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
package qnx.samples.listccm
{
	import qnx.fuse.ui.text.TextAlign;
	import qnx.fuse.ui.display.Image;
	import qnx.fuse.ui.listClasses.CellRenderer;
	import qnx.fuse.ui.text.Label;
	import qnx.fuse.ui.text.TextFormat;
	import qnx.fuse.ui.text.TextFormatStyle;
	import qnx.fuse.ui.theme.ThemeGlobals;
	import qnx.fuse.ui.utils.ImageCache;

	import flash.text.TextLineMetrics;

	/**
	 * @author jdolce
	 */
	public class ListRenderer extends CellRenderer
	{
		
		private static var cache:ImageCache = new ImageCache();
		
		private var icon:Image;
		private var subtitle:Label;
		private var status:Label;
		
		public function ListRenderer()
		{
			super();
		}

		override protected function init():void
		{
			mouseChildren = false;
			super.init();
			icon = new Image();
			icon.cache = cache;
			icon.width = 81;
			icon.height = 81;
			addChild( icon );
			
			subtitle = new Label();
			var format:TextFormat = subtitle.format;
			format.style = TextFormatStyle.SMALL;
	
			var oled:Boolean = ThemeGlobals.useOLED;
			
			if( ThemeGlobals.currentTheme == ThemeGlobals.BLACK )
			{
				format.color =( oled ) ? 0x9E9E9E : 0x555555;		
			}
			else if( ThemeGlobals.currentTheme == ThemeGlobals.WHITE )
			{
				format.color = ( oled ) ? 0x4C4C4C : 0x555555;
			}
			
			
			subtitle.format = format;
			addChild( subtitle );
			
			var statusFormat:TextFormat = format.clone();
			statusFormat.align = TextAlign.RIGHT;
			
			status = new Label();
			status.format = statusFormat;
			addChild( status );
			
		}
		
		override protected function drawLabel( unscaledWidth:Number, unscaledHeight:Number ):void
		{
			var metrics:TextLineMetrics = label.getLineMetrics(0);
			var textHeight:Number = Math.floor( metrics.ascent + metrics.descent );
			
			status.width = 200;
			status.x = unscaledWidth - status.width  - paddingRight;
			
			var labelX:Number = ( icon.width > 0 ) ? paddingLeft + icon.x + icon.width : paddingLeft;
			
			label.x = labelX;
			label.width = status.x - ( label.x + paddingRight );
			label.height = textHeight;
			
			
			metrics = subtitle.getLineMetrics( 0 );
			subtitle.height = Math.round( metrics.ascent + metrics.descent );
			subtitle.x = label.x;
			subtitle.width = label.width;
			
			label.y = Math.floor( (unscaledHeight - (label.height + subtitle.height) )/2 );
			subtitle.y = label.y + label.height;
			
			status.y = Math.round( textHeight / 2 ) + label.y;
			
		}

		override protected function updateDisplayList( unscaledWidth:Number, unscaledHeight:Number ):void
		{
			icon.y = Math.round( ( unscaledHeight - icon.width ) / 2 );
			icon.x = 20;
			super.updateDisplayList( unscaledWidth, unscaledHeight );
		}
		
		
		override public function set data( data:Object ):void
		{
			super.data = data;
			
			if( data )
			{
				
				if( data.status != "hidden" )
				{
					icon.width = 81;
					icon.setImage(data.image);
				}
				else
				{
					icon.setImage( null );
					icon.width = 0;
				}
				
				
				subtitle.text = data.subtitle;
				status.text = data.status;
				
				drawLabel(width, height );
			}
			
		}
		
		
		
	}
}
