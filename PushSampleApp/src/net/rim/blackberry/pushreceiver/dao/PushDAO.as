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
	import net.rim.blackberry.pushreceiver.vo.Push;
	
	/**
	 * DAO related to the handling / processing of pushes.
	 */
	public interface PushDAO
	{
		function createPushTable():void;
		
		function addPush(push:Push):int;
		
		function removePush(pushSeqNum:int):void;
		
		function removeAllPushes():void;
		
		function markPushAsRead(pushSeqNum:int):void;
		
		function markAllPushesAsRead():void;
		
		function getPush(pushSeqNum:int):Push;
		
		function getAllPushes():Array;
		
		function getUnreadPushCount():int;
	}
}