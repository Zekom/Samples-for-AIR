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
	import flash.events.Event;
	
	import net.rim.blackberry.events.CreateChannelSuccessEvent;
	import net.rim.blackberry.events.PushServiceErrorEvent;
	import net.rim.blackberry.events.PushServiceEvent;
	import net.rim.blackberry.pushreceiver.events.*;
	import net.rim.blackberry.pushreceiver.service.*;
	import net.rim.blackberry.pushreceiver.ui.dialog.ConfigurationDialog;
	import net.rim.blackberry.pushreceiver.ui.dialog.ProgressAlertDialog;
	import net.rim.blackberry.pushreceiver.vo.Configuration;
	import net.rim.blackberry.pushreceiver.vo.User;
	
	import qnx.fuse.ui.dialog.AlertDialog;
	import qnx.fuse.ui.dialog.LoginDialog;
	import qnx.notification.NotificationManager;
	
	/**
	 * Helper class for handling actions involving the action bar.
	 * 
	 * As a push developer, you will want to focus on the code for saving the configuration (create session), registering and unregistering (i.e. create
     * and destroy a push channel) and how to handle the corresponding success and error events. Pay particular attention to the create channel success 
	 * event handling with respect to the token that is returned with that event. 
	 */
	public class ActionBarHelper 
	{
		[Embed(source="/PushReceiver-icon.png")] private static var PUSH_RECEIVER_ICON : Class;
		
		public static var CONFIG_ACTION_LABEL:String = "Config";
		public static var REGISTER_ACTION_LABEL:String = "Register";
		public static var UNREGISTER_ACTION_LABEL:String = "Unregister";
		public static var MARK_ALL_OPEN_ACTION_LABEL:String = "Mark All Open";
		public static var DELETE_ALL_OPEN_ACTION_LABEL:String = "Delete All";
		
		private static var instance:ActionBarHelper = null;
		
		private var configService:ConfigurationService = ConfigurationServiceImpl.getConfigurationService();
		private var pushNotificationService:PushNotificationService = PushNotificationServiceImpl.getPushNotificationService();
		
		private var progressDialog:ProgressAlertDialog;
		private var configDialog:ConfigurationDialog;
		private var registerDialog:LoginDialog;
		private var unregisterDialog:LoginDialog;
		private var eventCompleteDialog:AlertDialog;
						
		private var registerUser:User;
		private var unregisterUser:User;
		
		// Whether a register to launch operation should be attempted
		private var shouldRegisterToLaunch:Boolean;
		// Whether an unregister from launch operation should be attempted
		private var shouldUnregisterFromLaunch:Boolean;
		
		public function ActionBarHelper()
		{
			// Add register events
			pushNotificationService.addEventListener(CreateChannelSuccessEvent.CREATE_CHANNEL_SUCCESS, createChannelSuccess);
			pushNotificationService.addEventListener(PushServiceErrorEvent.CREATE_CHANNEL_ERROR, createChannelError);
			pushNotificationService.addEventListener(SubscribeToPushInitiatorSuccessEvent.SUBSCRIBE_TO_PI_SUCCESS, subscribeToPISuccess);
			pushNotificationService.addEventListener(SubscribeToPushInitiatorErrorEvent.SUBSCRIBE_TO_PI_ERROR, subscribeToPIError);
			
			// Add unregister events
			pushNotificationService.addEventListener(PushServiceEvent.DESTROY_CHANNEL_SUCCESS, destroyChannelSuccess);
			pushNotificationService.addEventListener(PushServiceErrorEvent.DESTROY_CHANNEL_ERROR, destroyChannelError);
			pushNotificationService.addEventListener(UnsubscribeFromPushInitiatorSuccessEvent.UNSUBSCRIBE_FROM_PI_SUCCESS, unsubscribeFromPISuccess);
			pushNotificationService.addEventListener(UnsubscribeFromPushInitiatorErrorEvent.UNSUBSCRIBE_FROM_PI_ERROR, unsubscribeFromPIError);						
		}
		
		public static function getActionBarHelper():ActionBarHelper
		{
			if (!instance) {
				instance = new ActionBarHelper();
			}
			
			return instance;
		}
				
		/**
		 * Actions to perform when unsubscribing from the Push Initiator was a success.
		 * @param e a successful unsubscribe from the Push Initiator event
		 */
		public function unsubscribeFromPISuccess(e:UnsubscribeFromPushInitiatorSuccessEvent):void 
		{
			dialogSuccess("Unregister", "Unregister succeeded.");
		}
		
		/**
		 * Actions to perform when unsubscribing from the Push Initiator has failed.
		 * @param e a failed unsubscribe from the Push Initiator event
		 */
		public function unsubscribeFromPIError(e:UnsubscribeFromPushInitiatorErrorEvent):void
		{			
			var message:String = "Unsubscribe from the Push Initiator failed with error code: " + e.errorID + ".";
			
			dialogError("Unregister", message, e.text);
		}
		
		/**
		 * Displays the register dialog.
		 */
		public function showRegisterDialog():void
		{
			var config:Configuration = configService.getConfiguration();
			
			if (!config) {				
				var alertDialog:AlertDialog = new AlertDialog();
				alertDialog.title = "Push Receiver";
				alertDialog.message = "Please fill in the config before attempting to register.";
				alertDialog.addButton("Ok");
				alertDialog.show();
			} else {
				if (config.pushInitiatorUrl) {
					// The Push Service SDK will be used on the server-side so prompt for a username and password
					registerDialog = getRegisterDialog();
					
					var user:User = pushNotificationService.getCurrentlyRegisteredUser();
					
					// Load the existing user, if it's available
					if (user) {
						registerDialog.username = user.userId;
						registerDialog.password = user.password;
					}
					
					registerDialog.show();	
				} else {
					// No username and password is needed when the 
					// Push Service SDK is not being used on the server-side so
					// Jump straight to creating a push channel
					progressDialog = getProgressDialog("Register", "Creating push channel...");
					progressDialog.show();
					
					pushNotificationService.createChannel();
				}
			}
		}				
		
		/**
		 * Performs an operation which marks all pushes as open/read. 
		 */
		public function performMarkAllAsOpen():void
		{
			// All the pushes have been marked as open/read, so delete all the notifications for the app
			NotificationManager.notificationManager.deleteNotification();
			
			ListContainer.getListContainer().removeAll();
			
			pushNotificationService.markAllPushesAsRead();
			
			PushReceiver.updateListContainerWithCurrentPushes();
		}
		
		/**
		 * Performs an operation which deletes all pushes from the push list
		 * and from the database. 
		 */
		public function performDeleteAll():void
		{			
			var deleteAllDialog:AlertDialog = new AlertDialog();
			deleteAllDialog.title = "Delete All";
			deleteAllDialog.message = "Delete All Items?";
			deleteAllDialog.addButton("Cancel");
			deleteAllDialog.addButton("Delete");
			deleteAllDialog.addEventListener(Event.SELECT, deleteAllDialogClicked);
			deleteAllDialog.show();
		}
		
		/**
		 * Actions to perform when "delete" or "cancel" was clicked on for the "delete all" dialog. 
		 * @param event the event after clicking "delete" or "cancel"
		 */
		private function deleteAllDialogClicked(event:Event):void
		{				
			if (event.target.selectedIndex == 1) {
				// The "Delete" button was clicked
				// All the pushes have been deleted, so delete all the notifications for the app
				NotificationManager.notificationManager.deleteNotification();
				
				pushNotificationService.deleteAllPushes();
				
				ListContainer.getListContainer().removeAll();
				
				PushReceiver.noPushesLabel.visible = true;
			} 
		}
		
		/**
		 * Returns the config dialog. 
		 * @return the config dialog
		 */
		private function getConfigDialog():ConfigurationDialog
		{
			var dialog:ConfigurationDialog = new ConfigurationDialog();
			dialog.title = "Configuration";
			dialog.addButton("Cancel");
			dialog.addButton("Save");
			dialog.addEventListener(ConfigurationDialogEvent.BUTTON_CLICKED, configDialogClicked);
			
			return dialog;
		}
		
		/**
		 * Returns the register dialog.
		 * @return the register dialog
		 */
		private function getRegisterDialog():LoginDialog
		{			
			var dialog:LoginDialog = new LoginDialog();
			dialog.title = "Register";
			dialog.usernamePrompt = "Username"; 
			dialog.passwordPrompt = "Password";
			dialog.addButton("Cancel");
			dialog.addButton("Register");
			dialog.addEventListener(Event.SELECT, registerDialogClicked);	
			
			return dialog;
		}
		
		/**
		 * Returns the unregister dialog.
		 * @return the unregister dialog
		 */
		private function getUnregisterDialog():LoginDialog
		{			
			var dialog:LoginDialog = new LoginDialog();
			dialog.title = "Unregister";
			dialog.usernamePrompt = "Username"; 
			dialog.passwordPrompt = "Password";
			dialog.addButton("Cancel");
			dialog.addButton("Unregister");
			dialog.addEventListener(Event.SELECT, unregisterDialogClicked);	
			
			return dialog;
		}
		
		/**
		 * Returns the progress dialog (which indicates the progress of registering / unregistering). 
		 * @param title the title of the progress dialog
		 * @param progress the current progress message
		 * @return the progress dialog
		 */
		private function getProgressDialog(title:String, progress:String):ProgressAlertDialog
		{
			var dialog:ProgressAlertDialog = new ProgressAlertDialog();
			dialog.title = title;
			dialog.progressAlertMessage = progress;
			
			return dialog;
		}
		
		/**
		 * Returns the dialog which indicates that an operation is complete. 
		 * @param title the title of the dialog
		 * @param message the message to be displayed when the operation is complete
		 * @return  the event complete dialog 
		 */
		private function getEventCompleteDialog(title:String, message:String):AlertDialog
		{			
			var dialog:AlertDialog = new AlertDialog();
			dialog.title = title;
			dialog.message = message;
			dialog.addButton("Ok");
			
			return dialog;
		}
		
		/**
		 * Displays the config dialog. 
		 */
		public function showConfigDialog():void
		{                    
			configDialog = getConfigDialog();
			
			var config:Configuration = configService.getConfiguration();
			
			// Load the existing configuration, if it's available
			if (config) {
				configDialog.launchApplicationOnPush = config.launchApplicationOnPush;
				
				if (config.pushInitiatorUrl) {
					configDialog.pushInitiatorUrlEditable = true;
					configDialog.useSDKAsPushInitiator = true;
					configDialog.pushInitiatorUrl = config.pushInitiatorUrl;      
				} else {
					configDialog.pushInitiatorUrlEditable = false;
					configDialog.useSDKAsPushInitiator = false;
				}
				
				if (config.usingPublicPushProxyGateway) {
					// Consumer application
					configDialog.selectPublicPushProxyGatewayRadioButton();
					configDialog.providerApplicationIdEditable = true;
					configDialog.pushProxyGatewayUrlEditable = true;
					configDialog.providerApplicationId = config.providerApplicationId;
					configDialog.pushProxyGatewayUrl = config.ppgUrl;
				} else {
					// Enterprise application
					configDialog.selectEnterprisePushProxyGatewayRadioButton();
					configDialog.pushProxyGatewayUrlEditable = false;
					configDialog.pushProxyGatewayUrl = null;
					
					if (config.pushInitiatorUrl) {
						configDialog.providerApplicationIdEditable = true;
						configDialog.providerApplicationId = config.providerApplicationId;
					} else {
						configDialog.providerApplicationIdEditable = false;
						configDialog.providerApplicationId = null;
					}
				}
			} else {
				// No configuration was found in the database
				configDialog.selectPublicPushProxyGatewayRadioButton();
				configDialog.useSDKAsPushInitiator = true;
				configDialog.providerApplicationIdEditable = true;
				configDialog.pushProxyGatewayUrlEditable = true;
				configDialog.pushInitiatorUrlEditable = true;
				configDialog.launchApplicationOnPush = false;
			}
			
			configDialog.show();
		}

		
		/**
		 * Displays the unregister dialog.
		 */
		public function showUnregisterDialog():void
		{
			var config:Configuration = configService.getConfiguration();
			
			if (!config) {				
				var alertDialog:AlertDialog = new AlertDialog();
				alertDialog.title = "Push Receiver";
				alertDialog.message = "Please fill in the config before attempting to unregister.";
				alertDialog.addButton("Ok");
				alertDialog.show();
			} else {				
				if (config.pushInitiatorUrl) {
					// The Push Service SDK will be used
					unregisterDialog = getUnregisterDialog();
					
					var user:User = pushNotificationService.getCurrentlyRegisteredUser();
					
					// Load the existing user, if it's available
					if (user) {
						unregisterDialog.username = user.userId;
						unregisterDialog.password = user.password;
					}
					
					unregisterDialog.show();	
				} else {
					// No username and password is needed when the 
					// Push Service SDK is not being used
					// Jump straight to destroying a push channel
					progressDialog = getProgressDialog("Unregister", "Destroying push channel...");
					progressDialog.show();
					
					pushNotificationService.destroyChannel();
				}
			}	
		}
												
		/**
		 * Actions to perform when "save" or "cancel" was clicked on for the config dialog. 
		 * @param event a configuration dialog event
		 */
		private function configDialogClicked(event:ConfigurationDialogEvent):void
		{					
			if (event.target.selectedIndex == 1) {
				// The "Save" button was clicked
				
				// Trim the entered values
				event.providerApplicationId = trim(event.providerApplicationId);
				event.pushProxyGatewayUrl = trim(event.pushProxyGatewayUrl);
				event.pushInitiatorUrl = trim(event.pushInitiatorUrl);
				
				configDialog = getConfigDialog();
				
				var messageStr:String;
				if ((event.usingPublicPushProxyGateway || event.useSDKAsPushInitiator) && !event.providerApplicationId) {
					messageStr = "Please specify an Application ID.";
					initializeConfigDialogAfterError(event);
					configDialog.errorText = messageStr;
					configDialog.show();
				} else if ((event.usingPublicPushProxyGateway || event.useSDKAsPushInitiator) && event.providerApplicationId.indexOf("||") != -1) {
					messageStr = "Application ID is not allowed to contain '||'.";
					initializeConfigDialogAfterError(event);
					configDialog.errorText = messageStr;
					configDialog.show();
				} else if (event.usingPublicPushProxyGateway && !event.pushProxyGatewayUrl) {
					messageStr = "Please specify a PPG URL.";
					initializeConfigDialogAfterError(event);
					configDialog.errorText = messageStr;
					configDialog.show();
				} else if (event.usingPublicPushProxyGateway && !event.pushProxyGatewayUrl.match("^http://")) {
					messageStr = "PPG URL must start with http://.";
					initializeConfigDialogAfterError(event);
					configDialog.errorText = messageStr;
					configDialog.show();
				} else if (event.usingPublicPushProxyGateway && event.pushProxyGatewayUrl.match("/$")) {
					messageStr = "PPG URL should not end with a /. One will be automatically added.";
					initializeConfigDialogAfterError(event);
					configDialog.errorText = messageStr;
					configDialog.show();					
				} else if (event.useSDKAsPushInitiator && !event.pushInitiatorUrl) {
					messageStr = "Please specify a Push Initiator URL.";
					initializeConfigDialogAfterError(event);
					configDialog.pushInitiatorUrl = "";
					configDialog.errorText = messageStr;
					configDialog.show();
				}  else if (event.useSDKAsPushInitiator && !event.pushInitiatorUrl.match("^http://") && !event.pushInitiatorUrl.match("^https://")) {
					messageStr = "Push Initiator URL must start with http:// or https://.";
					initializeConfigDialogAfterError(event);
					configDialog.errorText = messageStr;
					configDialog.show();
				} else if (event.useSDKAsPushInitiator && event.pushInitiatorUrl.match("/$")) {
					messageStr = "Push Initiator URL should not end with a /. One will be automatically added.";
					initializeConfigDialogAfterError(event);
					configDialog.errorText = messageStr;
					configDialog.show();
				} else {
					progressDialog = getProgressDialog("Configuration", "Storing configuration...");
					progressDialog.show();
					
					storeConfiguration(event);
				}
			}				
		}
		
		/**
		 * Initializes the config dialog after a validation error has occurred.
		 * @param event a configuration dialog event
		 */		
		private function initializeConfigDialogAfterError(event:ConfigurationDialogEvent):void
		{
			configDialog.useSDKAsPushInitiator = event.useSDKAsPushInitiator;
			configDialog.providerApplicationId = event.providerApplicationId;
			configDialog.pushProxyGatewayUrl = event.pushProxyGatewayUrl;
			configDialog.pushInitiatorUrl = event.pushInitiatorUrl;
			configDialog.launchApplicationOnPush = event.launchApplicationOnPush;
			
			if (event.usingPublicPushProxyGateway) {
				// Consumer application
				configDialog.selectPublicPushProxyGatewayRadioButton();
				configDialog.providerApplicationIdEditable = true;
				configDialog.pushProxyGatewayUrlEditable = true;
			} else {
				// Enterprise application
				configDialog.selectEnterprisePushProxyGatewayRadioButton();
				configDialog.pushProxyGatewayUrlEditable = false;
				
				if (event.useSDKAsPushInitiator) {
					configDialog.providerApplicationIdEditable = true;
				} else {
					configDialog.providerApplicationIdEditable = false;
				}
			}
			
			if (event.useSDKAsPushInitiator) {
				configDialog.pushInitiatorUrlEditable = true;
			} else {
				configDialog.pushInitiatorUrlEditable = false;
			}
		}
		
		/**
		 * Stores the config settings to the database. 
		 * @param event a configuration dialog event containing configuration settings
		 */
		private function storeConfiguration(event:ConfigurationDialogEvent):void 
		{
			// First, load the previous configuration so we can determine whether or not to register to launch
			// or unregister from launch
			var storedConfig:Configuration = configService.getConfiguration();
			if (storedConfig) {
				if (!storedConfig.launchApplicationOnPush && event.launchApplicationOnPush) {
					shouldRegisterToLaunch = true;
					shouldUnregisterFromLaunch = false;
				} else if (storedConfig.launchApplicationOnPush && !event.launchApplicationOnPush) {
					shouldRegisterToLaunch = false;
					shouldUnregisterFromLaunch = true;
				} else {
					shouldRegisterToLaunch = false;
					shouldUnregisterFromLaunch = false;
				}
			} else {
				shouldRegisterToLaunch = event.launchApplicationOnPush;
				// There is no configuration currently stored, so register to launch was never previously called
				// so we wouldn't need to call unregister
				shouldUnregisterFromLaunch = false;
			}
			
			// Store the configuration
			var config:Configuration = new Configuration();
			config.usingPublicPushProxyGateway = event.usingPublicPushProxyGateway;
			config.providerApplicationId = event.providerApplicationId;
			config.ppgUrl = event.pushProxyGatewayUrl;
			config.launchApplicationOnPush = event.launchApplicationOnPush;
			config.pushInitiatorUrl = event.pushInitiatorUrl;
			
			configService.storeConfiguration(config);
			
			// Now that the configuration settings are stored, we can create a push session
			// Listen to see if it was successful or failed
			pushNotificationService.removeEventListener(PushServiceEvent.CREATE_SESSION_SUCCESS, PushReceiver.createSessionSuccess);
			pushNotificationService.removeEventListener(PushServiceErrorEvent.CREATE_SESSION_ERROR, PushReceiver.createSessionError);
			
			pushNotificationService.addEventListener(PushServiceEvent.CREATE_SESSION_SUCCESS, createSessionSuccess);
			pushNotificationService.addEventListener(PushServiceErrorEvent.CREATE_SESSION_ERROR, createSessionError);
			
			pushNotificationService.createSession();	
		}
		
		/**
		 *  Actions to perform when creating a push session is successful. 
		 * @param e a create session success event
		 */
		private function createSessionSuccess(e:PushServiceEvent):void
		{	
			// Add register to launch / unregister to launch events
			if ((shouldRegisterToLaunch || shouldUnregisterFromLaunch) && !pushNotificationService.hasEventListener(PushServiceEvent.REGISTER_TO_LAUNCH_SUCCESS)) {
				// Only add these event listeners once
				pushNotificationService.addEventListener(PushServiceEvent.REGISTER_TO_LAUNCH_SUCCESS, registerToLaunchSuccess);
				pushNotificationService.addEventListener(PushServiceErrorEvent.REGISTER_TO_LAUNCH_ERROR, registerToLaunchError);
				pushNotificationService.addEventListener(PushServiceEvent.UNREGISTER_FROM_LAUNCH_SUCCESS, unregisterFromLaunchSuccess);
				pushNotificationService.addEventListener(PushServiceErrorEvent.UNREGISTER_FROM_LAUNCH_ERROR, unregisterFromLaunchError);
			}
			
			if (shouldRegisterToLaunch) {
				pushNotificationService.registerToLaunch();
			} else if (shouldUnregisterFromLaunch) {
				pushNotificationService.unregisterFromLaunch();
			} else {
				dialogSuccess("Configuration", "Configuration was saved. Please register now.");						
			}
		}
		
		/**
		 * Actions to perform when creating a push session has failed. 
		 * @param e a create session error event
		 */
		private function createSessionError(e:PushServiceErrorEvent):void
		{			
			// Typically in your own application you wouldn't want to display this error to your users
			var message:String = "Configuration was saved, but was unable to create push session. (Error code: " + e.errorID + ")";
			
			dialogError("Configuration", message, e.text);
		}
		
		/**
		 *  Actions to perform when registering to launch is successful. 
		 * @param e a register to launch success event
		 */
		private function registerToLaunchSuccess(e:PushServiceEvent):void
		{			
			dialogSuccess("Configuration", "Configuration was saved. Please register now.");	
		}
		
		/**
		 * Actions to perform when registering to launch has failed. 
		 * @param e a register to launch error event
		 */
		private function registerToLaunchError(e:PushServiceErrorEvent):void
		{
			// Typically in your own application you wouldn't want to display this error to your users
			var message:String = "Register to launch failed with error code: " + e.errorID + ".";
			
			dialogError("Configuration", message, e.text);
		}
		
		/**
		 *  Actions to perform when unregistering from launch is successful. 
		 * @param e an unregister from launch success event
		 */
		private function unregisterFromLaunchSuccess(e:PushServiceEvent):void
		{
			dialogSuccess("Configuration", "Configuration was saved. Please register now.");	
		}
		
		/**
		 * Actions to perform when unregistering from launch has failed. 
		 * @param e an unregister from launch error event
		 */
		private function unregisterFromLaunchError(e:PushServiceErrorEvent):void
		{
			// Typically in your own application you wouldn't want to display this error to your users
			var message:String = "Unregister from launch failed with error code: " + e.errorID + ".";
			
			dialogError("Configuration", message, e.text);
		}
		
		/**
		 * Actions to perform when "register" or "cancel" was clicked on for the register dialog. 
		 * @param event the event after clicking "register" or "cancel"
		 */
		private function registerDialogClicked(event:Event):void
		{						
			if (event.target.selectedIndex == 1) {
				// The "Register" button was clicked				
				// Trim the entered values
				var username:String = trim(event.target.username);
				var password:String = trim(event.target.password);
				
				registerDialog = getRegisterDialog();
				
				var messageStr:String;
				if (!username) {
					messageStr = "Please specify a username.";
					registerDialog.password = password;
					registerDialog.errorText = messageStr;
					registerDialog.show();
				} else if (!password) {
					messageStr = "Please specify a password.";
					registerDialog.username = username;
					registerDialog.errorText = messageStr;
					registerDialog.show();
				} else {					
					registerUser = new User();
					registerUser.userId = username;
					registerUser.password = password;
					
					// Now, attempt to create a push channel
					progressDialog = getProgressDialog("Register", "Creating push channel...");
					progressDialog.show();
					
					pushNotificationService.createChannel();
				}
			}
		}
		
		/**
		 * Actions to perform when creating a push channel was a success. 
		 * 
		 * @param e a create channel success event
		 */
		private function createChannelSuccess(e:CreateChannelSuccessEvent):void
		{
			var config:Configuration = configService.getConfiguration();
			
			if (config.pushInitiatorUrl) {
				// The Push Service SDK will be used to subscribe to the Push Initiator's server-side application since a 
				// Push Initiator URL was specified
				progressDialog.cancel();
				
				// Now, attempt to subscribe to the Push Initiator
				progressDialog = getProgressDialog("Register", "Subscribing to Push Initiator...");
				progressDialog.show();
				
				// This is very important: the token returned in the create channel success event is what
				// the Push Initiator should use when initiating a push to the BlackBerry Push Service.
				// This token must be communicated back to the Push Initiator's server-side application.
				pushNotificationService.subscribeToPushInitiator(registerUser, e.token);
			} else {				
				subscribeToPISuccess(new SubscribeToPushInitiatorSuccessEvent(SubscribeToPushInitiatorSuccessEvent.SUBSCRIBE_TO_PI_SUCCESS));
			}
		}
		
		/**
		 * Actions to perform when creating a push channel has failed.
		 * @param e a create channel fail event
		 */
		private function createChannelError(e:PushServiceErrorEvent):void
		{
			var message:String;
			if (e.errorID == PushServiceErrorEvent.PUSH_TRANSPORT_UNAVAILABLE) {
				message = "Create channel failed as the push transport is unavailable. " +
					"Verify your mobile network and/or Wi-Fi are turned on. " +
					"If they are on, you will be notified when the push transport is available again.";
			} else if (e.errorID == PushServiceErrorEvent.PPG_SERVER_ERROR) {
				message = "Create channel failed as the PPG is currently returning a server error. " +
					"You will be notified when the PPG is available again.";				
			} else {
				// Typically in your own application you wouldn't want to display this error to your users
				message = "Create channel failed with error code: " + e.errorID + ".";	
			}
			
			dialogError("Register", message, e.text);
		}
		
		/**
		 * Actions to perform when subscribing to the Push Initiator was a success. 
		 * @param e a successful subscribe to the Push Initiator event
		 */
		private function subscribeToPISuccess(e:SubscribeToPushInitiatorSuccessEvent):void 
		{
			dialogSuccess("Register", "Registration succeeded.");
		}
		
		/**
		 * Actions to perform when subscribing to the Push Initiator has failed.
		 * @param e a failed subscribe to the Push Initiator event
		 */
		private function subscribeToPIError(e:SubscribeToPushInitiatorErrorEvent):void
		{			
			// Typically in your own application you wouldn't want to display this error to your users
			var message:String = "Subscribe to the Push Initiator failed with error code: " + e.errorID + ".";
			
			dialogError("Register", message, e.text);
		}
		
		/**
		 * Actions to perform when "unregister" or "cancel" was clicked on for the unregister dialog.
		 * @param event the event after clicking "unregister" or "cancel"
		 */
		private function unregisterDialogClicked(event:Event):void
		{						
			if (event.target.selectedIndex == 1) {
				// The "Unregister" button was clicked
				// Trim the entered values
				var username:String = trim(event.target.username);
				var password:String = trim(event.target.password);
				
				unregisterDialog = getUnregisterDialog();
				
				var messageStr:String;
				if (!username) {
					messageStr = "Please specify a username.";
					unregisterDialog.password = password;
					unregisterDialog.errorText = messageStr;
					unregisterDialog.show();
				} else if (!password) {
					messageStr = "Please specify a password.";
					unregisterDialog.username = username;
					unregisterDialog.errorText = messageStr;
					unregisterDialog.show();
				} else {
					unregisterUser = new User();
					unregisterUser.userId = username;
					unregisterUser.password = password;
					
					// Now, attempt to destroy a push channel
					progressDialog = getProgressDialog("Unregister", "Destroying push channel...");
					progressDialog.show();
					
					pushNotificationService.destroyChannel();
				}
			}
		}
		
		/**
		 * Actions to perform when destroying a push channel was a success.
		 * @param e a a destroy channel success event
		 */
		private function destroyChannelSuccess(e:PushServiceEvent):void
		{
			var config:Configuration = configService.getConfiguration();
			
			if (config.pushInitiatorUrl) {
				// The Push Service SDK will be used to unsubscribe to the Push Initiator's server-side application since a 
				// Push Initiator URL was specified
				progressDialog.cancel();
				
				progressDialog = getProgressDialog("Unregister", "Unsubscribing from Push Initiator...");
				progressDialog.show();
				
				// Now, attempt to unsubscribe from the Push Initiator
				pushNotificationService.unsubscribeFromPushInitiator(unregisterUser);
			} else {
				unsubscribeFromPISuccess(new UnsubscribeFromPushInitiatorSuccessEvent(UnsubscribeFromPushInitiatorSuccessEvent.UNSUBSCRIBE_FROM_PI_SUCCESS));
			}
		}
		
		/**
		 * Actions to perform when destroying a push channel has failed.
		 * @param e a destroy channel fail event
		 */
		private function destroyChannelError(e:PushServiceErrorEvent):void
		{			
			var message:String;
			if (e.errorID == PushServiceErrorEvent.PUSH_TRANSPORT_UNAVAILABLE) {
				message = "Destroy channel failed as the push transport is unavailable. " +
					"Verify your mobile network and/or Wi-Fi are turned on. " +
					"If they are on, you will be notified when the push transport is available again.";
			} else if (e.errorID == PushServiceErrorEvent.PPG_SERVER_ERROR) {
				message = "Destroy channel failed as the PPG is currently returning a server error. " +
					"You will be notified when the PPG is available again.";				
			} else {
				// Typically in your own application you wouldn't want to display this error to your users
				message = "Destroy channel failed with error code: " + e.errorID + ".";
			}
			
			dialogError("Unregister", message, e.text);
		}
		
		/**
		 * Called after a successful dialog operation. 
		 * @param title the title on a success
		 * @param message the message on a success
		 */
		private function dialogSuccess(title:String, message:String):void
		{
			progressDialog.cancel();
			
			eventCompleteDialog = getEventCompleteDialog(title, message);
			eventCompleteDialog.show();
		}
		
		/**
		 * Called after a dialog operation has failed.
		 * @param title the title on a failure
		 * @param errorMsg the error message to present to the user
		 * @param errorDescription the error description back from the Push APIs (if one exists)
		 */		
		private function dialogError(title:String, errorMsg:String, errorDescription:String):void
		{
			progressDialog.cancel();
			
			var message:String = errorMsg;
			if (errorDescription) {
				message += " Reason: " + errorDescription;
			}
			
			eventCompleteDialog = getEventCompleteDialog(title, message);
			eventCompleteDialog.show();			
		}
						
		/**
		 * Trims away white space from a string. 
		 * @param s the string to be trimmed
		 * @return the string with white space removed
		 */
		private function trim(s:String):String
		{
			if (s) {
				return s.replace(/^([\s|\t|\n]+)?(.*)([\s|\t|\n]+)?$/gm, "$2");
			} 
			
			return null;
		}			
	}
}