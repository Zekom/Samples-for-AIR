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
	import qnx.events.CardCloseEvent;
	import qnx.fuse.ui.actionbar.ActionBar;
	import qnx.fuse.ui.core.Action;
	import qnx.fuse.ui.core.UIComponent;
	import qnx.fuse.ui.events.ActionEvent;
	import qnx.fuse.ui.titlebar.TitleBar;
	import qnx.invoke.InvokeManager;
	import qnx.invoke.InvokeRequest;
	import qnx.samples.photoeditor.Icons;

	import flash.display.Bitmap;
	import flash.utils.ByteArray;

	/**
	 * @author jdolce
	 */
	public class MainView extends UIComponent
	{
		private var __titleBar:TitleBar;
		private var __actionBar:ActionBar;
		
		private var __select:Action;
		private var __edit:Action;
		private var __preview:Action;
		
		private var __invokedTarget:String;
		

		private var __composeData:String;
		private var __url:String;
		
		private var __icon:Bitmap = new Icons.ICON_LOGO();
		
		public function MainView()
		{
		}

		override protected function init():void
		{
			super.init();
			
			InvokeManager.invokeManager.addEventListener(CardCloseEvent.CARD_CLOSED, onCardClosed );
			
			__titleBar = new TitleBar();
			__titleBar.title = "Photo Editor";
			addChild( __titleBar );
			
			__actionBar = new ActionBar();
			__actionBar.addEventListener(ActionEvent.ACTION_SELECTED, onActionSelected );
			__actionBar.showTabsFirstOnBar(false);
			
			__select = new Action( "Select", Icons.ICON_SELECT );
			__actionBar.addAction(__select);
			
			__edit = new Action( "Edit", Icons.ICON_EDIT );
			__actionBar.addAction( __edit );
			
			__preview = new Action( "Preview", Icons.ICON_IMAGE );
			__actionBar.addAction( __preview );
			
			
			addChild( __actionBar );
			
			addChild( __icon );
		}


		private function onActionSelected( event:ActionEvent ):void
		{
			var request:InvokeRequest = new InvokeRequest();
			var obj:Object = {};
			obj.url = __url;
			var ba:ByteArray = new ByteArray();
			switch( event.action )
			{
				case __edit:
					__invokedTarget = "qnx.samples.photoeditor.composer";
					ba.writeUTFBytes( JSON.stringify(obj));
					request.data = ba;
					
					break;
				case __select:

					__invokedTarget = "qnx.samples.photoeditor.picker";
					
					break;
				case __preview:
					__invokedTarget = "qnx.samples.photoeditor.previewer";

					if( __composeData )
					{
						obj = JSON.parse( __composeData );
					}

					ba.writeUTFBytes( JSON.stringify(obj));
					request.data = ba;
					
					break;
			}
			
			request.target = __invokedTarget;
			InvokeManager.invokeManager.invoke( request );
		}

		private function onCardClosed( event:CardCloseEvent ):void
		{
			switch( __invokedTarget )
			{
				case "qnx.samples.photoeditor.picker":
					
					if( event.reason == "ItemSelected" )
					{
						__url =  event.data;
					}
					break;
				case "qnx.samples.photoeditor.composer":
					if( event.reason == "ContentSaved" )
					{
						__composeData = event.data;
					}
					break;
			}
		}
		


		override protected function updateDisplayList( unscaledWidth:Number, unscaledHeight:Number ):void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			__actionBar.y = unscaledHeight - __actionBar.height;
			__actionBar.width = unscaledWidth;
			__titleBar.width = unscaledWidth;
			__icon.x = Math.round( (unscaledWidth - __icon.width ) / 2 );
			__icon.y = Math.round( ( ( unscaledHeight - __titleBar.height - __actionBar.height ) - __icon.height) / 2 ) + __titleBar.height;
			
		}


	}
}
