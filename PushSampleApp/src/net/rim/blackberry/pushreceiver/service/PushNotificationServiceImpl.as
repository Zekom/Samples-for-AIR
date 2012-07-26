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
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import net.rim.blackberry.events.CreateChannelSuccessEvent;
	import net.rim.blackberry.events.PushServiceErrorEvent;
	import net.rim.blackberry.events.PushServiceEvent;
	import net.rim.blackberry.push.InitializationError;
	import net.rim.blackberry.push.PushPayload;
	import net.rim.blackberry.push.PushService;
	import net.rim.blackberry.pushreceiver.dao.UserDAO;
	import net.rim.blackberry.pushreceiver.dao.UserDAOImpl;
	import net.rim.blackberry.pushreceiver.vo.Configuration;
	import net.rim.blackberry.pushreceiver.vo.Push;
	import net.rim.blackberry.pushreceiver.vo.PushHistoryItem;
	import net.rim.blackberry.pushreceiver.vo.User;
	
	import qnx.fuse.ui.dialog.AlertDialog;
	import qnx.invoke.InvokeRequest;
	
	/**
	 * Offers services related to the handling / processing of push messages.
	 * 
	 * As a push developer you will want to focus on the creation of a PushService object and setting listeners for callbacks on it as well as
	 * the create session, create channel, destroy channel APIs.
	 */
	public class PushNotificationServiceImpl extends EventDispatcher implements PushNotificationService
	{
		private static const INVOKE_TARGET_ID:String = "sample.pushreceiver.invoke.target";
		
		private static var instance:PushNotificationService = null;
		private static var pushService:PushService;
		
		private var previousApplicationId:String;
		private var configService:ConfigurationService = ConfigurationServiceImpl.getConfigurationService();
		private var userDAO:UserDAO;
		
		public function PushNotificationServiceImpl()
		{
			super();
			userDAO = new UserDAOImpl();
		}
		
		public static function getPushNotificationService():PushNotificationService
		{
			if (!instance) {
				instance = new PushNotificationServiceImpl();
			}
			
			return instance;
		}
		
		public function dispose():void
		{
			getPushService().dispose();
		}
		
		public function createSession():void
		{
			// Initialize the PushService if it has not been already
			initializePushService();
			
			getPushService().createSession();
		}
		
		public function initializePushService():void
		{
			var config:Configuration = configService.getConfiguration();
			
			if (!pushService || (!previousApplicationId && config.providerApplicationId) || (previousApplicationId && previousApplicationId != config.providerApplicationId)) {
				// If a PushService instance has never been created or if the app id has changed, then create a new PushService instance
				// Important note: App ids would not change in a real application, but this sample application allows this.
				// To allow the app id change, we perform a dispose if there's already an existing PushService instance.
				if (pushService) {
					pushService.dispose();
				}
				
				previousApplicationId = config.providerApplicationId;
				try {
					if (!config.providerApplicationId) {
						pushService = new PushService(INVOKE_TARGET_ID);
					} else {
						pushService = new PushService(INVOKE_TARGET_ID, config.providerApplicationId);
					}
				}
				catch (error:ArgumentError) {
					// Note: As a best practice in your application, you should handle this error gracefully.
					trace("ArgumentError while creating push service: " + error.message + "\r" + error.getStackTrace());
					throw error;
				} catch(error:InitializationError) {
					// Note: Restarting the app or the device itself might help, so we present this information to the user.
					trace("InitializationError while creating push service: " + error.message + "\r" + error.getStackTrace());
					
					showInitializationErrorDialog();
				}
				
				addEventHandlersToPushService();
			}
		}
		
		public function createChannel():void
		{
			// This should not be null, since we require config settings to be present
			// before a user can register / unregister
			var config:Configuration = configService.getConfiguration();
			
			try {
				// For a consumer application, config.ppgUrl will be a non-null value
				// For an enterprise application, config.ppgUrl will be null
				getPushService().createChannel(config.ppgUrl);		
			} catch (error:ArgumentError) {
				trace("ArgumentError while creating channel: " + error.message + ".\r" + error.getStackTrace());
				throw error;
			}		
		}
		
		public function destroyChannel():void
		{
			// This should not be null, since we require config settings to be present
			// before a user can register / unregister
			var config:Configuration = configService.getConfiguration();
			
			getPushService().destroyChannel();
		}
		
		public function handleSimChange():void
		{
			var config:Configuration = configService.getConfiguration();
			var user:User = getCurrentlyRegisteredUser();
			
			if (config.pushInitiatorUrl && user) {
				unsubscribeFromPushInitiator(user);
				
				// Remove the user regardless of whether the unsubscribe is successful or not
				new UnregisterHandler(this).removeUser();
			}
		}
		
		public function registerToLaunch():void
		{
			// This should not be null, since we require config settings to be present
			// before a user can register to launch
			var config:Configuration = configService.getConfiguration();
			
			getPushService().registerToLaunch();
		}
		
		public function unregisterFromLaunch():void
		{
			// This should not be null, since we require config settings to be present
			// before a user can unregister from launch
			var config:Configuration = configService.getConfiguration();
			
			getPushService().unregisterFromLaunch();
		}
		
		public function subscribeToPushInitiator(user:User, token:String):void
		{
			new RegisterHandler(this).subscribeToPushInitiator(user, token);
		}
		
		public function getCurrentlyRegisteredUser():User
		{
			return new UnregisterHandler(this).getCurrentlyRegisteredUser();
		}
		
		public function unsubscribeFromPushInitiator(user:User):void
		{
			new UnregisterHandler(this).unsubscribeFromPushInitiator(user);	
		}
		
		public function extractPushPayload(invokeRequest:InvokeRequest):PushPayload
		{
			try {
			    return getPushService().extractPushPayload(invokeRequest);
			} catch (error:ArgumentError) {
			    trace("ArgumentError while extracting PushPayload: " + error.message + ".\r" + error.getStackTrace());
				throw error;
			}
			
			return null;
		}
		
		public function acceptPush(payloadId:String):void
		{
			getPushService().acceptPush(payloadId);
		}
		
		public function rejectPush(payloadId:String):void
		{
			getPushService().rejectPush(payloadId);
		}
		
		public function checkForDuplicatePush(pushHistoryItem:PushHistoryItem):Boolean
		{
			return new PushHandler().checkForDuplicatePush(pushHistoryItem);
		}
		
		public function storePush(push:Push):int
		{
			return new PushHandler().storePush(push);	
		}
		
		public function deletePush(pushSeqNum:int):void
		{
			new PushHandler().deletePush(pushSeqNum);	
		}
		
		public function deleteAllPushes():void
		{
			new PushHandler().deleteAllPushes();	
		}
		
		public function markPushAsRead(pushSeqNum:int):void
		{
			new PushHandler().markPushAsRead(pushSeqNum);	
		}
		
		public function markAllPushesAsRead():void
		{
			new PushHandler().markAllPushesAsRead();	
		}
		
		public function getPush(pushSeqNum:int):Push
		{
			return new PushHandler().getPush(pushSeqNum);	
		}
		
		public function getAllPushes():Array
		{
			return new PushHandler().getAllPushes();
		}
		
		public function getUnreadPushCount():int
		{
			return new PushHandler().getUnreadPushCount();
		}
		
		private function showInitializationErrorDialog():void
		{
			var alertDialog:AlertDialog = new AlertDialog();
			alertDialog.title = "Initialization Error";
			alertDialog.message = "Error: Could not create push service. Restart app and see if it helps or restart device.";
			alertDialog.addEventListener(Event.SELECT, alertDialogClicked);
			alertDialog.addButton("Ok");
			alertDialog.show();
		}
		
		private function addEventHandlersToPushService():void
		{
			getPushService().addEventListener(PushServiceErrorEvent.CREATE_SESSION_ERROR, errorEventHandler);
			getPushService().addEventListener(PushServiceEvent.CREATE_SESSION_SUCCESS, successEventHandler);
			getPushService().addEventListener(PushServiceErrorEvent.CREATE_CHANNEL_ERROR, errorEventHandler);
			getPushService().addEventListener(CreateChannelSuccessEvent.CREATE_CHANNEL_SUCCESS, createChannelSuccessHandler);
			getPushService().addEventListener(PushServiceErrorEvent.DESTROY_CHANNEL_ERROR, errorEventHandler);
			getPushService().addEventListener(PushServiceEvent.DESTROY_CHANNEL_SUCCESS, successEventHandler);
			getPushService().addEventListener(PushServiceEvent.SIM_CHANGE, successEventHandler);
			getPushService().addEventListener(PushServiceErrorEvent.REGISTER_TO_LAUNCH_ERROR, errorEventHandler);
			getPushService().addEventListener(PushServiceEvent.REGISTER_TO_LAUNCH_SUCCESS, successEventHandler);
			getPushService().addEventListener(PushServiceErrorEvent.UNREGISTER_FROM_LAUNCH_ERROR, errorEventHandler);
			getPushService().addEventListener(PushServiceEvent.UNREGISTER_FROM_LAUNCH_SUCCESS, successEventHandler);
		}
		
		private function getPushService():PushService
		{
			if (pushService) {
				return pushService;
			} else {
				trace("No existing instance of net.rim.blackberry.push.PushService was found to use.");
				throw(new Error("No existing instance of net.rim.blackberry.push.PushService was found to use."));
			}
		}
		
		private function alertDialogClicked(event:Event):void
		{
			NativeApplication.nativeApplication.exit(-1);
		}
		
		private function errorEventHandler(e:PushServiceErrorEvent):void
		{
			var event:PushServiceErrorEvent = new PushServiceErrorEvent(e.type, e.text, e.errorID);
			
			dispatchEvent(event);
		}
		
		private function successEventHandler(e:PushServiceEvent):void
		{
			var event:PushServiceEvent = new PushServiceEvent(e.type);
			
			dispatchEvent(event);
		}
		
		private function createChannelSuccessHandler(e:CreateChannelSuccessEvent):void
		{		
			var event:CreateChannelSuccessEvent = new CreateChannelSuccessEvent(e.type, e.token);
			
			dispatchEvent(event);
		}
	}
}