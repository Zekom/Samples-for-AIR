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
	
	import net.rim.blackberry.pushreceiver.ui.ListContainer;
	
	import qnx.fuse.ui.core.Container;
	import qnx.fuse.ui.core.SizeOptions;
	import qnx.fuse.ui.dialog.DialogBase;
	import qnx.fuse.ui.layouts.Align;
	import qnx.fuse.ui.layouts.gridLayout.GridData;
	import qnx.fuse.ui.layouts.gridLayout.GridLayout;
	import qnx.fuse.ui.listClasses.ScrollDirection;
	import qnx.fuse.ui.progress.ActivityIndicator;
	import qnx.fuse.ui.text.Label;
	
	/**
	 * Dialog for displaying a progress alert while an operation is being performed.
	 */
	public class ProgressAlertDialog extends DialogBase
	{	
		protected var activityContainer:Container;
		protected var messageContainer:Container;
		
		protected var progressMessageStr:String;
		
		private var activityIndicator:ActivityIndicator = new ActivityIndicator();
		private var messageLabel:Label = new Label(); 
		
		public function ProgressAlertDialog()
		{
			super();
		}
		
		public function set progressAlertMessage(value:String):void
		{
			progressMessageStr = value;
		}
		
		override protected function createContent(container:Container):void
		{
			super.createContent(container);
			
			activityContainer = new Container();
			var layout:GridLayout = new GridLayout();
			layout.hAlign = Align.CENTER;
			layout.vAlign = Align.BEGIN;
			activityContainer.layout = layout;
			var containerData:GridData = new GridData();
			containerData.hAlign = Align.CENTER;			
			activityContainer.layoutData = containerData;
			
			activityIndicator = new ActivityIndicator();
			var layoutData:GridData = new GridData();
			layoutData.hAlign = Align.CENTER;
			layoutData.vAlign = Align.CENTER;
			activityIndicator.layoutData = layoutData;
			activityIndicator.animate(true);
			
			messageContainer = new Container();
			messageContainer.layout = new GridLayout();
			messageContainer.scrollDirection = ScrollDirection.VERTICAL;
			containerData = new GridData();
			containerData.setOptions(SizeOptions.RESIZE_BOTH);
			messageContainer.layoutData = containerData;
			
			messageLabel = new Label();
			messageLabel.id = "dialogAlignCenter";	// Not defined in DialogBase
			
			var labelData:GridData = new GridData();
			labelData.hAlign = Align.CENTER;			
			labelData.vAlign = Align.CENTER;
			labelData.setOptions(SizeOptions.RESIZE_HORIZONTAL);
			messageLabel.layoutData = labelData;
			messageLabel.maxLines = 0;
			
			messageContainer.addChild(messageLabel);			
			activityContainer.addChild(activityIndicator);			
			container.addChild(activityContainer);
			container.addChild(messageContainer);
		}
		
		override public function show():void
		{						
			messageLabel.text = this.progressMessageStr;
			activityIndicator.animate(true);
			
			super.show();
		}
	}
}