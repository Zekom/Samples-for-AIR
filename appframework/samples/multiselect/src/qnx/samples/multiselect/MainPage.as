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
package qnx.samples.multiselect
{
	import qnx.fuse.ui.actionbar.ActionPlacement;
	import qnx.fuse.ui.core.Action;
	import qnx.fuse.ui.core.ActionBase;
	import qnx.fuse.ui.core.ActionSet;
	import qnx.fuse.ui.core.DeleteAction;
	import qnx.fuse.ui.core.MultiSelectAction;
	import qnx.fuse.ui.events.ActionEvent;
	import qnx.fuse.ui.events.ContextMenuEvent;
	import qnx.fuse.ui.events.ListEvent;
	import qnx.fuse.ui.listClasses.List;
	import qnx.fuse.ui.listClasses.ListSelectionMode;
	import qnx.fuse.ui.navigation.Page;
	import qnx.fuse.ui.skins.SkinAssets;
	import qnx.fuse.ui.titlebar.TitleBar;

	import flash.events.Event;

	/**
	 * @author jdolce
	 */
	public class MainPage extends Page
	{
		private var __list:List;
		private var __editAction:Action;
		private var __deleteAction:DeleteAction;
		private var __multiselect:MultiSelectAction;
		
		private var __editingItem:Object;
		
		private var __tempDeleteAction:Action;
		private var __multiSelectSet:Vector.<ActionSet>;
		private var __standardSet:Vector.<ActionSet>;
		
		[Embed(source="../../../../images/ic_add.png")]
		private var AddIcon : Class;
		
		[Embed(source="../../../../images/ic_edit.png")]
		private var EditIcon : Class;
		
		public function MainPage()
		{
		}

		override protected function init():void
		{
			titleBar = new TitleBar();
			titleBar.title = "To Do";
			super.init();
			
			__list = new List();
			
			__standardSet = new Vector.<ActionSet>();
			
			var a:Vector.<ActionBase> = new Vector.<ActionBase>();
			__editAction = new Action( "Edit", new EditIcon() );
			__deleteAction = new DeleteAction( "Delete" );
			__multiselect = new MultiSelectAction( "Select More" );
			
			//This is temporary until a bug is fixed so that just a DeleteAction can be set after mulit-select
			__tempDeleteAction = new Action( "Delete", new SkinAssets.DeleteIconCommon() );
			
			var lsv:Vector.<ActionBase> = new <ActionBase>[__tempDeleteAction];
			//This is temporary until a bug is fixed so that just a DeleteAction can be set after mulit-select
			var as4:ActionSet = new ActionSet( lsv , "Select Multiple", "");
			__multiSelectSet = new <ActionSet>[as4];
			
			a.push( __editAction );
		
			
			var aset:ActionSet = new ActionSet( a, "To Do Actions", "Edit or Delete Actions", __deleteAction, __multiselect );
			
			__standardSet.push( aset );
			
			__list.contextActions = __standardSet;

			__list.addEventListener(ActionEvent.ACTION_SELECTED, listActionSelected );
			__list.addEventListener(ContextMenuEvent.CLOSED, listContextMenuClosed );
			__list.selectionMode = ListSelectionMode.SINGLE;
			
			content = __list;
		
			var mainActions:Vector.<ActionBase> = new Vector.<ActionBase>();
			mainActions.push( new Action( "Add", new AddIcon(), null, ActionPlacement.ON_BAR ) );
			actions = mainActions;
			
		}

		private function listContextMenuClosed( event:ContextMenuEvent ):void
		{
			__list.contextActions = __standardSet;
			__list.selectionMode = ListSelectionMode.SINGLE;
			__list.selectedIndex = -1;
			__list.removeEventListener(ListEvent.ITEM_CLICKED, onListClick );
		}


		private function listActionSelected( event:ActionEvent ):void
		{

			if( event.action == __editAction )
			{
				onActionSelected( __editAction );
			}
			else if( event.action == __deleteAction || event.action == __tempDeleteAction )
			{
				deleteSelectedItems();
			}
			else if( event.action == __multiselect )
			{
				var selectedIndex:int = __list.selectedIndex;
				__list.selectionMode = ListSelectionMode.MULTIPLE;
				__list.selectedIndex = selectedIndex;
				
				__list.addEventListener(ListEvent.ITEM_CLICKED, onListClick );

				__list.contextActions = __multiSelectSet;
				
				onListClick();
			}
			
		}
		
		private function deleteSelectedItems():void
		{
			if( __list.selectedItems != null )
			{
				for( var i:int = 0; i<__list.selectedItems.length; i++ )
				{
					__list.removeItem( __list.selectedItems[ i ] ); 
				}
			}
		}

		private function onListClick( event:ListEvent = null ):void
		{
			__list.contextMultiSelectText = __list.selectedIndices.length + " Item(s) Selected";
		}
		
		
		override public function onActionSelected( action:ActionBase ):void
		{
			super.onActionSelected( action );
			
			var sheet:AddPage = new AddPage();
			sheet.addEventListener(Event.CANCEL, onCancel );
			sheet.addEventListener(Event.COMPLETE, onComplete );
			
			
			if( __editAction == action )
			{
				__editingItem = __list.selectedItem;
				sheet.setText( __list.selectedItem.label );
			}
			
			pushPage(sheet);
			
		}

		private function onComplete( event:Event ):void
		{
			var sheet:AddPage = event.target as AddPage;
			sheet.removeEventListener(Event.CANCEL, onCancel );
			sheet.removeEventListener(Event.COMPLETE, onComplete );
			
			if( __editingItem == null )
			{
				__list.addItem({label:sheet.getText()} );
			}
			else
			{
				__editingItem.label = sheet.getText();
				__list.updateItem( __editingItem, __editingItem );
				__editingItem = null;
			}
			
			popAndDeletePage();
		}

		private function onCancel( event:Event ):void
		{
			var sheet:AddPage = event.target as AddPage;
			sheet.removeEventListener(Event.CANCEL, onCancel );
			sheet.removeEventListener(Event.COMPLETE, onComplete );
			popAndDeletePage();
			
			__editingItem = null;
		}

	}
}
