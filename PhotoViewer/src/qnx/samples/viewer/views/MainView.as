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
	import qnx.display.Viewer;
	import qnx.events.ViewerEvent;
	import qnx.fuse.ui.actionbar.ActionBar;
	import qnx.fuse.ui.core.Action;
	import qnx.fuse.ui.core.UIComponent;
	import qnx.fuse.ui.events.ActionEvent;
	import qnx.fuse.ui.titlebar.TitleBar;
	import qnx.invoke.InvokeManager;
	import qnx.invoke.InvokeViewerRequest;
	import qnx.samples.viewer.Icons;

	import flash.filesystem.File;
	import flash.utils.ByteArray;

	/**
	 * @author jdolce
	 */
	public class MainView extends UIComponent
	{
		private var __titleBar:TitleBar;
		private var __actionBar:ActionBar;
		
		private var __select:Action;

		private var __viewer:Viewer;
		private var __url:String;
		
		private var __files:Array;
		

		public function MainView()
		{
		}

		override protected function init():void
		{
			super.init();

			__titleBar = new TitleBar();
			__titleBar.title = "Photo Editor";
			addChild( __titleBar );
			
			__actionBar = new ActionBar();
			__actionBar.addEventListener(ActionEvent.ACTION_SELECTED, onActionSelected );
			__actionBar.showTabsFirstOnBar(false);
			
			__select = new Action( "Randomize", Icons.ICON_IMAGE );
			__actionBar.addAction(__select);
			
			addChild( __actionBar );
			
			
			var dir:File = File.userDirectory.resolvePath( "shared/camera" );
			__files = dir.getDirectoryListing();
			
			
		}


		private function onActionSelected( event:ActionEvent ):void
		{
			randomizeImage();
		}
		
		
		private function randomizeImage():void
		{
			var index:int = Math.floor(Math.random() * __files.length );
			setImage( File( __files[index] ).url );
		}
		
		private function setImage( url:String ):void
		{
			__url = url;
			if( __viewer == null )
			{
				var request:InvokeViewerRequest = new InvokeViewerRequest();
				request.target = "qnx.samples.photoviewer.viewer";
				request.windowId = "photoviewerwindow";
				request.windowWidth = width;
				request.windowHeight = __actionBar.y - __titleBar.height;
				var ba:ByteArray = new ByteArray();
				ba.writeUTFBytes(url);
				request.data = ba;

				__viewer = InvokeManager.invokeManager.invokeViewer(request);
				__viewer.addEventListener(ViewerEvent.VIEWER_CREATED, viewerCreated );
				
			}
			else
			{
				__viewer.sendMessage( "loadImage", {url:__url} );
			}
		}

		private function viewerCreated( event:ViewerEvent ):void
		{
			__viewer.y = __titleBar.height;
		}

		override protected function updateDisplayList( unscaledWidth:Number, unscaledHeight:Number ):void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			__actionBar.y = unscaledHeight - __actionBar.height;
			__actionBar.width = unscaledWidth;
			__titleBar.width = unscaledWidth;
			
			if( __viewer )
			{
				__viewer.y = __titleBar.height;
				__viewer.resize(unscaledWidth, __actionBar.y - __titleBar.height );
			}
			
		}


	}
}
