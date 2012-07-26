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

package net.rim.blackberry.pushreceiver.dao
{
	import net.rim.blackberry.pushreceiver.vo.PushHistoryItem;

	/**
	 * DAO related to the handling / processing items in the push history.
	 * The push history is used to check for potential duplicate pushes being sent.
	 * Any duplicate pushes that are detected will be discarded and not displayed to the user.
	 */
	public interface PushHistoryDAO
	{
		function createPushHistoryTable():void;
		
		function addPushHistoryItem(item:PushHistoryItem):void;
		
		function removeOldestPushHistoryItem():void;
		
		function getPushHistoryItem(pushHistoryItemId:String):PushHistoryItem;
		
		function getPushHistoryCount():int;
	}
}