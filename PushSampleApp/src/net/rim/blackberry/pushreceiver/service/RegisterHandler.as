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
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import net.rim.blackberry.pushreceiver.dao.ConfigurationDAO;
	import net.rim.blackberry.pushreceiver.dao.ConfigurationDAOImpl;
	import net.rim.blackberry.pushreceiver.dao.UserDAO;
	import net.rim.blackberry.pushreceiver.dao.UserDAOImpl;
	import net.rim.blackberry.pushreceiver.events.SubscribeToPushInitiatorErrorEvent;
	import net.rim.blackberry.pushreceiver.events.SubscribeToPushInitiatorSuccessEvent;
	import net.rim.blackberry.pushreceiver.vo.Configuration;
	import net.rim.blackberry.pushreceiver.vo.User;
	
	import qnx.system.Device;
	
	/**
	 * Implements services related to the handling / processing of registration.
	 */
	public class RegisterHandler
	{
		private var eventDispatcher:EventDispatcher;
		private var configurationDAO:ConfigurationDAO;
		private var userDAO:UserDAO;
		private var currentUser:User;
		private var hasPushInitiatorErrorAlreadyBeenDispatched:Boolean;
		
		public function RegisterHandler(eventDispatcher:EventDispatcher)
		{
			this.eventDispatcher = eventDispatcher;
			
			configurationDAO = new ConfigurationDAOImpl();
			userDAO = new UserDAOImpl();
		}
		
		public function subscribeToPushInitiator(user:User, token:String):void
		{
			hasPushInitiatorErrorAlreadyBeenDispatched = false;
			
			// Keep track of the current user's information so it can be stored later
			// on a success
			currentUser = user;
			
			// This should not be null, since we require config settings to be present
			// before a user can register / unregister
			var config:Configuration = configurationDAO.getConfiguration();
			
			var subscribeUrl:String = config.pushInitiatorUrl + "/subscribe";
			
			var request:URLRequest = new URLRequest(subscribeUrl);
			
			var requestVars:URLVariables = new URLVariables();
			requestVars.appid = escape(config.providerApplicationId);
			requestVars.address = token;
			requestVars.osversion = Device.device.scmBundle;
			requestVars.model = Device.device.hardwareID;
			requestVars.username = escape(user.userId);
			requestVars.password = escape(user.password);
			if (config.usingPublicPushProxyGateway) {
				requestVars.type = "public";
			} else {
				requestVars.type = "enterprise";
			}
			request.data = requestVars;
			request.method = URLRequestMethod.GET;
			
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
			
			// Add an event listener for a successful HTTP response back from the 
			// subscribe servlet of the Push Service SDK
			urlLoader.addEventListener(Event.COMPLETE, loaderCompleteHandler, false, 0, false);
			
			// Add event listeners for handling errors back from the 
			// subscribe servlet of the Push Service SDK
			urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler, false, 3, false);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler, false, 2, false);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 1, false);
			
			try {
				urlLoader.load(request);
			} catch(e:Error) {
				hasPushInitiatorErrorAlreadyBeenDispatched = true;
				
				var errorEvent:SubscribeToPushInitiatorErrorEvent = new SubscribeToPushInitiatorErrorEvent(
					SubscribeToPushInitiatorErrorEvent.SUBSCRIBE_TO_PI_ERROR, false, false, e.message, e.errorID);
				eventDispatcher.dispatchEvent(errorEvent);	
			}
		}
		
		private function loaderCompleteHandler(e:Event):void {
			var loader:URLLoader = URLLoader(e.target);
			var returnCode:String = loader.data;
			
			var successEvent:SubscribeToPushInitiatorSuccessEvent;
			var errorEvent:SubscribeToPushInitiatorErrorEvent;
			if (returnCode == "rc=200") {
				// Success!
				// Store the user information
				userDAO.createUserTable();
				userDAO.addOrUpdateUser(currentUser);
				
				successEvent = new SubscribeToPushInitiatorSuccessEvent(
					SubscribeToPushInitiatorSuccessEvent.SUBSCRIBE_TO_PI_SUCCESS, false, false);
				eventDispatcher.dispatchEvent(successEvent);
			} else if (returnCode == "rc=10001") {
				errorEvent = new SubscribeToPushInitiatorErrorEvent(
					SubscribeToPushInitiatorErrorEvent.SUBSCRIBE_TO_PI_ERROR, false, false, 
					"Error: The token from the create channel was null, empty, or longer " +
					"than 40 characters in length.", 10001);
				eventDispatcher.dispatchEvent(errorEvent);	
			} else if (returnCode == "rc=10011") {
				// Note: This error should not occur unless, for some weird reason, the OS version or device model
				// specified in the request parameter is incorrect
				errorEvent = new SubscribeToPushInitiatorErrorEvent(
					SubscribeToPushInitiatorErrorEvent.SUBSCRIBE_TO_PI_ERROR, false, false, 
					"Error: The OS version or device model of the BlackBerry was invalid.", 10011);
				eventDispatcher.dispatchEvent(errorEvent);	
			} else if (returnCode == "rc=10002") {
				errorEvent = new SubscribeToPushInitiatorErrorEvent(
					SubscribeToPushInitiatorErrorEvent.SUBSCRIBE_TO_PI_ERROR, false, false, 
					"Error: The application ID specified in the configuration settings could not be found, or it was found "
					+ "to be inactive or expired.", 10002);
				eventDispatcher.dispatchEvent(errorEvent);	
			} else if (returnCode == "rc=10020") {
				errorEvent = new SubscribeToPushInitiatorErrorEvent(
					SubscribeToPushInitiatorErrorEvent.SUBSCRIBE_TO_PI_ERROR, false, false, 
					"Error: The subscriber ID generated by the Push Initiator "
					+ "(based on the username and password specified) was null or empty, "
					+ "longer than 42 characters in length, or matched the 'push_all' keyword.", 10020);
				eventDispatcher.dispatchEvent(errorEvent);	
			} else if (returnCode == "rc=10025") {
				errorEvent = new SubscribeToPushInitiatorErrorEvent(
					SubscribeToPushInitiatorErrorEvent.SUBSCRIBE_TO_PI_ERROR, false, false, 
					"Error: The Push Initiator application had a type of Enterprise Push " +
					"and had the bypass subscription flag set to true.", 10025);
				eventDispatcher.dispatchEvent(errorEvent);	
			} else if (returnCode == "rc=10026") {
				errorEvent = new SubscribeToPushInitiatorErrorEvent(
					SubscribeToPushInitiatorErrorEvent.SUBSCRIBE_TO_PI_ERROR, false, false, 
					"Error: The username or password specified was incorrect.", 10026);
				eventDispatcher.dispatchEvent(errorEvent);	
			} else if (returnCode == "rc=10027") {
				// Note: You obviously would not want to put an error description like this, but we will to assist with
				// debugging
				errorEvent = new SubscribeToPushInitiatorErrorEvent(
					SubscribeToPushInitiatorErrorEvent.SUBSCRIBE_TO_PI_ERROR, false, false, 
					"Error: A CPSubscriptionFailureException was thrown by the onSubscribeSuccess method of the implementation "
					+ "being used of the ContentProviderSubscriptionService interface.", 10027);
				eventDispatcher.dispatchEvent(errorEvent);	
			} else if (returnCode == "rc=10028") {
				// Note: You obviously would not want to put an error description like this, but we will to assist with
				// debugging
				errorEvent= new SubscribeToPushInitiatorErrorEvent(
					SubscribeToPushInitiatorErrorEvent.SUBSCRIBE_TO_PI_ERROR, false, false, 
					"Error: The type specified was null, empty, or not one of 'public' or 'enterprise'.", 10028);
				eventDispatcher.dispatchEvent(errorEvent);	
			} else if (returnCode == "rc=-9999") {
				errorEvent = new SubscribeToPushInitiatorErrorEvent(
					SubscribeToPushInitiatorErrorEvent.SUBSCRIBE_TO_PI_ERROR, false, false, 
					"Error: General error (i.e. rc=-9999).", -9999);
				eventDispatcher.dispatchEvent(errorEvent);	
			} else {
				errorEvent = new SubscribeToPushInitiatorErrorEvent(
					SubscribeToPushInitiatorErrorEvent.SUBSCRIBE_TO_PI_ERROR, false, false, 
					"Error: Unknown error code: " + returnCode + ".", -1);
				eventDispatcher.dispatchEvent(errorEvent);	
			}
		}
		
		private function httpStatusHandler(e:HTTPStatusEvent):void
		{
			if (!hasPushInitiatorErrorAlreadyBeenDispatched && e.status != 200) {
				hasPushInitiatorErrorAlreadyBeenDispatched = true;
				
				var errorEvent:SubscribeToPushInitiatorErrorEvent = new SubscribeToPushInitiatorErrorEvent(
					SubscribeToPushInitiatorErrorEvent.SUBSCRIBE_TO_PI_ERROR, false, false, 
					"Error: Invalid HTTP status code: " + e.status + ".", e.status);
				eventDispatcher.dispatchEvent(errorEvent);	
			}
		}
		
		private function securityErrorHandler(e:SecurityErrorEvent):void
		{
			if (!hasPushInitiatorErrorAlreadyBeenDispatched) {
				hasPushInitiatorErrorAlreadyBeenDispatched = true;
				
				var errorEvent:SubscribeToPushInitiatorErrorEvent = new SubscribeToPushInitiatorErrorEvent(
					SubscribeToPushInitiatorErrorEvent.SUBSCRIBE_TO_PI_ERROR, false, false, e.text, e.errorID);
				eventDispatcher.dispatchEvent(errorEvent);	
			}
		}
		
		private function ioErrorHandler(e:IOErrorEvent):void 
		{
			if (!hasPushInitiatorErrorAlreadyBeenDispatched) {
				hasPushInitiatorErrorAlreadyBeenDispatched = true;
				
				var errorEvent:SubscribeToPushInitiatorErrorEvent = new SubscribeToPushInitiatorErrorEvent(
					SubscribeToPushInitiatorErrorEvent.SUBSCRIBE_TO_PI_ERROR, false, false, e.text, e.errorID);
				eventDispatcher.dispatchEvent(errorEvent);
			}
		}
	}
}