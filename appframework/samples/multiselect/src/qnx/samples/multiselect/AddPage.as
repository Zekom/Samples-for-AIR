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
package qnx.samples.multiselect
{
	import qnx.fuse.ui.core.Action;
	import qnx.fuse.ui.core.Container;
	import qnx.fuse.ui.events.ActionEvent;
	import qnx.fuse.ui.layouts.gridLayout.GridLayout;
	import qnx.fuse.ui.navigation.Page;
	import qnx.fuse.ui.text.TextInput;
	import qnx.fuse.ui.titlebar.TitleBar;

	import flash.events.Event;

	/**
	 * @author jdolce
	 */
	public class AddPage extends Page
	{
		
		private var __input:TextInput;
		
		
		
		public function AddPage()
		{
		}

		override protected function init():void
		{
			super.init();
			var container:Container = new Container();
			var layout:GridLayout = new GridLayout();
			
			layout.padding = 20;
			
			container.layout = layout;

			__input = new TextInput();
			__input.prompt = "Add Item";
			__input.addEventListener( Event.CHANGE, onTextChanged );
			
			container.addChild( __input );
			
			content = container;
			
			var acceptAction:Action = new Action( "Save" );
			acceptAction.enabled = false;
			
			var dismissAction:Action = new Action( "Cancel" );
			
			titleBar = new TitleBar();
			titleBar.acceptAction = acceptAction;
			titleBar.dismissAction = dismissAction;
			titleBar.addEventListener(ActionEvent.ACTION_SELECTED, onTitleBarActionSelected );
			
		}

		private function onTextChanged( event:Event ):void
		{
			setAcceptEnable();
		}
		
		private function setAcceptEnable():void
		{
			if( __input.text != null && __input.text.length > 0 )
			{
				titleBar.acceptAction.enabled = true;
			}
			else
			{
				titleBar.acceptAction.enabled = false;
			}
		}
		
		
		private function onTitleBarActionSelected( event:ActionEvent ):void
		{
			if( event.action == titleBar.dismissAction )
			{
				dispatchEvent( new Event( Event.CANCEL ) );
			}
			else if( event.action == titleBar.acceptAction )
			{
				dispatchEvent( new Event( Event.COMPLETE ) );
			}
		}
		
		public function setText( value:String ):void
		{
			__input.text = value;
			setAcceptEnable();
		}
		
		public function getText():String
		{
			return( __input.text );
		}
	}
}
