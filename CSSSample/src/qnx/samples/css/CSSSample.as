/*
* Copyright (c) 2012 Research In Motion Limited.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/
package qnx.samples.css 
{
	import qnx.fuse.ui.theme.ThemeGlobals;
	import qnx.samples.css.styles.CoreStyles;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	public class CSSSample extends Sprite
	{
		//If you wish to embed the CSS you can uncomment these lines and use the
		//ThemeGlobals.injectCSS() method in the constructor.
		//With bigger files it is better to use the ant script in build.xml to auto-generate the native styles.
		//[Embed(source="../../../styles.css", mimeType="application/octet-stream")]
		//public static var STYLES:Class;
		
		
		public function CSSSample()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			//Uncomment if you are embedding the css.
			//ThemeGlobals.injectCSS((new STYLES() as ByteArray).toString());
			
			ThemeGlobals.injectStyleArray( CoreStyles.style );
			
			
			var box : Box = new Box();
			addChild(box);

			
		}
	}
}