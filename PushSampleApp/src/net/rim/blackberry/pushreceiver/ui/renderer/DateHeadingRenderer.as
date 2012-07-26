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

package net.rim.blackberry.pushreceiver.ui.renderer
{
	import flash.display.Sprite;
	import flash.text.TextLineMetrics;
	
	import qnx.fuse.ui.layouts.Align;
	import qnx.fuse.ui.listClasses.SectionHeaderRenderer;
	import qnx.fuse.ui.text.Label;
	import qnx.fuse.ui.text.TextAlign;
	import qnx.fuse.ui.text.TextFormat;
	import qnx.fuse.ui.text.TextFormatStyle;
	import qnx.fuse.ui.utils.LayoutUtil;
	import qnx.system.FontSettings;
	
	/**
	 *  Renders a date heading in the list.
	 */	
	public class DateHeadingRenderer extends SectionHeaderRenderer
	{
		protected var background:Sprite;
		protected var dateHeading:Label;
		protected var format:TextFormat;
		
		public function DateHeadingRenderer()
		{
			super();
		}
		
		override public function set data(value:Object):void
		{											
			super.data = value;
			
			if (value) {
				dateHeading.text = value.label;
			}
		}
		
		override protected function styleState():void
		{					
			super.styleState();
			
			background.graphics.clear();
			background.graphics.beginFill(0xCCCCCC, 1.0);
			background.graphics.drawRect(0, 0, width, height);
			background.graphics.endFill();
		}
		
		/*
		override public function updateFontSettings():void
		{
			super.updateFontSettings();
			
			dateHeading.updateFontSettings();
		}
		*/
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{						
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			dateHeading.width = unscaledWidth;
			dateHeading.y = LayoutUtil.computeAlignment(0, unscaledHeight, dateHeading.height, Align.CENTER);
		}
		
		override protected function init():void
		{					
			super.init();
			
			background = new Sprite();
			dateHeading = new Label();
			
			format = new TextFormat();
			format.style = TextFormatStyle.CONTENT;
			format.bold = true;
			format.align = TextAlign.CENTER;
			
			dateHeading.format = format;
			
			addChild(background);
			addChild(dateHeading);
		}
	}
}