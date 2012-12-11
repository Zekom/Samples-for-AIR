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

package
{	
	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import net.rim.blackberry.events.PushServiceErrorEvent;
	import net.rim.blackberry.events.PushServiceEvent;
	import net.rim.blackberry.events.PushTransportReadyEvent;
	import net.rim.blackberry.push.PushPayload;
	import net.rim.blackberry.pushreceiver.events.*;
	import net.rim.blackberry.pushreceiver.service.*;
	import net.rim.blackberry.pushreceiver.ui.ActionBarHelper;
	import net.rim.blackberry.pushreceiver.ui.ListContainer;
	import net.rim.blackberry.pushreceiver.ui.renderer.PushRenderer;
	import net.rim.blackberry.pushreceiver.vo.*;
	
	import qnx.crypto.Base64;
	import qnx.events.InvokeEvent;
	import qnx.fuse.ui.actionbar.ActionBar;
	import qnx.fuse.ui.actionbar.ActionPlacement;
	import qnx.fuse.ui.core.Action;
	import qnx.fuse.ui.core.Container;
	import qnx.fuse.ui.core.SizeOptions;
	import qnx.fuse.ui.dialog.AlertDialog;
	import qnx.fuse.ui.events.ActionEvent;
	import qnx.fuse.ui.layouts.Align;
	import qnx.fuse.ui.layouts.gridLayout.GridData;
	import qnx.fuse.ui.layouts.gridLayout.GridLayout;
	import qnx.fuse.ui.text.Label;
	import qnx.fuse.ui.text.TextFormat;
	import qnx.fuse.ui.text.TextFormatStyle;
	import qnx.fuse.ui.utils.ImageCache;
	import qnx.invoke.InvokeAction;
	import qnx.invoke.InvokeManager;
	import qnx.invoke.InvokeRequest;
	import qnx.notification.Notification;
	import qnx.notification.NotificationManager;
	import qnx.system.FontSettings;

	/**
	 * The main class which handles the construction of all the UI components,
	 * and provides functions for handling an incoming push and a SIM card change.
	 * 
	 * As a push developer you will want to focus on where and how creating a push session happens
	 * and how to handle incoming push messages and SIM card change events.
	 */
	public class PushReceiver extends Sprite
	{
		public static const NOTIFICATION_PREFIX:String = "sample.push.PushReceiver_";
		
		// Label to be displayed when there are no items currently in the list container
		public static var noPushesLabel:Label;
		
		// Shared cache for caching images used by the application
		public static var imageCache:ImageCache;		
		
		// Constant for the invoke target ID for an application open action
		private static const INVOKE_TARGET_ID_OPEN:String = "sample.pushreceiver.invoke.open";
		
		// The max. number of attempts to create the push session before returning an error
		private static const MAX_CREATE_SESSION_FAILURES:uint = 5;
		
		// Tracks the current number of create push session attempts
		private static var numCreateSessionFailures:uint = 0;
		
		// The view (container) holding the list of push items 
		private static var listContainer:ListContainer;
		
		// The service classes
		private static var configService:ConfigurationService = ConfigurationServiceImpl.getConfigurationService();
		private static var pushNotificationService:PushNotificationService = PushNotificationServiceImpl.getPushNotificationService();
		
		// Whether or not the application has at some point in time been running in the foreground
		private static var hasBeenInForeground:Boolean = false;
		
		public function PushReceiver()
		{		
			// Add an event listener to handle incoming invokes
			InvokeManager.invokeManager.addEventListener(InvokeEvent.INVOKE, invokeHandler);
			
			super();
			
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, handleActivate);
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			noPushesLabel = new Label();
			imageCache = new ImageCache();
			listContainer = ListContainer.getListContainer();
			
			// Indicate that we are using the user defined font settings on the device
			FontSettings.fontSettings.useUserSettings = true;
			// Listen for font changes and update the appropriate UI components
			FontSettings.fontSettings.addEventListener(Event.CHANGE, fontSettingsChangeHandler);
			
			// Listen for a SIM card change (and handle it)
			pushNotificationService.addEventListener(PushServiceEvent.SIM_CHANGE, simChange);
			
			// Listen for a push transport ready event (and handle it)
			pushNotificationService.addEventListener(PushTransportReadyEvent.PUSH_TRANSPORT_READY, pushTransportReady);
			
			initializeUI();
			
			// Initialize the push session if a configuration has already been saved
			initializePushSession();
		}
		
		private function handleActivate(e:Event):void
		{
			hasBeenInForeground = true;
		}
		
		/**
		 *  Actions to perform when creating a push session is successful. 
		 * @param e a create session success event
		 */
		public static function createSessionSuccess(e:PushServiceEvent):void
		{
			var config:Configuration = configService.getConfiguration();
			
			// We will just perform these calls here, but won't bother checking
			// to see if they were successful or unsuccessful
			if (config.launchApplicationOnPush) {
				pushNotificationService.registerToLaunch();
			} else {
				pushNotificationService.unregisterFromLaunch();
			}
		}
		
		/**
		 * Actions to perform when creating a push session has failed. 
		 * @param e a create session error event
		 */
		public static function createSessionError(e:PushServiceErrorEvent):void
		{
			numCreateSessionFailures++;
			
			if (numCreateSessionFailures >= MAX_CREATE_SESSION_FAILURES) {				
				// Typically in your own application you wouldn't want to display this error to your users
				var msg:String = "Unable to create push session. (Error code: " + e.errorID + ")";
				if (e.text) {
					msg += " Reason: " + e.text; 					
				}
				
				var alertDialog:AlertDialog = new AlertDialog();
				alertDialog.title = "Push Receiver";
				alertDialog.message = msg;
				alertDialog.addButton("Ok");
				alertDialog.show();
			} else {
				// Try it again (consider using an exponential backoff retry)
				pushNotificationService.createSession();
			}
		}
		
		/**
		 * Updates the list container to have the current list of pushes. 
		 */		
		public static function updateListContainerWithCurrentPushes():void
		{
			var pushes:Array = pushNotificationService.getAllPushes();	
			
			if (pushes) {
				var pushDates:Array = getDateHeadings(pushes);
				
				listContainer.addDateHeadings(pushDates);	
				
				var lastIndex:uint = 0;
				for (var i:uint = 0; i < pushDates.length; i++) {
					var pushDate:String = pushDates[i].label as String;
					
					// Now, add the pushes that have that date
					for (var j:uint = lastIndex; j < pushes.length; j++) {
						var push:Push = pushes[j] as Push;
						
						if (push.pushDate == pushDate) {
							listContainer.addPushToDateHeading(push, pushDates[i]);
						} else {
							lastIndex = j;
							break;
						}
					}
				}
			}
		}
		
		/**
		 * Handles incoming invoke events.  We will just be concerned with push-related invoke events
		 * and ignore all others. 
		 * @param e an invoke event
		 */		
		private function invokeHandler(e:InvokeEvent):void
		{
			if (configService.hasConfiguration()) {
				// The underlying net.rim.blackberry.push.PushService instance might not have been 
				// initialized when an invoke first comes in
				// Make sure that we initialize it here if it hasn't been already
				// It requires an application ID (for consumer applications) so we have to check
				// that configuration settings have already been stored
				pushNotificationService.initializePushService();
				
				var invokeRequest:InvokeRequest = InvokeManager.invokeManager.startupRequest;
				
				if (invokeRequest.action == InvokeAction.PUSH) {
					var pushPayload:PushPayload = pushNotificationService.extractPushPayload(invokeRequest);
					
					pushNotificationHandler(pushPayload);
				} else if (invokeRequest.action == InvokeAction.OPEN) {
					var pushSeqNum:int = invokeRequest.data.readInt();

					pushNotificationService.markPushAsRead(pushSeqNum);
					
					var currentPush:Push = listContainer.findPushInList(pushSeqNum);
					
					var updatedPush:Push = pushNotificationService.getPush(pushSeqNum);
					updatedPush.dateHeading = currentPush.dateHeading;
					
					listContainer.updatePush(currentPush.dateHeading, updatedPush, currentPush);
					
					listContainer.selectItem(updatedPush);
					
					PushRenderer.displayPushDialog(updatedPush);
				}
			}
		}
		
		private function fontSettingsChangeHandler(e:Event):void
		{
			noPushesLabel.updateFontSettings();
			listContainer.updateFontSettings();
		}
		
		/**
		 * Initializes the main UI components.
		 */
		private function initializeUI():void
		{							
			var actionBar:ActionBar = new ActionBar();
			actionBar.showTabsFirstOnBar(false);
			
			var configAction:Action = new Action(ActionBarHelper.CONFIG_ACTION_LABEL, "configicon.png");
			actionBar.addAction(configAction);
			
			var registerAction:Action = new Action(ActionBarHelper.REGISTER_ACTION_LABEL, "registericon.png");
			actionBar.addAction(registerAction);
			
			var unregisterAction:Action = new Action(ActionBarHelper.UNREGISTER_ACTION_LABEL, "unregistericon.png");
			actionBar.addAction(unregisterAction);
			
			var markAllAction:Action = new Action(ActionBarHelper.MARK_ALL_OPEN_ACTION_LABEL, "markallicon.png");
			markAllAction.actionBarPlacement = ActionPlacement.IN_OVERFLOW;
			actionBar.addAction(markAllAction);
			
			var deleteAllAction:Action = new Action(ActionBarHelper.DELETE_ALL_OPEN_ACTION_LABEL, "deleteallicon.png");
			deleteAllAction.actionBarPlacement = ActionPlacement.IN_OVERFLOW;
			actionBar.addAction(deleteAllAction);

			actionBar.y = stage.stageHeight - actionBar.height;		
			actionBar.addEventListener(ActionEvent.ACTION_SELECTED, onActionSelected);
			
			addChild(actionBar);
			
			var noPushesContainer:Container = new Container();
			noPushesContainer.setActualSize(stage.stageWidth, actionBar.y); 
			
			var noPushesGrid:GridLayout = new GridLayout();
			noPushesGrid.verticalPadding = 30;
			noPushesGrid.numColumns = 1;
			noPushesContainer.layout = noPushesGrid;
			
			var noPushesGridData:GridData = new GridData();
			noPushesGridData.hAlign = Align.CENTER;
			noPushesGridData.vAlign = Align.BEGIN;
			noPushesGridData.setOptions(SizeOptions.RESIZE_BOTH);
			noPushesLabel.layoutData = noPushesGridData;
			
			var format:TextFormat = new TextFormat();
			format.style = TextFormatStyle.CONTENT;
			format.bold = true;
			
			noPushesLabel.format = format;
			noPushesLabel.text = "There are currently no pushes.";
			
			noPushesContainer.addChild(noPushesLabel);
			addChild(noPushesContainer);
			
			listContainer.setActualSize(stage.stageWidth, actionBar.y); 

			addChild(listContainer);
			
			updateListContainerWithCurrentPushes();
		}
		
		
		private function onActionSelected(actionEvent:ActionEvent):void
		{     
			if(actionEvent.action.label == ActionBarHelper.CONFIG_ACTION_LABEL) {
				ActionBarHelper.getActionBarHelper().showConfigDialog();
			} else if(actionEvent.action.label == ActionBarHelper.REGISTER_ACTION_LABEL) {
				ActionBarHelper.getActionBarHelper().showRegisterDialog();
			} else if(actionEvent.action.label == ActionBarHelper.UNREGISTER_ACTION_LABEL) {
				ActionBarHelper.getActionBarHelper().showUnregisterDialog();
			} else if(actionEvent.action.label == ActionBarHelper.MARK_ALL_OPEN_ACTION_LABEL) {
				ActionBarHelper.getActionBarHelper().performMarkAllAsOpen();
			} else if(actionEvent.action.label == ActionBarHelper.DELETE_ALL_OPEN_ACTION_LABEL) {
				ActionBarHelper.getActionBarHelper().performDeleteAll();
			}
		}
		
		/**
		 * Initializes the push session if a configuration has already been saved.
		 */
		private function initializePushSession():void
		{
			if (configService.hasConfiguration()) {
				// If the app already has config info saved, just create the session and listen to see if creating a push session was successful or failed
				pushNotificationService.addEventListener(PushServiceEvent.CREATE_SESSION_SUCCESS, createSessionSuccess);
				pushNotificationService.addEventListener(PushServiceErrorEvent.CREATE_SESSION_ERROR, createSessionError);
				
				pushNotificationService.createSession();
			}	
		}
		
		/**
		 * Returns all the different dates for the pushes in the database. 
		 * @param pushes all the pushes in the database
		 * @return the unique dates corresponding to the pushes in the database 
		 */
		private static function getDateHeadings(pushes:Array):Array 
		{
			var pushDates:Array = [];
			
			for (var i:uint = 0; i < pushes.length; i++) {
				var isFound:Boolean = false;
				
				var push:Push = pushes[i] as Push;
				
				for (var j:uint = 0; j < pushDates.length; j++) {
					var pushDate:String = pushDates[j].label as String;
					
					if (pushDate == push.pushDate) {
						isFound = true;
						break;
					}
				}
				
				if (!isFound) {
					var dateHeading:Object = new Object();
					dateHeading.label = push.pushDate;
					
					pushDates.push(dateHeading);
				}
			}
			
			return pushDates;
		}	
		
		/**
		 * Actions to perform after a SIM card change has occurred. 
		 * @param e a SIM card change event
		 */
		private function simChange(e:PushServiceEvent):void
		{
			// Remove the currently registered user (if there is one)
			// and unsubscribe the user from the Push Initiator since
			// switching SIMs might indicate we are dealing with
			// a different user
			pushNotificationService.handleSimChange();
			
			var simChangeDialog:AlertDialog = new AlertDialog();
			simChangeDialog.title = "Push Receiver";
			simChangeDialog.message = "The SIM card was changed and, as a result, the current user has been unregistered. Would you like to re-register?";
			simChangeDialog.addButton("No");
			simChangeDialog.addButton("Yes");
			simChangeDialog.addEventListener(Event.SELECT, simChangeDialogClicked);
			simChangeDialog.show();
		}
		
		/**
		 * Actions to perform after a push transport ready event has occurred.
		 * @param e a push transport ready event
		 */
		private function pushTransportReady(e:PushTransportReadyEvent):void
		{
			var pushTransportReadyDialog:AlertDialog = new AlertDialog();
			pushTransportReadyDialog.title = "Push Receiver";
			pushTransportReadyDialog.addButton("Ok");
			
			var message:String = "The push transport/wireless network/PPG is now available. Please try ";
			
			if (e.lastFailedOperation == PushTransportReadyEvent.CREATE_CHANNEL) {
				message += "registering ";
			} else {
				message += "unregistering ";
			}
			
			message += "again.";
			
			pushTransportReadyDialog.message = message;
			pushTransportReadyDialog.show();
		}
		
		/**
		 * Actions to perform after the SIM change dialog is clicked. 
		 * @param event a dialog event
		 */
		private function simChangeDialogClicked(event:Event):void
		{			
			if (event.target.selectedIndex == 1) {
				// The "Yes" button was clicked, show the register dialog
				ActionBarHelper.getActionBarHelper().showRegisterDialog();
			} 
		}
		
		
		/**
		 * Actions to perform when a new push comes in. 
		 * @param pushPayload a push payload
		 */
		private function pushNotificationHandler(pushPayload:PushPayload):void
		{						
			// Check for a duplicate push
			var pushHistoryItem:PushHistoryItem = new PushHistoryItem();
			pushHistoryItem.itemId = pushPayload.id;
			
			if (pushNotificationService.checkForDuplicatePush(pushHistoryItem)) {
				// A duplicate was found, stop processing. Silently discard this push from the user
				trace("Duplicate push was found with ID: " + pushPayload.id + ".");

				// Exit the application if it has not been brought to the foreground
				if (!hasBeenInForeground) {
					NativeApplication.nativeApplication.exit();
				}
				
				return;
			}
			
			// Hide this message since there will be pushes visible
			noPushesLabel.visible = false;
			
			var contentTypeHeaderVal:String = pushPayload.getHeader("Content-Type");
			var currentTime:Date = new Date();
			
			// Convert from PushPayload to Push so that it can be stored in the database
			var push:Push = new Push();
			push.contentType = getPushContentType(contentTypeHeaderVal);
			push.fileExtension = getPushContentFileExtension(contentTypeHeaderVal);
			push.pushDate = getPushDate(currentTime);
			push.pushTime = getPushTime(currentTime);
			push.content = Base64.encode(pushPayload.data);
			push.unread = true;
			
			// Store the push and set the sequence number (ID) of the push
			push.seqNum = pushNotificationService.storePush(push);
			
			// Add the push to the push list being displayed
			listContainer.addPush(push);
			
			// If an acknowledgement of the push is required (that is, the push was sent as a confirmed push 
			// - which is equivalent terminology to the push being sent with application level reliability),
			// then you must either accept the push or reject the push
			if (pushPayload.isAckRequired) {
				// In our sample, we always accept the push, but situations might arise where an application
				// might want to reject the push (for example, after looking at the headers that came with the push
				// or the data of the push, we might decide that the push received did not match what we expected
				// and so we might want to reject it)
				pushNotificationService.acceptPush(pushPayload.id);
			}
			
			// Add a notification for the push to the BlackBerry Hub
			var notification:Notification = new Notification();
			notification.itemId = NOTIFICATION_PREFIX + push.seqNum;
			notification.title = "Push Receiver";
			notification.subTitle = "New " + push.fileExtension + " push received";
			notification.invokeAction = "bb.action.OPEN";
			notification.invokeTarget = INVOKE_TARGET_ID_OPEN;
			notification.invokeMimeType = "text/plain";
			
			// We set the data of the invoke to be the seqnum of the 
			// push so that we know which push needs to be opened
			var openInvokeData:ByteArray = new ByteArray();
			openInvokeData.writeInt(push.seqNum);
			notification.invokeData = openInvokeData;
			
			NotificationManager.notificationManager.notifyNotification(notification);
			
			// If the "Launch Application on New Push" checkbox was checked in the config settings, then 
			// a new push will launch the app so that it's running in the background (if the app was not 
			// already running when the push came in)
			// In this case, the push launched the app (not the user), so it makes sense 
			// once our processing of the push is done to just exit the app
			// But, if the user has brought the app to the foreground at some point, then they know about the
			// app running and so we leave the app running after we're done processing the push
			if (!hasBeenInForeground) {
		        NativeApplication.nativeApplication.exit();
			}
		}
		
		/**
		 * Retrieves the content type of a push. If the content type header was missing or not recognized a content type of 'text' will be assumed. It
		 * is a best practice to always send a Content-Type header with the push message.
		 *  
		 * @param contentTypeHeaderValue the value of the Content-Type header
		 * @return the content type based on the Content-Type header value
		 */
		private function getPushContentType(contentTypeHeaderValue:String):String
		{
			if(!contentTypeHeaderValue) {
				var alertDialog:AlertDialog = new AlertDialog();
				alertDialog.title = "Push Receiver";
				alertDialog.message = "Error: Missing Content-Type header for push. Defaulting to text.";
				alertDialog.addButton("Ok");
				alertDialog.show();

				return Push.CONTENT_TYPE_TEXT; 
			}
			
			if (contentTypeHeaderValue.indexOf("image") >= 0) {
				return Push.CONTENT_TYPE_IMAGE;
			} else if (contentTypeHeaderValue.match("^text/html") || contentTypeHeaderValue.match("^application/xml")) {
				return Push.CONTENT_TYPE_XML;
			} else {
				return Push.CONTENT_TYPE_TEXT;
			}
		}
		
		/**
		 * Retrieves the file extension of a push. If the content type header was missing or not recognized a file extension of null will be returned. It
		 * is a best practice to always send a Content-Type header with the push message.
		 * 
		 * @param contentTypeHeaderValue the value of the Content-Type header
		 * @return the file extension based on the Content-Type header value 
		 */
		private function getPushContentFileExtension(contentTypeHeaderValue:String):String
		{
			if(!contentTypeHeaderValue) {
				var alertDialog:AlertDialog = new AlertDialog();
				alertDialog.title = "Push Receiver";
				alertDialog.message = "Error: Missing Content-Type header for push. Defaulting to text.";
				alertDialog.addButton("Ok");
				alertDialog.show();
				
				return Push.FILE_EXTENSION_TEXT;
			}
			
			if (contentTypeHeaderValue.match("^application/xml")) {
				return Push.FILE_EXTENSION_XML;
			} else if (contentTypeHeaderValue.match("^text/html")) {
				return Push.FILE_EXTENSION_HTML;
			} else if (contentTypeHeaderValue.match("^image/jpeg")) {
				return Push.FILE_EXTENSION_JPEG;
			} else if (contentTypeHeaderValue.match("^image/gif")) {
				return Push.FILE_EXTENSION_GIF;
			} else if (contentTypeHeaderValue.match("^image/png")) {
				return Push.FILE_EXTENSION_PNG;
			} else if (contentTypeHeaderValue.match("^text/plain")) {
				return Push.FILE_EXTENSION_TEXT;
			} else {
				var alert:AlertDialog = new AlertDialog();
				alert.title = "Push Receiver";
				alert.message = "Error: File extension is unknown for Content-Type header value: " + contentTypeHeaderValue + ".";
				alert.addButton("Ok");
				alert.show();

				return null;
			}
		}
		
		/**
		 * Retrieves the date of a push. 
		 * @param currentTime the current date
		 * @return  the push's date (e.g. Mon, Oct 31, 2011) 
		 */
		private function getPushDate(currentTime:Date):String 
		{
			var dayOfWeek:String = getDayOfWeekText(currentTime.getDay());
			var month:String = getMonthText(currentTime.getMonth());
			var dayOfMonth:Number = currentTime.getDate();
			var year:Number = currentTime.getFullYear();
			
			return dayOfWeek + ", " + month + " " + dayOfMonth + ", " + year;
		}
		
		/**
		 * Retrieves an English abbreviation for the day of the week. 
		 * @param dayOfWeek a day of the week (from 0-5)
		 * @return  a day of the week's English abbreviation
		 * 
		 */
		private function getDayOfWeekText(dayOfWeek:Number):String
		{
			if (dayOfWeek == 0) {
				return "Sun";
			} else if (dayOfWeek == 1) {
				return "Mon";
			} else if (dayOfWeek == 2) {
				return "Tue";
			} else if (dayOfWeek == 3) {
				return "Wed";
			} else if (dayOfWeek == 4) {
				return "Thu";
			} else if (dayOfWeek == 5) {
				return "Fri";
			} else  {
				return "Sat";
			} 
		}
		
		/**
		 * Retrieves an English abbreviation for the month of the year. 
		 * @param month a month (from 0-11) 
		 * @return a month's English abbreviation
		 */
		private function getMonthText(month:Number):String
		{
			if (month == 0) {
				return "Jan";
			} else if (month == 1) {
				return "Feb";
			} else if (month == 2) {
				return "Mar";
			} else if (month == 3) {
				return "Apr";
			} else if (month == 4) {
				return "May";
			} else if (month == 5) {
				return "Jun";
			} else if (month == 6) {
				return "Jul";
			} else if (month == 7) {
				return "Aug";
			} else if (month == 8) {
				return "Sep";
			} else if (month == 9) {
				return "Oct";
			} else if (month == 10) {
				return "Nov";
			} else {
				return "Dec";
			}
		}
		
		/**
		 * Retrieves the time of a push.
		 * @param currentTime the current date
		 * @return the push time using a 12-hour clock (e.g. 2:38p, e.g. 11:22a)
		 */
		private function getPushTime(currentTime:Date):String
		{
			var hours:Number = currentTime.getHours();
			var minutes:String = "" + currentTime.getMinutes();
			var timeOfDay:String = "a";
			
			// We want all minutes less than 10 to add a "0" in front since,
			// for example, 5:8 for a time is incorrect (it should be 5:08)
			if (currentTime.getMinutes() < 10) {
				minutes = "0" + minutes;
			}
			
			if (hours >= 12) {
				timeOfDay = "p";
			}
			
			if (hours >= 13) {
				hours -= 12;
			}
			
			if (hours == 0) {
				hours += 12;
			}
			
			return hours + ":" + minutes + timeOfDay;
		}
	}
}