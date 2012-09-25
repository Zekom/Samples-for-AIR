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
package qnx.fuse.ui.titlebar
{
	import qnx.fuse.ui.core.DefaultSize;
	import qnx.fuse.ui.core.UIComponent;
	import qnx.fuse.ui.text.Label;
	import qnx.fuse.ui.text.TextAlign;
	import qnx.fuse.ui.text.TextFormat;
	import qnx.fuse.ui.utils.DisplayObjectUtils;

	import flash.display.Bitmap;

	/**
	 * @author juliandolce
	 */
	public class TitleBar extends UIComponent
	{
		
		[Embed(source="../../../../../assets/images/titlebar/core_title_bar.png")]
		private var BG_IMAGE : Class;
		
		[Embed(source="../../../../../assets/images/titlebar/core_title_bar_shadow.png")]
		private var SHADOW_IMAGE : Class;
		
		private var __bg:Bitmap;
		private var __shadow:Bitmap;
		private var __label:Label;
		private var __title:String;
		private var __paddingLeft:int;
		
		public function get paddingLeft():int
		{
			return( __paddingLeft );
			
		}
		
		public function set paddingLeft( value:int ):void
		{
			if( __paddingLeft != value )
			{
				__paddingLeft = value;
				invalidateDisplayList();
			}
		}
		
		
		public function get title():String
		{
			return( __title );
		}
		
		public function set title( value:String ):void
		{
			if( __title != value )
			{
				__title = value;
				__label.text = value;
			}
		}
		
		public function TitleBar()
		{
		}
		
		
		override protected function get cssID():String
		{
			return "TitleBar";
		}
		
		override protected function init():void
		{
			super.init();
			__bg = DisplayObjectUtils.getDisplayAsset(BG_IMAGE) as Bitmap;
			addChild( __bg );
			
			__shadow = DisplayObjectUtils.getDisplayAsset(SHADOW_IMAGE) as Bitmap;
			addChild( __shadow );
			
			__label = new Label();
			
			var format:TextFormat = __label.format;
			format.size = 54;
			
			__label.format = format;
			__label.selectable = false;
			addChild( __label );
			
			__label.height = __label.measure(DefaultSize, DefaultSize).preferredHeight;
		}

		override protected function updateDisplayList( unscaledWidth:Number, unscaledHeight:Number ):void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			__bg.width = unscaledWidth;
			__bg.height = unscaledHeight;
			
			__shadow.width = unscaledWidth;
			__shadow.y = unscaledHeight;
			
			__label.x = __paddingLeft;
			__label.width = unscaledWidth - __label.x;
			__label.y = Math.round( ( unscaledHeight - __label.height ) / 2 );
		}


	}
}
