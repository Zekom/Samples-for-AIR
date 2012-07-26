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

package net.rim.blackberry.pushreceiver.ui.renderer
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.ByteArray;
	
	import net.rim.blackberry.pushreceiver.service.PushNotificationService;
	import net.rim.blackberry.pushreceiver.service.PushNotificationServiceImpl;
	import net.rim.blackberry.pushreceiver.ui.ListContainer;
	import net.rim.blackberry.pushreceiver.ui.dialog.HtmlContentDialog;
	import net.rim.blackberry.pushreceiver.ui.dialog.PushContentDialog;
	import net.rim.blackberry.pushreceiver.vo.Push;
	
	import qnx.crypto.Base64;
	import qnx.fuse.ui.dialog.AlertDialog;
	import qnx.fuse.ui.display.Image;
	import qnx.fuse.ui.events.TextEvent;
	import qnx.fuse.ui.layouts.Align;
	import qnx.fuse.ui.listClasses.CellRenderer;
	import qnx.fuse.ui.skins.SkinStates;
	import qnx.fuse.ui.text.Label;
	import qnx.fuse.ui.text.TextFormat;
	import qnx.fuse.ui.text.TextFormatStyle;
	import qnx.fuse.ui.text.TextTruncationMode;
	import qnx.fuse.ui.utils.LayoutUtil;
	
	/**
	 * Renders a push in the list.
	 */
	public class PushRenderer extends CellRenderer
	{		
		protected static const PADDING:uint = 30;
		protected static const PUSH_TYPE_ICON_WIDTH:uint = 37;
		protected static const DELETE_ICON_WIDTH:uint = 40;
		protected static const PUSH_TIME_PADDING:uint = 10;
		
		protected var background:Sprite;
		protected var pushTypeIcon:Image;
		protected var pushPreview:Label;
		protected var pushTime:Label;
		protected var deleteIcon:Image;
		
		protected var format:TextFormat;
		
		public function PushRenderer()
		{			
			super();
		}
		
		override public function set data(value:Object):void
		{											
			super.data = value;
			
			if (value) {
				updateCell();
			}
		}
		
		override public function destroy():void
		{
			super.destroy();
			
			background.removeEventListener(MouseEvent.CLICK, openPush);
			pushTypeIcon.removeEventListener(MouseEvent.CLICK, openPush);
			pushPreview.removeEventListener(MouseEvent.CLICK, openPush);
			pushTime.removeEventListener(MouseEvent.CLICK, openPush);
			deleteIcon.removeEventListener(MouseEvent.CLICK, deletePush);
			
			pushTypeIcon.removeEventListener(Event.COMPLETE, onPushTypeIconLoad);
			deleteIcon.removeEventListener(Event.COMPLETE, onDeleteIconLoad);
			
			pushTime.removeEventListener(TextEvent.LAYOUT_ESTIMATE_CHANGE, pushTimeLayoutChange);
		}
		
		protected function updateCell():void
		{					
			var push:Push = data as Push;
			 
			format.italic = push.unread;
			
			pushPreview.format = format;
			pushTime.format = format;
			
			pushTime.text = push.pushTime;
			
			if (push.contentType == Push.CONTENT_TYPE_IMAGE) {
				pushTypeIcon.setImage("pictures.png");
				pushPreview.text = "Image: " + push.fileExtension;
			} else if (push.contentType == Push.CONTENT_TYPE_TEXT) {	
				pushTypeIcon.setImage("memo.png");
				
				// Generate a preview of the text that was pushed
				var textBytes:ByteArray = Base64.decode(push.content);
				// Set the read position back to the start of the data
				textBytes.position = 0;
				var textToPreview:String =  textBytes.readUTFBytes(textBytes.length);
				
				// Replace new line characters with a space for the sake of the preview
				textToPreview = textToPreview.replace(/\r/gi, " ");
				textToPreview = textToPreview.replace(/\n/gi, " ");
				
				pushPreview.text = textToPreview;
			} else {
				// We are dealing with an HTML/XML push
				pushTypeIcon.setImage("browser.png");
				
				if (push.fileExtension == Push.FILE_EXTENSION_HTML) {
					pushPreview.text = "HTML/XML: .html";
				} else {
					pushPreview.text = "HTML/XML: .xml";
				}
			}
		}

		override protected function styleState():void
		{					
			super.styleState();
			
			if (state == SkinStates.SELECTED)
			{
				background.graphics.clear();
				background.graphics.beginFill(0x659EC7, 1.0);
				background.graphics.drawRect(0, 0, width, height);
				background.graphics.endFill();
				background.graphics.lineStyle(2, 0x222222);
				background.graphics.moveTo(0, height - 1);
				background.graphics.lineTo(width - 1, height - 1);
				background.graphics.lineTo(width - 1, 0);
				
				format.color = 0xffffff;
			} else {
				background.graphics.clear();
				background.graphics.beginFill(0xffffff, 1.0);
				background.graphics.drawRect(0, 0, width, height);
				background.graphics.endFill();
				background.graphics.lineStyle(2, 0x222222);
				background.graphics.moveTo(0, height - 1);
				background.graphics.lineTo(width - 1, height - 1);
				background.graphics.lineTo(width - 1, 0);
				
				format.color = 0x000000;
			}
			
			pushPreview.format = format;
			pushTime.format = format;
		}
		
		/*
		override public function updateFontSettings():void
		{
			super.updateFontSettings();
			
			pushTime.updateFontSettings();
			pushPreview.updateFontSettings();
		}
		*/
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{									
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			pushTime.width = unscaledWidth;
			
			deleteIcon.x = unscaledWidth - PADDING - DELETE_ICON_WIDTH;

			pushPreview.y = LayoutUtil.computeAlignment(0, unscaledHeight, pushPreview.height, Align.CENTER);
			pushTime.y = LayoutUtil.computeAlignment(0, unscaledHeight, pushTime.height, Align.CENTER);
		}
		
		/**
		 * Initializes objects needed in the item rendering.
		 */
		override protected function init():void
		{					
			super.init();
			
			background = new Sprite();
			pushTypeIcon = new Image();
			pushPreview = new Label();
			pushTime = new Label();
			deleteIcon = new Image();
			
			format = new TextFormat();
			format.style = TextFormatStyle.CONTENT;

			pushTypeIcon.cache = PushReceiver.imageCache;
			pushTypeIcon.addEventListener(Event.COMPLETE, onPushTypeIconLoad);
			
			deleteIcon.setImage("trash.png");
			deleteIcon.cache = PushReceiver.imageCache;
			deleteIcon.addEventListener(Event.COMPLETE, onDeleteIconLoad);
			
			pushTypeIcon.x = PADDING;
			pushPreview.x = pushTypeIcon.x + PUSH_TYPE_ICON_WIDTH + PADDING;
			
			// Set the truncation mode for the text preview
			// so that a "..." is displayed if the text is too long
			pushPreview.truncationMode = TextTruncationMode.TRUNCATE_TAIL;
			
			addChild(background);
			addChild(pushTypeIcon);
			addChild(pushPreview);
			addChild(pushTime);
			addChild(deleteIcon);
			
			background.addEventListener(MouseEvent.CLICK, openPush);
			pushTypeIcon.addEventListener(MouseEvent.CLICK, openPush);
			pushPreview.addEventListener(MouseEvent.CLICK, openPush);
			pushTime.addEventListener(MouseEvent.CLICK, openPush);
			deleteIcon.addEventListener(MouseEvent.CLICK, deletePush);
			
			pushTime.addEventListener(TextEvent.LAYOUT_ESTIMATE_CHANGE, pushTimeLayoutChange);
		}
		
		protected function pushTimeLayoutChange(e:TextEvent):void
		{
			if (pushTime.layoutComplete) {
				pushTime.width = pushTime.textWidth + PUSH_TIME_PADDING;
				pushTime.x = deleteIcon.x - PADDING - pushTime.width;
				pushPreview.width = pushTime.x - PADDING - pushPreview.x;
			}
		}
		
		protected function onDeleteIconLoad(e:Event):void
		{			
			deleteIcon.y = LayoutUtil.computeAlignment(0, height, deleteIcon.height, Align.CENTER);
		}
		
		protected function onPushTypeIconLoad(e:Event):void
		{			
			pushTypeIcon.width = pushTypeIcon.bitmapData.width;
			pushTypeIcon.height = pushTypeIcon.bitmapData.height;
			
			pushTypeIcon.y =  LayoutUtil.computeAlignment(0, height, pushTypeIcon.height, Align.CENTER);
		}
		
		/**
		 * Opens a push item by displaying its contents in a dialog. 
		 * @param event a mouse event
		 */
		protected function openPush(event:MouseEvent):void
		{
			var push:Push = data as Push;
			
			var pushNotificationService:PushNotificationService = PushNotificationServiceImpl.getPushNotificationService();
			pushNotificationService.markPushAsRead(push.seqNum);
			
			var updatedPush:Push = pushNotificationService.getPush(push.seqNum);
			updatedPush.dateHeading = push.dateHeading;
			
			ListContainer.getListContainer().updatePush(push.dateHeading, updatedPush, push);
			
			if (push.contentType == Push.CONTENT_TYPE_TEXT || push.fileExtension == Push.FILE_EXTENSION_XML 
				|| push.contentType == Push.CONTENT_TYPE_IMAGE) {
				var openDialog:PushContentDialog = new PushContentDialog();
				openDialog.title = push.pushDate + " - " + push.pushTime;
				openDialog.addButton("Close");
				openDialog.push = push;
				openDialog.show();
			} else if (push.fileExtension == Push.FILE_EXTENSION_HTML) {
				var htmlBytes:ByteArray = Base64.decode(push.content);
				// Set the read position back to the start of the data
				htmlBytes.position = 0;
				
				var openHtmlDialog:HtmlContentDialog = new HtmlContentDialog();
				openHtmlDialog.title = push.pushDate + " - " + push.pushTime;
				openHtmlDialog.addButton("Close");
				openHtmlDialog.htmlContent = htmlBytes.readUTFBytes(htmlBytes.length);
				openHtmlDialog.show();
			}
		}
		
		/**
		 * Deletes a push item after confirming in a dialog.
		 * @param event a mouse event
		 */
		protected function deletePush(event:MouseEvent):void 
		{			
			deleteIcon.setImage("trashhighlight.png");
			
			var deleteDialog:AlertDialog = new AlertDialog();
			deleteDialog.title = "Delete";
			deleteDialog.message = "Delete Item?";
			deleteDialog.addButton("Delete");
			deleteDialog.addButton("Cancel");
			deleteDialog.addEventListener(Event.SELECT, deleteDialogClicked);
			deleteDialog.show();
		}
		
		/**
		 * Actions to perform when either the "delete" or "cancel" button are clicked for the delete dialog.
		 * @param event a dialog event 
		 */
		protected function deleteDialogClicked(event:Event):void
		{				
			if (event.target.selectedIndex == 0) {
				// The "Delete" button was clicked
				// Remove the highlight
				deleteIcon.setImage("trash.png");
				
				var push:Push = data as Push;
				
				removePush(push);
			} else {
				// Remove the highlight
				deleteIcon.setImage("trash.png");
			}
		}
		
		/**
		 * Removes the push from the list and from the database. 
		 * @param push the push to be removed
		 */
		protected function removePush(push:Push):void 
		{			
			ListContainer.getListContainer().selectItem(data);
			ListContainer.getListContainer().removeItem();
			
			var pushNotificationService:PushNotificationService = PushNotificationServiceImpl.getPushNotificationService();
			pushNotificationService.deletePush(push.seqNum);
		}
	}
}