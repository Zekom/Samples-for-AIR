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
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import qnx.events.WebViewEvent;
	import qnx.fuse.ui.core.Container;
	import qnx.fuse.ui.dialog.AlertDialog;
	import qnx.fuse.ui.managers.WindowManager;
	import qnx.media.QNXStageWebView;
	
	/**
	 * Dialog for displaying HTML content.
	 */
	public class HtmlContentDialog extends AlertDialog
	{		
		private var webview:QNXStageWebView;
		private var isWebviewCreated:Boolean = false;
		private var html:String;
		
		public function HtmlContentDialog()
		{
			super();
		}
		
		public function set htmlContent(htmlContent:String):void
		{
			html = htmlContent;
		}
		
		override protected function createContent(container:Container):void
		{
			super.createContent(container);
			
			addEventListener(Event.SELECT, webviewDispose);
		}
		
		override protected function updateSize():void
		{
			dialogContainer.layout.layoutChanged();
			
			var wm:WindowManager = WindowManager.windowManager;
			var maximumWidth:int = wm.screenWidth;
			var maximumHeight:int = wm.screenHeight;
			
			setActualSize(maximumWidth - 48, maximumHeight - 48);
			dialogContainer.setActualSize(maximumWidth - 48, maximumHeight - 48);
		}
		
		override public function show():void
		{			
			super.show();
			
			content.width = header.width;
			content.height = height - header.height - footer.height;
			footer.y = height - footer.height;
			
			webview = new QNXStageWebView("htmlpushdisplay");
			webview.addEventListener(WebViewEvent.CREATED, webviewCreated);
			webview.stage = stage;
			webview.loadString(html);
			webview.zOrder = 5;
		}
		
		private function webviewCreated(e:WebViewEvent):void
		{
			isWebviewCreated = true;			
			
			webview.viewPort = new Rectangle(this.leftShadow, header.height, content.width - this.leftShadow - this.rightShadow, content.height); 
		}
		
		private function webviewDispose(e:Event):void
		{
			if (isWebviewCreated) {
			    webview.dispose();
			}
		}
	}
}