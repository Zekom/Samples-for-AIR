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
	import flash.system.Capabilities;
	
	import qnx.fuse.ui.core.Container;
	import qnx.fuse.ui.dialog.AlertDialog;
	import qnx.media.QNXStageWebView;
	
	/**
	 * Dialog for displaying HTML content.
	 */
	public class HtmlContentDialog extends AlertDialog
	{		
		private var webview:QNXStageWebView;
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
			
			var maximumHeight:int = Capabilities.screenResolutionY - 2 * 	minimumScreenMargin;
			setActualSize(startWidth - 48, maximumHeight);
			dialogContainer.setActualSize(startWidth - 48, maximumHeight);
		}
		
		override public function show():void
		{			
			super.show();
			
			webview = new QNXStageWebView("htmlpushdisplay");
			webview.stage = stage;
			webview.viewPort = new Rectangle(content.x, content.y, content.width, content.height); 
			webview.loadString(html);
			webview.zOrder = 5;
		}
		
		private function webviewDispose(e:Event):void
		{
			webview.dispose();
		}
	}
}