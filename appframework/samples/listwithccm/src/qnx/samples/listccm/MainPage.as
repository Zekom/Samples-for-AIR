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
package qnx.samples.listccm
{
	import qnx.fuse.ui.events.ContextMenuEvent;
	import qnx.fuse.ui.core.Action;
	import qnx.fuse.ui.core.ActionBase;
	import qnx.fuse.ui.core.ActionSet;
	import qnx.fuse.ui.events.ActionEvent;
	import qnx.fuse.ui.listClasses.List;
	import qnx.fuse.ui.navigation.Page;
	import qnx.ui.data.DataProvider;

	/**
	 * @author jdolce
	 */
	public class MainPage extends Page
	{
		private var __breakAction:Action;
		private var __hideAction:Action;
		
		private var __longPressedItem:Object;
		
		[Embed(source="../../../../images/defaultaction.png")]
		private var ActionIcon : Class;
		
		public function MainPage()
		{
		}

		override protected function init():void
		{
			super.init();
			
			var dp:DataProvider = new DataProvider();
			
			for( var i:int = 0; i<10; i++ )
			{
				dp.addItem( {label:"Highland", subtitle:"Image " + i, status:"", image:"images/picture1.png"} );
			}

			var list:List = new List();
			list.cellRenderer = ListRenderer;
			list.dataProvider = dp;
			
			content = list;
			
			
			var asv:Vector.<ActionSet> = new Vector.<ActionSet>();
			
			var a:Vector.<ActionBase> = new Vector.<ActionBase>();
			__breakAction = new Action( "Break", new ActionIcon() );
			__hideAction = new Action( "Hide", new ActionIcon() );
			
			a.push( __breakAction );
			a.push( __hideAction );
			
			var aset:ActionSet = new ActionSet( a, "Picture actions", "Set of the useful things to do ..." );
			
			asv.push( aset );
			
			list.contextActions = asv;
			list.addEventListener(ContextMenuEvent.OPENED, listContextMenuOpened );
			list.addEventListener(ContextMenuEvent.CLOSED, listContextMenuClosed );
			list.addEventListener(ActionEvent.ACTION_SELECTED, listActionSelected );
			
		}

		private function listContextMenuClosed( event:ContextMenuEvent ):void
		{
			__longPressedItem = null;
		}

		private function listContextMenuOpened( event:ContextMenuEvent ):void
		{
			var list:List = event.target as List;
			__longPressedItem = list.longPressedItem;
		}

		private function listActionSelected( event:ActionEvent ):void
		{
			var list:List = event.target as List;
			
			if( event.action == __breakAction )
			{
				__longPressedItem.image = ( __longPressedItem.status != "broken" ) ? "images/picture2.png" : "images/picture1.png";
				__longPressedItem.status = ( __longPressedItem.status != "broken" ) ? "broken" : "";
			}
			else if( event.action == __hideAction )
			{
				__longPressedItem.status = (__longPressedItem.status == "hidden" ) ? "" : "hidden";
			}
			
			list.updateItem(__longPressedItem, __longPressedItem);
			
		}


	}
}
