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
	import qnx.events.InvokeQueryTargetEvent;
	import qnx.fuse.ui.actionbar.ActionPlacement;
	import qnx.fuse.ui.core.Action;
	import qnx.fuse.ui.core.ActionBase;
	import qnx.fuse.ui.core.Container;
	import qnx.fuse.ui.core.SizeOptions;
	import qnx.fuse.ui.dialog.ToastBase;
	import qnx.fuse.ui.display.CardPreviewer;
	import qnx.fuse.ui.display.Image;
	import qnx.fuse.ui.events.ActionEvent;
	import qnx.fuse.ui.layouts.gridLayout.GridLayout;
	import qnx.images.ImageSaver;
	import qnx.images.ImageSaverCodes;
	import qnx.invoke.ActionQuery;
	import qnx.invoke.FileTransferMode;
	import qnx.invoke.InvokeManager;
	import qnx.invoke.InvokeRequest;
	import qnx.invoke.InvokeTarget;
	import qnx.invoke.InvokeTargetOptions;

	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.geom.ColorTransform;
	import flash.utils.getTimer;

	/**
	 * @author jdolce
	 */
	public class PhotoPreviewer extends CardPreviewer
	{
		private var __image:Image;
		private var __container:Container;
		private var __data:Object;
	
		public function PhotoPreviewer()
		{
		}

		
		override protected function init():void
		{
			
			super.init();
			InvokeManager.DEBUG = true;
			InvokeManager.invokeManager.addEventListener(InvokeQueryTargetEvent.SUCCESS, onTargets );
			InvokeManager.invokeManager.addEventListener(ErrorEvent.ERROR, onError );

			__container = new Container();
			var layout:GridLayout = new GridLayout();
			layout.setOptions( SizeOptions.RESIZE_BOTH );
			__container.layout = layout;
			
			content = __container;
			
			__image = new Image();
			__image.fixedAspectRatio = true;
			__container.addChild( __image );
			
			addEventListener( ActionEvent.ACTION_SELECTED, actionSelected );

		}

		private function onError( event:ErrorEvent ):void
		{
			var toast:ToastBase = new ToastBase();
			toast.message = "Inovke Error";
			toast.show();
		}

		private function actionSelected( event:ActionEvent ):void
		{
			var file:File = new File( __data.url );

			var newFile:File = File.userDirectory.resolvePath( "shared/photos/PhotoEditor" + getTimer() + "." + file.extension );

			var saver:ImageSaver = new ImageSaver();
			var success:int = saver.saveImage( __image.bitmapData, newFile.nativePath, false );
			
			if( success == ImageSaverCodes.IMG_ERR_OK )
			{
				var request:InvokeRequest = new InvokeRequest();
				request.target = event.action.data.key;
				request.uri = newFile.url;
				request.fileTransferMode = FileTransferMode.COPY_READ_WRITE;
				request.action = event.action.data.action;
				InvokeManager.invokeManager.invoke(request);
			}
			else
			{
				var toast:ToastBase = new ToastBase();
				toast.message = "Image failed to save. " + success;
				toast.show();
			}

		}
		
		private function onTargets( event:InvokeQueryTargetEvent ):void
		{
			var queryActions:Vector.<ActionBase> = new Vector.<ActionBase>();
			for( var i:int = 0; i<event.actions.length; i++ )
			{
				var action:ActionQuery = event.actions[ i ];
				
				for( var j:int = 0; j<action.targets.length; j++ )
				{
					var target:InvokeTarget = action.targets[ j ];
					
					var icon:String = ( action.icon == "" ) ? target.icon : action.icon;
					
					var a:Action = new Action( action.label + " " + target.label, "file://" + icon, {key:target.target, action:action.action} );
					a.actionBarPlacement = ActionPlacement.IN_OVERFLOW;
					
					queryActions.push( a );
				}
			}
			
			actions = queryActions;
		}
		
		public function setData( data:Object ):void
		{
			InvokeManager.invokeManager.queryInvokeTargets( null, data.url, null, InvokeTargetOptions.APPLICATION );
			__data = data;

			__image.visible = false;
			__image.setImage( data.url );
			__image.addEventListener(Event.COMPLETE, onImageLoad );
		}

		private function onImageLoad( event:Event ):void
		{
			__container.validateNow();
			var transform:ColorTransform = new ColorTransform();
			transform.redMultiplier = __data.r;
			transform.greenMultiplier = __data.g;
			transform.blueMultiplier = __data.b;
			
			
			__image.bitmapData.draw( __image.bitmapData, null, transform );
			__image.visible = true;
		}


	}
}
