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
package qnx.samples.viewer
{
	import qnx.events.ViewerEvent;
	import qnx.events.InvokeEvent;
	import qnx.invoke.InvokeManager;
	import qnx.invoke.InvokeStartupMode;
	import qnx.samples.viewer.views.MainView;
	import qnx.samples.viewer.views.PhotoViewer;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.utils.ByteArray;

	public class PhotoViewerSample extends Sprite
	{
		private var __view:DisplayObject;
		
		public function PhotoViewerSample()
		{
			InvokeManager.invokeManager.addEventListener(InvokeEvent.INVOKE, onInvoke );
			InvokeManager.DEBUG = true;
			InvokeManager.invokeManager.addEventListener(ErrorEvent.ERROR, onInvokeError );
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			stage.addEventListener(Event.RESIZE, onStageResize );
		}

		private function onInvokeError( event:ErrorEvent ):void
		{
			trace( "INVOKE ERROR:", event.text );
		}

		private function onInvoke( event:InvokeEvent ):void
		{

			if( InvokeManager.invokeManager.startupMode == InvokeStartupMode.VIEWER )
			{
				
				var data:ByteArray = InvokeManager.invokeManager.startupViewerRequest.data;
				var url:String = data.readUTFBytes( data.bytesAvailable );
				
				if( __view == null )
				{
					__view = new PhotoViewer();
					InvokeManager.invokeManager.addEventListener(ViewerEvent.VIEWER_MESSAGE, onViewerMessage );
				}
				PhotoViewer( __view ).setImage( url );
			}
			
			if( __view == null )
			{
				__view = new MainView();
			}
			
			addChild( __view );
			layout();
		}

		private function onViewerMessage( event:ViewerEvent ):void
		{
			
			if( event.message == "loadImage" )
			{
				PhotoViewer( __view ).setImage( event.data.url );
			}
			
		}

		
		private function layout():void
		{
			if( __view )
			{
				__view.width = stage.stageWidth;
				__view.height = stage.stageHeight;
			}
		}
		
		private function onStageResize( event:Event ):void
		{
			layout();
		}
	}
}
