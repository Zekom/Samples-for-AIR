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
package qnx.samples.navigationdrilldown
{
	import qnx.fuse.ui.core.Container;
	import qnx.fuse.ui.core.SizeOptions;
	import qnx.fuse.ui.layouts.Align;
	import qnx.fuse.ui.layouts.gridLayout.GridLayout;
	import qnx.fuse.ui.navigation.Page;
	import qnx.fuse.ui.text.Label;
	import qnx.fuse.ui.text.TextAlign;
	import qnx.fuse.ui.text.TextFormat;
	import qnx.fuse.ui.text.TextFormatStyle;
	import qnx.fuse.ui.titlebar.TitleBar;

	/**
	 * @author jdolce
	 */
	public class CitiesPage extends Page
	{
		private var __title:String;
		private var __city:String;
		
		public function CitiesPage( item:Object )
		{
			__title = item.label;
			__city = item.capital;
			super();
		}
		
		override protected function init():void
		{
			titleBar = new TitleBar();
			titleBar.title = __title;
			
			super.init();
			
			var container:Container = new Container();
			
			var layout:GridLayout = new GridLayout();
			layout.padding = 20;
			layout.setOptions(SizeOptions.GROW_VERTICAL | SizeOptions.RESIZE_HORIZONTAL);
			layout.setTopLevelAlign(Align.CENTER, Align.CENTER );
			container.layout = layout;
			
			
			var label:Label = new Label();
			label.maxLines = 0;
			label.text = "The capital of " + __title + " is " + __city;
			
			var format:TextFormat = label.format;
			format.align = TextAlign.CENTER;
			format.style = TextFormatStyle.XXLARGE;
			
			label.format = format;
			
			container.addChild( label );
			
			content = container;
			
			
		}
	}
}
