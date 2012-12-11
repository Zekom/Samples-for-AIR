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

package net.rim.blackberry.pushreceiver.ui
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import net.rim.blackberry.pushreceiver.ui.renderer.PushRenderer;
	import net.rim.blackberry.pushreceiver.vo.Push;
	
	import qnx.fuse.ui.core.Container;
	import qnx.fuse.ui.events.ListEvent;
	import qnx.fuse.ui.listClasses.ListSelectionMode;
	import qnx.fuse.ui.listClasses.ScrollDirection;
	import qnx.fuse.ui.listClasses.SectionList;
	import qnx.system.FontSettings;
	import qnx.ui.data.SectionDataProvider;
	
	/**
	 * Represents the container view of the list of received push messsages. Provides APIs to manage that list (add, remove, update, etc...)
	 */
	public class ListContainer extends Container
	{
		private static const DATE_HEADING_PADDING:uint = 31;
		private static const PUSH_PADDING:uint = 51;
		
		private static var instance:ListContainer = null;
		
		private var list:SectionList;
		private var sectionDataProvider:SectionDataProvider;
		private var selectedPushItem:PushRenderer;
		
		public function ListContainer()
		{			
			super();
			
			sectionDataProvider = new SectionDataProvider();
			
			list = new SectionList();
			list.setPosition(0, 0);
			list.scrollable = true;
			list.scrollDirection = ScrollDirection.VERTICAL;
			list.dataProvider = sectionDataProvider;
			list.cellRenderer = PushRenderer;
			list.selectionMode = ListSelectionMode.SINGLE;
			list.allowDeselect = false;
			list.addEventListener(ListEvent.ITEM_CLICKED, listItemClicked);
			
			addChild(list);
		}
		
		public static function getListContainer():ListContainer
		{
			if (!instance) {
				instance = new ListContainer();
			}
			
			return instance;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{			
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			list.width = unscaledWidth;
			list.height = unscaledHeight;
			list.columnWidth = unscaledWidth;
			
			list.headerHeight = FontSettings.fontSettings.contentSize + DATE_HEADING_PADDING;
			list.rowHeight = FontSettings.fontSettings.contentSize + PUSH_PADDING;
		}
		
		override public function updateFontSettings():void
		{
			super.updateFontSettings();
			
			list.headerHeight = FontSettings.fontSettings.contentSize + DATE_HEADING_PADDING;
			list.rowHeight = FontSettings.fontSettings.contentSize + PUSH_PADDING;
		}
		
		/**
		 * Selects an item in the push list. 
		 * @param item the item to be selected
		 */
		public function selectItem(item:Object):void
		{
			list.selectedItem = item;	
		}
		
		public function findPushInList(pushSeqNum:int):Push
		{
			for (var i:uint = 0; i < sectionDataProvider.length; i++) {
				var dateHeading:Object = sectionDataProvider.getItemAt(i);
				
				for (var j:uint = 0; j < sectionDataProvider.getChildrenLengthForItem(dateHeading); j++) {
					var push:Push = sectionDataProvider.getChildInItemAt(dateHeading, j) as Push;
					
					if (push.seqNum == pushSeqNum) {
						return push;
					}
				}
			}
			
			return null;
		}
		
		/**
		 * Adds an array of date headings to the push list. 
		 * Each object in the array has a "label" property with the date heading to display. 
		 * @param array the array of date headings
		 */		
		public function addDateHeadings(array:Array):void
		{
			// Hide this message since there will be pushes visible 
			PushReceiver.noPushesLabel.visible = false;
			
			sectionDataProvider.addItemsAt(array, 0);
		}
		
		/**
		 * Adds a push to the push list for the specified date heading.
		 * @param push the push to add
		 * @param dateHeading the date heading the push corresponds to
		 */		
		public function addPushToDateHeading(push:Push, dateHeading:Object):void
		{
			push.dateHeading = dateHeading;
			sectionDataProvider.addChildToItem(push, dateHeading);	
		}
		
		/**
		 * Adds a push item (and possibly a date heading) to the push list. 
		 * @param push the push to be added to the push list
		 */
		public function addPush(push:Push):void
		{			
			var shouldAddDateHeading:Boolean = false;
			
			if (sectionDataProvider.length > 0) {
				var dateHeading:Object = sectionDataProvider.getItemAt(0);
				
				if (push.pushDate == dateHeading.label) {
					// The date of the push matches the existing date heading
					// Add the push to that date heading
					push.dateHeading = dateHeading;
					sectionDataProvider.addChildToItemAtIndex(push, dateHeading, 0);
				} else {
					shouldAddDateHeading = true;
				}
			} else {
				// The push list is currently empty
				shouldAddDateHeading = true;
			}
			
			if (shouldAddDateHeading) {					
				var heading:Object = new Object();
				heading.label = push.pushDate;
	
				sectionDataProvider.addItemAt(heading, 0);
				
				push.dateHeading = heading;
				sectionDataProvider.addChildToItemAtIndex(push, heading, 0);
			}
		}
		
		/**
		 * Updates a push in the push list. 
		 * @param dateHeading the date heading the push belongs to
		 * @param newPush the new push
		 * @param oldPush the push to be replaced
		 */
		public function updatePush(dateHeading:Object, newPush:Push, oldPush:Push):void
		{				
			sectionDataProvider.updateChildInItem(dateHeading, newPush, oldPush);
		}
		
		/**
		 * Removes an item from the push list.
		 */
		public function removeItem():void 
		{		
			var selectedPush:Push = list.selectedItem as Push;
			
			if (sectionDataProvider.getChildrenLengthForItem(selectedPush.dateHeading) == 1) {
				// This is the only push for the date
				sectionDataProvider.removeItem(selectedPush.dateHeading);
			} else {
				sectionDataProvider.removeChildFromItem(selectedPush.dateHeading, selectedPush);
			}
			
			if (sectionDataProvider.length == 0) {
				PushReceiver.noPushesLabel.visible = true;
			}
		}
		
		/**
		 * Removes all the items from the push list.
		 */
		public function removeAll():void
		{
			sectionDataProvider.removeAll();
		}
		
		/**
		 * The actions to take when an item is clicked in the push list.
		 * No actions will be taken on a date heading.
		 * @param e the list event
		 */
		private function listItemClicked(e:ListEvent):void
		{
		    if (e.cell is PushRenderer) {
				selectedPushItem = e.cell as PushRenderer;
				
				// We start a timer so the MouseEvent.CLICK event for the delete 
				// icon has time to execute before checking if it was clicked or not
				var timer:Timer = new Timer(1, 1);
				timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerComplete);
				timer.start();
			}
		}
		
		/**
		 * The actions to take after a timer event.  In this case,
		 * we want to check if the delete icon was clicked and, if not, then
		 * the user wishes to simply open and view the contents of the push.
		 * @param e the timer event
		 */
		private function timerComplete(e:TimerEvent):void {
			if (!selectedPushItem.wasDeleteIconClicked) {
				selectedPushItem.openPush();
			} 
		}
	}
}