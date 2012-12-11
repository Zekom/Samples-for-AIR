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
package qnx.samples.viewer.views
{
	import qnx.fuse.ui.core.SizeOptions;
	import qnx.fuse.ui.core.Container;
	import qnx.fuse.ui.core.UIComponent;
	import qnx.fuse.ui.display.Image;
	import qnx.fuse.ui.layouts.gridLayout.GridLayout;

	/**
	 * @author jdolce
	 */
	public class PhotoViewer extends UIComponent
	{
		private var __image:Image;
		private var __container:Container;
		
		public function PhotoViewer()
		{
		}
		
		
		
		override protected function init():void
		{
			super.init();
			
			__container = new Container();
			var layout:GridLayout = new GridLayout();
			layout.setOptions( SizeOptions.RESIZE_BOTH );
			__container.layout = layout;
			
			addChild( __container );
			
			__image = new Image();
			__image.fixedAspectRatio = true;
			__container.addChild( __image );
		}

		override protected function updateDisplayList( unscaledWidth:Number, unscaledHeight:Number ):void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			__container.width = unscaledWidth;
			__container.height = unscaledHeight;
		}
		
		public function setImage( image:Object ):void
		{
			__image.setImage( image );
		}

		
	}
}
