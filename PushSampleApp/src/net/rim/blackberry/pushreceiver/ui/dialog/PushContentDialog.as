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

package net.rim.blackberry.pushreceiver.ui.dialog
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	
	import net.rim.blackberry.pushreceiver.vo.Push;
	
	import qnx.crypto.Base64;
	import qnx.fuse.ui.core.Container;
	import qnx.fuse.ui.core.SizeOptions;
	import qnx.fuse.ui.dialog.AlertDialog;
	import qnx.fuse.ui.display.Image;
	import qnx.fuse.ui.layouts.Align;
	import qnx.fuse.ui.layouts.gridLayout.GridData;
	import qnx.fuse.ui.layouts.gridLayout.GridLayout;
	import qnx.fuse.ui.listClasses.ScrollDirection;
	import qnx.fuse.ui.text.Label;
	
	/**
	 * Dialog for displaying the contents of a push (except for HTML content).
	 */
	public class PushContentDialog extends AlertDialog
	{		
		private var contentGrid:GridData;
		private var contentContainer:Container;
		
		public function PushContentDialog()
		{
			super();
		}
		
		public function set push(push:Push):void
		{
			if (push.contentType == Push.CONTENT_TYPE_TEXT || push.fileExtension == Push.FILE_EXTENSION_XML) {
				// Text content
				var textBytes:ByteArray = Base64.decode(push.content);
				// Set the read position back to the start of the data
				textBytes.position = 0;
				
				var contentLabel:Label = new Label();
				contentLabel.maxLines = 0;
				contentLabel.layoutData = contentGrid;
				contentLabel.text = textBytes.readUTFBytes(textBytes.length);	
				
				contentContainer.addChild(contentLabel);
			} else if (push.contentType == Push.CONTENT_TYPE_IMAGE) {
				// Image content
				var imageBytes:ByteArray = Base64.decode(push.content);
				// Set the read position back to the start of the data
				imageBytes.position = 0;
				
				var imageLoader:Loader = new Loader();
				
				imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, 
					function(e:Event):void 
					{
						var bmd:BitmapData = Bitmap(e.target.content).bitmapData;
						
						var contentImage:Image = new Image();
						contentImage.setImage(bmd);
						
						contentImage.layoutData = contentGrid;
						
						contentContainer.addChild(contentImage);
					}
				);
				
				imageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, 
					function(e:IOErrorEvent):void 
					{
						var contentLabel:Label = new Label();
						contentLabel.maxLines = 0;
						contentLabel.layoutData = contentGrid;
						contentLabel.text = "Error: Unable to load image from the push. Reason: " + e.text;
						
						contentContainer.addChild(contentLabel);
					}
				);
				
				imageLoader.loadBytes(imageBytes);
			}
		}
		
		override protected function createContent(container:Container):void
		{
			super.createContent(container);
			
			contentGrid = new GridData();
			contentGrid.hAlign = Align.BEGIN;
			contentGrid.vAlign = Align.BEGIN;
			
			contentContainer = new Container();
			contentContainer.scrollDirection = ScrollDirection.BOTH;
			
			var contentLayout:GridLayout = new GridLayout();
			contentLayout.spacing = 20;
			contentLayout.numColumns = 1;
			contentLayout.hAlign = Align.BEGIN;
			contentLayout.vAlign = Align.BEGIN;
			contentLayout.setOptions(SizeOptions.GROW_BOTH);
			
			contentContainer.layout = contentLayout;
			
			container.addChild(contentContainer);
		}
		
		override protected function updateSize():void
		{
			dialogContainer.layout.layoutChanged();
			
			var maximumHeight:int = Capabilities.screenResolutionY - 2 * 	minimumScreenMargin;
			setActualSize(startWidth - 48, maximumHeight);
			dialogContainer.setActualSize(startWidth - 48, maximumHeight);
		}
	}
}