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