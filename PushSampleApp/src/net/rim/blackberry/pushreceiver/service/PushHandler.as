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

package net.rim.blackberry.pushreceiver.service
{
	import net.rim.blackberry.pushreceiver.dao.PushDAO;
	import net.rim.blackberry.pushreceiver.dao.PushDAOImpl;
	import net.rim.blackberry.pushreceiver.dao.PushHistoryDAO;
	import net.rim.blackberry.pushreceiver.dao.PushHistoryDAOImpl;
	import net.rim.blackberry.pushreceiver.vo.Push;
	import net.rim.blackberry.pushreceiver.vo.PushHistoryItem;
	
	/**
	 * Implements services related to the handling / processing of push messages.
	 */
	public class PushHandler
	{
		private var pushHistoryDAO:PushHistoryDAO;
		private var pushDAO:PushDAO;
		
		public function PushHandler()
		{
			pushHistoryDAO = new PushHistoryDAOImpl();
			pushDAO = new PushDAOImpl();
		}
		
		public function checkForDuplicatePush(pushHistoryItem:PushHistoryItem):Boolean
		{
			if (!pushHistoryItem || !pushHistoryItem.itemId) {
				return false;
			}
			
			pushHistoryDAO.createPushHistoryTable();
			
			var storedPushHistoryItem:PushHistoryItem = pushHistoryDAO.getPushHistoryItem(pushHistoryItem.itemId);
			
			if (storedPushHistoryItem) {
				return true;
			}
			
			pushHistoryDAO.addPushHistoryItem(pushHistoryItem);
			
			var count:int = pushHistoryDAO.getPushHistoryCount();
			
			if (count > 10) {
				pushHistoryDAO.removeOldestPushHistoryItem();
			}
			
			return false;
		}
		
		public function storePush(push:Push):int
		{
			pushDAO.createPushTable();
			
			return pushDAO.addPush(push);	
		}
		
		public function deletePush(pushSeqNum:int):void 
		{
			pushDAO.removePush(pushSeqNum);
		}
		
		public function deleteAllPushes():void
		{
			pushDAO.removeAllPushes();
		}
		
		public function markPushAsRead(pushSeqNum:int):void
		{
			pushDAO.markPushAsRead(pushSeqNum);	
		}
		
		public function markAllPushesAsRead():void 
		{
			pushDAO.markAllPushesAsRead();
		}
		
		public function getPush(pushSeqNum:int):Push
		{
			return pushDAO.getPush(pushSeqNum);	
		}
		
		public function getAllPushes():Array
		{
			return pushDAO.getAllPushes();
		}
		
		public function getUnreadPushCount():int 
		{
			return pushDAO.getUnreadPushCount();
		}
	}
}