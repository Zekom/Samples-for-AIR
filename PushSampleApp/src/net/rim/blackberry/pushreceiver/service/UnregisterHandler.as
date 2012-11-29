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
	import net.rim.blackberry.pushreceiver.events.UnsubscribeFromPushInitiatorErrorEvent;
	import net.rim.blackberry.pushreceiver.events.UnsubscribeFromPushInitiatorSuccessEvent;
	import net.rim.blackberry.pushreceiver.vo.Configuration;
	import net.rim.blackberry.pushreceiver.vo.User;
	
	public class UnregisterHandler
	{
		private var eventDispatcher:EventDispatcher;
		private var configurationDAO:ConfigurationDAO;
		private var userDAO:UserDAO;
		private var currentUser:User;
		private var hasPushInitiatorErrorAlreadyBeenDispatched:Boolean;
		
		/**
		 * Implements services related to the handling / processing of deregistration.
		 */		
		public function UnregisterHandler(eventDispatcher:EventDispatcher)
		{
			this.eventDispatcher = eventDispatcher;
			
			configurationDAO = new ConfigurationDAOImpl();
			userDAO = new UserDAOImpl();
		}
		
		public function getCurrentlyRegisteredUser():User
		{
			return userDAO.getUser();
		}
		
		public function removeUser():void
		{
			userDAO.removeUser();
		}
		
		public function unsubscribeFromPushInitiator(user:User):void
		{
			hasPushInitiatorErrorAlreadyBeenDispatched = false;
			
			// Keep track of the current user's information
			// If it matches the one stored in the database, then the one in the database
			// will be removed on a success
			currentUser = user;
			
			// This should not be null, since we require config settings to be present
			// before a user can register / unregister
			var config:Configuration = configurationDAO.getConfiguration();
			
			var unsubscribeUrl:String = config.pushInitiatorUrl + "/unsubscribe";
			
			var request:URLRequest = new URLRequest(unsubscribeUrl);
			
			var requestVars:URLVariables = new URLVariables();
			requestVars.appid = escape(config.providerApplicationId);
			requestVars.username = escape(user.userId);
			requestVars.password = escape(user.password);
			
			request.data = requestVars;
			request.method = URLRequestMethod.GET;
			
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
			
			// Add an event listener for a successful HTTP response back from the 
			// unsubscribe servlet of the Push Service SDK
			urlLoader.addEventListener(Event.COMPLETE, loaderCompleteHandler, false, 0, false);
			
			// Add event listeners for handling errors back from the 
			// unsubscribe servlet of the Push Service SDK
			urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler, false, 3, false);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler, false, 2, false);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 1, false);
			
			try {
				urlLoader.load(request);
			} catch(e:Error) {
				hasPushInitiatorErrorAlreadyBeenDispatched = true;
				
				var errorEvent:UnsubscribeFromPushInitiatorErrorEvent = new UnsubscribeFromPushInitiatorErrorEvent(
					UnsubscribeFromPushInitiatorErrorEvent.UNSUBSCRIBE_FROM_PI_ERROR, false, false, e.message, e.errorID);
				eventDispatcher.dispatchEvent(errorEvent);	
			}
		}
		
		private function loaderCompleteHandler(e:Event):void {
			var loader:URLLoader = URLLoader(e.target);
			var returnCode:String = loader.data;
			
			var successEvent:UnsubscribeFromPushInitiatorSuccessEvent;
			var errorEvent:UnsubscribeFromPushInitiatorErrorEvent;
			if (returnCode == "rc=200") {
				// Success!
				var storedUser:User = getCurrentlyRegisteredUser();
				
				if (storedUser && (currentUser.userId == storedUser.userId) && (currentUser.password == storedUser.password)) {
					// Remove the stored user information since the unregister was successful
					userDAO.removeUser();
				}
				
				successEvent = new UnsubscribeFromPushInitiatorSuccessEvent(
					UnsubscribeFromPushInitiatorSuccessEvent.UNSUBSCRIBE_FROM_PI_SUCCESS, false, false);
				eventDispatcher.dispatchEvent(successEvent);
			} else if (returnCode == "rc=10002") {
				errorEvent = new UnsubscribeFromPushInitiatorErrorEvent(
					UnsubscribeFromPushInitiatorErrorEvent.UNSUBSCRIBE_FROM_PI_ERROR, false, false, 
					"Error: The application ID specified in the configuration settings could not be found, "
					+ "or it was found to be inactive or expired.", 10002);
				eventDispatcher.dispatchEvent(errorEvent);	
			} else if (returnCode == "rc=10007") {
				errorEvent = new UnsubscribeFromPushInitiatorErrorEvent(
					UnsubscribeFromPushInitiatorErrorEvent.UNSUBSCRIBE_FROM_PI_ERROR, false, false, 
					"Error: The subscriber (matching the username and password specified) could not be found.", 10007);
				eventDispatcher.dispatchEvent(errorEvent);	
			} else if (returnCode == "rc=10020") {
				errorEvent = new UnsubscribeFromPushInitiatorErrorEvent(
					UnsubscribeFromPushInitiatorErrorEvent.UNSUBSCRIBE_FROM_PI_ERROR, false, false, 
					"Error: The subscriber ID generated by the Push Initiator "
					+ "(based on the username and password specified) was null or empty, longer than 42 "
					+ "characters in length, or matched the 'push_all' keyword.", 10020);
				eventDispatcher.dispatchEvent(errorEvent);	
			} else if (returnCode == "rc=10025") {
				errorEvent = new UnsubscribeFromPushInitiatorErrorEvent(
					UnsubscribeFromPushInitiatorErrorEvent.UNSUBSCRIBE_FROM_PI_ERROR, false, false, 
					"Error: The Push Initiator application has the bypass subscription flag set to true " +
					"(so no unsubscribe is allowed).", 10025);
				eventDispatcher.dispatchEvent(errorEvent);	
			} else if (returnCode == "rc=10026") {
				errorEvent = new UnsubscribeFromPushInitiatorErrorEvent(
					UnsubscribeFromPushInitiatorErrorEvent.UNSUBSCRIBE_FROM_PI_ERROR, false, false, 
					"Error: The username or password specified was incorrect.", 10026);
				eventDispatcher.dispatchEvent(errorEvent);	
			} else if (returnCode == "rc=10027") {
				// Note: You obviously would not want to put an error description like this, but we will to assist with
				// debugging
				errorEvent = new UnsubscribeFromPushInitiatorErrorEvent(
					UnsubscribeFromPushInitiatorErrorEvent.UNSUBSCRIBE_FROM_PI_ERROR, false, false, 
					"Error: A CPSubscriptionFailureException was thrown by the onUnsubscribeSuccess method of the "
					+ "implementation being used of the ContentProviderSubscriptionService interface.", 10027);
				eventDispatcher.dispatchEvent(errorEvent);	
			} else if (returnCode == "rc=-9999") {
				errorEvent = new UnsubscribeFromPushInitiatorErrorEvent(
					UnsubscribeFromPushInitiatorErrorEvent.UNSUBSCRIBE_FROM_PI_ERROR, false, false, 
					"Error: General error (i.e. rc=-9999).", -9999);
				eventDispatcher.dispatchEvent(errorEvent);	
			} else {
				errorEvent = new UnsubscribeFromPushInitiatorErrorEvent(
					UnsubscribeFromPushInitiatorErrorEvent.UNSUBSCRIBE_FROM_PI_ERROR, false, false, 
					"Error: Unknown error code: " + returnCode + ".", -1);
				eventDispatcher.dispatchEvent(errorEvent);	
			}
		}
		
		private function httpStatusHandler(e:HTTPStatusEvent):void
		{
			if (!hasPushInitiatorErrorAlreadyBeenDispatched && e.status != 200) {
				hasPushInitiatorErrorAlreadyBeenDispatched = true;
				
				var errorEvent:UnsubscribeFromPushInitiatorErrorEvent = new UnsubscribeFromPushInitiatorErrorEvent(
					UnsubscribeFromPushInitiatorErrorEvent.UNSUBSCRIBE_FROM_PI_ERROR, false, false, 
					"Error: Invalid HTTP status code: " + e.status + ".", e.status);
				eventDispatcher.dispatchEvent(errorEvent);	
			}
		}
		
		private function securityErrorHandler(e:SecurityErrorEvent):void
		{
			if (!hasPushInitiatorErrorAlreadyBeenDispatched) {
				hasPushInitiatorErrorAlreadyBeenDispatched = true;
				
				var errorEvent:UnsubscribeFromPushInitiatorErrorEvent = new UnsubscribeFromPushInitiatorErrorEvent(
					UnsubscribeFromPushInitiatorErrorEvent.UNSUBSCRIBE_FROM_PI_ERROR, false, false, e.text, e.errorID);
				eventDispatcher.dispatchEvent(errorEvent);	
			}
		}
		
		private function ioErrorHandler(e:IOErrorEvent):void 
		{
			if (!hasPushInitiatorErrorAlreadyBeenDispatched) {
				hasPushInitiatorErrorAlreadyBeenDispatched = true;
				
				var errorEvent:UnsubscribeFromPushInitiatorErrorEvent = new UnsubscribeFromPushInitiatorErrorEvent(
					UnsubscribeFromPushInitiatorErrorEvent.UNSUBSCRIBE_FROM_PI_ERROR, false, false, e.text, e.errorID);
				eventDispatcher.dispatchEvent(errorEvent);
			}
		}
	}
}