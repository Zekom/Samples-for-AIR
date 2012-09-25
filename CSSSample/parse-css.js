// Utility task that transforms a CSS file in to a
// a data structure that AIR can parse natively. This
// output is then saved to an .as file and built in to
// the skins ANEs in a later build step.

// Because input is sanitized and normalized in the build
// phase instead of at application initialization, and because
// it is less computationally expensive to parse a native data structure
// in to a style tree, we can incur significant performance gains.

importClass(java.util.regex.Pattern);

function parseFile(filename) {

	/*
	 * Take a selector and apply consistent formatting to it. 
	 */
	 function normalizeSelector(selector) {

		// condense the whitespace so all spaces, tabs and newlines are replaced by a single space.
		selector = selector.replaceAll( "\\s+", ' ' );

		// Normalize the state selectors so all . or : characters are preceeded by a single space,
		// and the internal character is changed to a :.
		var stateSplit = selector.split( /\\.| \\.|\\:| \\:/g );
		var stateJoined = stateSplit.join( " :" );

		// Normalize the ID selectors so all # characters are preceeded by a single space.
		var idSplit = stateJoined.split( /#| #/g );
		var idJoined = idSplit.join( " #" ).replace( /^\s+|\s+$/g, '' );
		
		return idJoined;
	}

	/*
	 * Parses a string value and transforms it to a number if possible.
	 * Otherwise a String value is returned wrapped in quotes.
	 */
	 function parseValue(value) {
		if (! value) {
			return null;
		}

		var stringValue = value;
		var numVal = parseFloat( stringValue );
		if (!isNaN( numVal )) {
			return numVal;
		}

		if(stringValue == "true" || stringValue == "false" 
			|| stringValue == "Infinity" || stringValue == "NaN" 
			|| stringValue == "null") {
			return stringValue;
		}

		return '"' + value.toString() + '"';
	 }

	/**
	 * Formats a properties array and returns a valid native ActionScript object.
	 */ 
	 function propertiesToString(arr, filename){

		var str = "";
		var i = 0;
		var selectorCount = 0;
		var styleCount = 0;
		var lineEnding = '\n\t\t\t';
		do {
			selectorCount++;
			str += '"' + arr[i].toString() + '",';

			var len = arr[i + 1];
			str += len.toString() + ",";
			i += 2;
			for (var j = i; j < i + len * 2; j += 2) {
				str += arr[j].toString() + ",";
				str += arr[j+1].toString() + ",";
				styleCount++;
			}
			i += len * 2;
			str += lineEnding;
		} while(i < arr.length);

		// trim trailing comma
		str = str.substr(0, str.length - lineEnding.length - 1);

		echo = project.createTask("echo");
		echo.setMessage("Parsed " + filename + ":\n\tGenerated " + selectorCount + " selectors\n\tGenerated " + styleCount + " styles");
		echo.perform();
		
		return "[" + lineEnding + str + "\n\t\t]"
	}

	/**
	 * Parses a CSS string in to a JavaScript array of selectors and properties.
	 * 
	 * Data is serialized in to a linear buffer, where the first element of the Array
	 * is a selector, and the next is an interger (n) that dictates how many key/value pairs
	 * follow in the array. After n*2 elements, we know the next element to be a selector, and
	 * the pattern repeats.
	 */
	 function parseCSS(css) {

		var arr = [];

		css = css.replaceAll( "//.*|(\"(?:\\\\[^\"]|\\\\\"|.)*?\")|(?s)/\\*.*?\\*/", "$1");
		css = css.replaceAll( "/\\s*([@{}:;,]|\\)\\s|\\s\\()\\\\s*|\\/\\\\*([^*\\\\\\\\]|\\*(?!\\/))+\\*\\/|[\\n\\r\\t]|(px)/", '$1' );
		css = css.replaceAll( "\\s+(\\})", '$1' );
		css = css.replaceAll( "\\s+(\\{)", '$1' );
		css = css.replaceAll( "(:)\\s+", '$1' );

		var matcher = Pattern.compile("(.*?)\\{(.*?)\\}").matcher(css);

		while ( matcher.find() ) {

			var prefix = matcher.group(1);
			var suffix = matcher.group(2);

			var prefixElements = prefix.split( ',' );
			var suffixElements = suffix.split( ';' );

			for (var i = 0; i < prefixElements.length; i++)
			{
				var selector = prefixElements[i];
				if (! selector) {
					break;
				}

				var normalizedSelector = normalizeSelector( selector );

				arr.push(normalizedSelector);
				arr.push(suffixElements.length);
				for (var j = 0; j < suffixElements.length; j++) {
					var pair = suffixElements[j];
					if (! pair) {
						self.fail("Invalid CSS encountered");
						break;
					}

					parts = pair.split( ':' );
					var value = parseValue(parts[1]);
					arr.push( '"' + parts[0].replaceAll("\\s+", '') + '"' );
					arr.push( value );
				}
			}
		}

		return arr;
	}

	// Load the input CSS file
	loadFile = project.createTask("loadfile");
	loadFile.setProperty(filename);
	loadFile.setSrcFile( new java.io.File( filename ) );
	loadFile.perform();

	// grab the file we just loaded from memory and parse it to a native object.
	dependencyFile = project.getProperty(filename);
	var str = propertiesToString(parseCSS(dependencyFile), filename);

	// load the template .as file which will serve as scaffolding for the generated native object.
	var templateName = attributes.get("template") || project.getProperty("base.build") + "/template/StyleTemplate.txt";
	loadFile = project.createTask("loadfile");
	loadFile.setProperty(templateName);
	loadFile.setSrcFile( new java.io.File( templateName ) );
	loadFile.perform();

	// The output file name is also the class name.
	var outputPath = attributes.get("output");
	var outputName = outputPath.replaceAll("^.*[\\\\\\/]", '');
	outputName = outputName.split("\\.")[0];

	// Replace template variables with content
	template = project.getProperty(templateName);
	template = template.replaceAll("\\{styles\\}", str);
	template = template.replaceAll("\\{title\\}", outputName);

	// Finally, Write the file to the target file.
	echo = project.createTask("echo");
	echo.setFile(new java.io.File( attributes.get("output") ) );
	echo.setMessage(template);
	echo.perform();

	echo = project.createTask("echo");
	echo.setMessage("Saved to " + attributes.get("output") + "\n\n");
	echo.perform();

}

parseFile(attributes.get("input"));
