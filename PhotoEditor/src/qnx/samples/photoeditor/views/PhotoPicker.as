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
	import flash.events.Event;
	import qnx.fuse.ui.core.Action;
	import qnx.fuse.ui.display.CardPicker;
	import qnx.fuse.ui.events.ActionEvent;
	import qnx.fuse.ui.events.ListEvent;
	import qnx.fuse.ui.listClasses.List;
	import qnx.fuse.ui.listClasses.ListSelectionMode;

	import flash.filesystem.File;

	/**
	 * @author jdolce
	 */
	public class PhotoPicker extends CardPicker
	{
		private var __list:List;
		
		public function PhotoPicker()
		{
		}

		override protected function init():void
		{
			
			super.init();
			
			title = "Choose Photo";
			addEventListener(ActionEvent.ACTION_SELECTED, onActionSelected );
			addEventListener(Event.CLOSE, onClose );
			
			__list = new List();
			
			var dir:File = File.userDirectory.resolvePath( "shared/camera" );
			var contents:Array = dir.getDirectoryListing();
			
			for( var i:int = 0; i<contents.length; i++ )
			{
				var path:File = contents[ i ] as File; 
				var index:int = path.nativePath.lastIndexOf( "/" );
				var label:String = path.nativePath.substr( index + 1 );
				__list.addItem( {label:label, path:path.url } );
			}
			
			__list.selectionMode = ListSelectionMode.SINGLE;
			__list.allowDeselect = false;
			__list.addEventListener(ListEvent.ITEM_CLICKED, onListClick );
			
			content = __list;		
			
			acceptAction = new Action( "Select" );
			acceptAction.enabled = false;
			dismissAction = new Action( "Cancel" );
						
		}

		private function onClose( event:Event ):void
		{
			__list.selectedIndex = -1;
			acceptAction.enabled = false;
		}
		
		private function onListClick( event:ListEvent ):void
		{
			acceptAction.enabled = true;
		}

		private function onActionSelected( event:ActionEvent ):void
		{
			if( event.action == acceptAction )
			{
				closeCard("ItemSelected", "text/plain", __list.selectedItem.path );
			}
		}
		
	}
}
