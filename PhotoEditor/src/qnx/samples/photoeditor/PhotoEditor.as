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
package qnx.samples.photoeditor
{
	import qnx.events.InvokeEvent;
	import qnx.invoke.InvokeManager;
	import qnx.invoke.InvokeRequest;
	import qnx.invoke.InvokeStartupMode;
	import qnx.samples.photoeditor.views.MainView;
	import qnx.samples.photoeditor.views.PhotoComposer;
	import qnx.samples.photoeditor.views.PhotoPicker;
	import qnx.samples.photoeditor.views.PhotoPreviewer;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.ErrorEvent;
	import flash.events.Event;

	public class PhotoEditor extends Sprite
	{
		
		private var __view:DisplayObject;
		
		
		public function PhotoEditor()
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
			if( __view != null )
			{
				//we have already been invoked once and are being re-launched from the pool.
				return;
			}
			
			if( InvokeManager.invokeManager.startupMode == InvokeStartupMode.INVOKE )
			{
				var request:InvokeRequest =  InvokeManager.invokeManager.startupRequest;
				
				switch( request.target )
				{
					case "qnx.samples.photoeditor.picker":
						__view = new PhotoPicker();
						break;
					case "qnx.samples.photoeditor.composer":
						__view = new PhotoComposer();
						PhotoComposer( __view ).setData( JSON.parse( request.data.readUTFBytes( request.data.bytesAvailable ) as String ) );
						break;
					case "qnx.samples.photoeditor.previewer":
						__view = new PhotoPreviewer();
						PhotoPreviewer( __view ).setData( JSON.parse( request.data.readUTFBytes( request.data.bytesAvailable ) as String ) );
						break;
				}
				__view.addEventListener( Event.CLOSE, onCardClose );
			}
			
			if( __view == null )
			{
				__view = new MainView();
			}
			
			addChild( __view );
			layout();
		}

		private function onCardClose( event:Event ):void
		{
			__view.removeEventListener( Event.CLOSE, onCardClose );
			removeChild( __view );
			__view = null;
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
