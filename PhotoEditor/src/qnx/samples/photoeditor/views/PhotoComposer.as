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
package qnx.samples.photoeditor.views
{
	import qnx.fuse.ui.core.Action;
	import qnx.fuse.ui.core.Container;
	import qnx.fuse.ui.core.SizeOptions;
	import qnx.fuse.ui.display.CardComposer;
	import qnx.fuse.ui.display.Image;
	import qnx.fuse.ui.events.ActionEvent;
	import qnx.fuse.ui.events.SliderEvent;
	import qnx.fuse.ui.layouts.gridLayout.GridData;
	import qnx.fuse.ui.layouts.gridLayout.GridLayout;
	import qnx.fuse.ui.slider.Slider;
	import qnx.fuse.ui.text.Label;

	import flash.events.Event;
	import flash.filters.ColorMatrixFilter;

	/**
	 * @author jdolce
	 */
	public class PhotoComposer extends CardComposer
	{
		private var __red:Slider;
		private var __green:Slider;
		private var __blue:Slider;
		
		private var __image:Image;
		
		public function PhotoComposer()
		{
		}

		override protected function init():void
		{
			addEventListener(Event.CLOSE, onCardClose );
			addEventListener(ActionEvent.ACTION_SELECTED, onActionSelected );
			
			super.init();
			title = "Edit";
			acceptAction = new Action( "Save" );
			dismissAction = new Action( "Cancel" );

			var container:Container = new Container();
			
			var layout:GridLayout = new GridLayout();
			layout.padding = 20;
			layout.spacing = 20;
			layout.setOptions(SizeOptions.RESIZE_VERTICAL);
			container.layout = layout;
			
			
			__image = new Image();
			var d:GridData = new GridData();
			d.setOptions(SizeOptions.RESIZE_BOTH);
			__image.layoutData = d;
			
			
			__image.fixedAspectRatio = true;
			
			container.addChild( __image );
			
			
			var rLabel:Label = new Label();
			rLabel.text = "Red";
			container.addChild( rLabel );
			
			__red = new Slider();
			__red.addEventListener(SliderEvent.MOVE, sliderChange );
			__red.minimum = 0;
			__red.maximum = 1;
			container.addChild( __red );
			
			var gLabel:Label = new Label();
			gLabel.text = "Green";
			container.addChild( gLabel );
			
			__green = new Slider();
			__green.addEventListener(SliderEvent.MOVE, sliderChange );
			__green.minimum = 0;
			__green.maximum = 1;
			container.addChild( __green );
			
			var bLabel:Label = new Label();
			bLabel.text = "Blue";
			container.addChild( bLabel );
			
			__blue = new Slider();
			__blue.addEventListener(SliderEvent.MOVE, sliderChange );
			__blue.minimum = 0;
			__blue.maximum = 1;
			container.addChild( __blue );
			
			__red.animateToValue = false;
			__green.animateToValue = false;
			__blue.animateToValue = false;
			
			__red.value = 1;
			__green.value = 1;
			__blue.value = 1;
			
			content = container;
			
			content.visible = false;
			
		}

		private function sliderChange( event:SliderEvent ):void
		{
			 var matrix:Array = new Array();
		    matrix = matrix.concat([__red.value, 0, 0, 0, 0]); 
		    matrix = matrix.concat([0, __green.value, 0, 0, 0]); 
		    matrix = matrix.concat([0, 0, __blue.value, 0, 0]); 
		    matrix = matrix.concat([0, 0, 0, 1, 0]); 
		
		    var filter:ColorMatrixFilter = new ColorMatrixFilter(matrix);
		    __image.filters = [filter];
		}
		
		public function setData( data:Object ):void
		{
			__image.setImage( data.url );
			__image.addEventListener(Event.COMPLETE, onImageLoad );
		}

		private function onImageLoad( event:Event ):void
		{
			
			content.visible = true;
		}
		

		private function onActionSelected( event:ActionEvent ):void
		{
			if( event.action == acceptAction )
			{
				var obj:Object = {r:__red.value, g:__green.value, b:__blue.value };
				closeCard("ContentSaved", "text/plain", JSON.stringify(obj) );
			}
		}

		private function onCardClose( event:Event ):void
		{
			__red.value = 1;
			__green.value = 1;
			__blue.value = 1;
		}

	}
}
