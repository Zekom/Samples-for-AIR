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
	import flash.events.IEventDispatcher;
	
	import net.rim.blackberry.push.PushPayload;
	import net.rim.blackberry.pushreceiver.vo.Push;
	import net.rim.blackberry.pushreceiver.vo.PushHistoryItem;
	import net.rim.blackberry.pushreceiver.vo.User;
	
	import qnx.invoke.InvokeRequest;
	
	/**
	 * Offers services related to the registering of a user to receive pushes, the  
	 * handling / processing of pushes, and the unregistering of a user from receiving pushes,
	 * and the handling of a SIM card change.
	 */
	public interface PushNotificationService extends IEventDispatcher
	{
		// Used to initialize the instance of net.rim.blackberry.push.PushService being used
		function initializePushService():void;
		
		// Used to dispose of all push-related resources
		function dispose():void;
		
		// Register-related service functions		
		function getCurrentlyRegisteredUser():User;
		
		function subscribeToPushInitiator(user:User, token:String):void;
		
		function createChannel():void;
		
		function createSession():void;
		
		// Unregister-related service functions		
		function unsubscribeFromPushInitiator(user:User):void;
		
		function destroyChannel():void;
		
		// Push-related service functions
		function extractPushPayload(invokeRequest:InvokeRequest):PushPayload;
		
		function acceptPush(payloadId:String):void;
		
		function rejectPush(payloadId:String):void;
		
		function checkForDuplicatePush(pushHistoryItem:PushHistoryItem):Boolean;
		
		function storePush(push:Push):int;
		
		function deletePush(pushSeqNum:int):void;
		
		function deleteAllPushes():void;
		
		function markPushAsRead(pushSeqNum:int):void;
		
		function markAllPushesAsRead():void;
		
		function getPush(pushSeqNum:int):Push;
		
		function getAllPushes():Array;
		
		function getUnreadPushCount():int;
		
		// SIM-related service functions
		function handleSimChange():void;
		
		// Launch-related service functions
		function registerToLaunch():void;
		
		function unregisterFromLaunch():void;
	}
}