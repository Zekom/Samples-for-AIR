package qnx.samples.css {
	import qnx.fuse.ui.core.UIComponent;
	import qnx.fuse.ui.text.Label;

	import flash.display.Graphics;
	
	public class Box extends UIComponent
	{
		private var __color:uint = 0x000000;
		private var label:Label;
		
		public function Box()
		{
			super();
		}
		
		override protected function init():void
		{
			label = new Label();
			label.text = "Box";
			addChild( label );
			super.init();
		}
		
		override protected function get cssID():String
		{
			return "Box";
		}
		
		public function get color():uint
		{
			return( __color );
		}
		
		public function set color( hex:uint ):void
		{
			__color = hex;
			invalidateDisplayList();
		}
		
		override protected function updateDisplayList( unscaledWidth:Number, unscaledHeight:Number ):void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			
			var g:Graphics = this.graphics;
			g.beginFill( __color, 1 );
			g.drawRect( 0,0,unscaledWidth, unscaledHeight );
			g.endFill();

			label.validateNow();
			label.width = unscaledWidth;
			label.height = label.textHeight;
			label.y = Math.round( ( unscaledHeight - label.height ) / 2 );
		}
	}
}