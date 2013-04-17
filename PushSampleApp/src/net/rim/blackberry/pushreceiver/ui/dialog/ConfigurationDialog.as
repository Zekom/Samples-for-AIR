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
	import flash.events.MouseEvent;
	
	import net.rim.blackberry.pushreceiver.events.ConfigurationDialogEvent;
	
	import qnx.fuse.ui.buttons.CheckBox;
	import qnx.fuse.ui.buttons.RadioButton;
	import qnx.fuse.ui.buttons.RadioButtonGroup;
	import qnx.fuse.ui.core.Container;
	import qnx.fuse.ui.dialog.AlertDialog;
	import qnx.fuse.ui.layouts.Align;
	import qnx.fuse.ui.layouts.gridLayout.GridLayout;
	import qnx.fuse.ui.listClasses.ScrollDirection;
	import qnx.fuse.ui.text.Label;
	import qnx.fuse.ui.text.TextFormat;
	import qnx.fuse.ui.text.TextInput;
	import qnx.fuse.ui.text.KeyboardType;
	
	/**
	 * Dialog for setting configuration settings.
	 */
	public class ConfigurationDialog extends AlertDialog
	{
		public static const PPG_TYPE_RADIO_BUTTON_GROUP:String = "PPG Type";
		
		public var ppgRadioButtonGroup:RadioButtonGroup = RadioButtonGroup.getGroup(PPG_TYPE_RADIO_BUTTON_GROUP);
		public var publicPPGRadioButton:RadioButton = new RadioButton();
		public var enterprisePPGRadioButton:RadioButton = new RadioButton();
		public var useSDKAsPIField:CheckBox = new CheckBox();
		public var appIdField:TextInput = new TextInput();
		public var ppgUrlField:TextInput = new TextInput();
		public var piUrlField:TextInput = new TextInput();
		public var launchAppOnPushField:CheckBox = new CheckBox();
		public var errorLabel:Label = new Label();
		
		protected var publicPPGRadioButtonText:String = "Public/BIS";
		protected var enterprisePPGRadioButtonText:String = "Enterprise/BDS";
		protected var useSDKAsPILabelStr:String = "Subscribe with Push Service SDK";
		protected var appIdLabelStr:String = "Application ID";
		protected var ppgUrlLabelStr:String = "PPG URL";
		protected var piUrlLabelStr:String = "Push Initiator URL";
		protected var launchAppOnPushLabelStr:String = "Launch Application on New Push";
		
		public function ConfigurationDialog()
		{
			super();
		}
		
		public function ppgRadioButtonGroupClicked(e:Event):void
		{			
			if (publicPPGRadioButton.selected) {
				this.ppgUrlField.enabled = true;
				this.appIdField.enabled = true;
			} else {
				this.ppgUrlField.enabled = false;
				
				if (useSDKAsPIField.selected) {
					this.appIdField.enabled = true;
				} else {
					this.appIdField.enabled = false;
				}
			}
		}
		
		public function useSDKAsPIFieldClicked(e:MouseEvent):void
		{			
			if (useSDKAsPIField.selected) {
				this.piUrlField.enabled = true;
				this.appIdField.enabled = true;
			} else {
				this.piUrlField.enabled = false;
				
				if (publicPPGRadioButton.selected) {
					this.appIdField.enabled = true;
				} else {
					this.appIdField.enabled = false;
				}
			}
		}
		
		public function set publicPushProxyGatewayRadioButtonLabel(value:String):void
		{
			this.publicPPGRadioButtonText = value;
		}
		
		public function selectPublicPushProxyGatewayRadioButton():void
		{
			this.ppgRadioButtonGroup.setSelectedRadioButton(publicPPGRadioButton);
		}
		
		public function set enterprisePushProxyGatewayRadioButtonLabel(value:String):void
		{
			this.enterprisePPGRadioButtonText = value;	
		}
		
		public function selectEnterprisePushProxyGatewayRadioButton():void
		{
			this.ppgRadioButtonGroup.setSelectedRadioButton(enterprisePPGRadioButton);
		}
		
		public function set useSDKAsPushInitiatorLabel(value:String):void
		{
			this.useSDKAsPILabelStr = value;	
		}
		
		public function set useSDKAsPushInitiator(value:Boolean):void
		{
			this.useSDKAsPIField.selected = value;	
		}
		
		public function set providerApplicationIdLabel(value:String):void
		{
			this.appIdLabelStr = value;
		}
		
		public function set providerApplicationId(value:String):void
		{
			this.appIdField.text = value;
		}
		
		public function set providerApplicationIdEditable(value:Boolean):void
		{
			this.appIdField.enabled = value;	
		}
		
		public function set pushProxyGatewayUrlLabel(value:String):void
		{
			this.ppgUrlLabelStr = value;
		}
		
		public function set pushProxyGatewayUrl(value:String):void
		{
			this.ppgUrlField.text = value;	
		}
		
		public function set pushProxyGatewayUrlEditable(value:Boolean):void
		{
			this.ppgUrlField.enabled = value;	
		}
		
		public function set pushInitiatorUrlLabel(value:String):void
		{
			this.piUrlLabelStr = value;
		}
		
		public function set pushInitiatorUrl(value:String):void
		{
			this.piUrlField.text = value;
		}
		
		public function set pushInitiatorUrlEditable(value:Boolean):void
		{
			this.piUrlField.enabled = value;	
		}
		
		public function set launchApplicationOnPushLabel(value:String):void
		{
			this.launchAppOnPushLabelStr = value;	
		}
		
		public function set launchApplicationOnPush(value:Boolean):void
		{
			this.launchAppOnPushField.selected = value;	
		}
		
		public function set errorText(value:String):void
		{
			if (errorLabel.text == value)
			{
				return;
			}
			
			errorLabel.text = value;
		}
		
		public function get errorText():String
		{
			return errorLabel.text;
		}
		
		override protected function createContent(container:Container):void
		{
			super.createContent(container);
			
			publicPPGRadioButton.groupname = PPG_TYPE_RADIO_BUTTON_GROUP;
			enterprisePPGRadioButton.groupname = PPG_TYPE_RADIO_BUTTON_GROUP;
			ppgRadioButtonGroup.addButton(publicPPGRadioButton);
			ppgRadioButtonGroup.addButton(enterprisePPGRadioButton);
			
			// Add event listeners for when radio buttons, checkboxes, etc. are clicked
			useSDKAsPIField.addEventListener(MouseEvent.CLICK, useSDKAsPIFieldClicked);
			ppgRadioButtonGroup.addEventListener(Event.CHANGE, ppgRadioButtonGroupClicked);
			
			addEventListener(Event.SELECT, createNotificationEvent);
			
			var grid:GridLayout = new GridLayout();
			container.layout = grid;
			grid.numColumns = 1;
			grid.vSpacing = 40;
			grid.padding = 10;
			
			var radioButtonGrid:GridLayout = new GridLayout();
			radioButtonGrid.numColumns = 2;
			radioButtonGrid.hSpacing = 50;
			radioButtonGrid.hAlign = Align.CENTER;
			var radioButtonContainer:Container = new Container();
			radioButtonContainer.layout = radioButtonGrid;
			radioButtonContainer.addChild(this.publicPPGRadioButton);
			radioButtonContainer.addChild(this.enterprisePPGRadioButton);
			
			publicPPGRadioButton.label = this.publicPPGRadioButtonText;
			enterprisePPGRadioButton.label = this.enterprisePPGRadioButtonText;
			useSDKAsPIField.label = this.useSDKAsPILabelStr;
			appIdField.prompt = this.appIdLabelStr;
			appIdField.spellCheck = false;
			appIdField.autoCorrect = false;
			ppgUrlField.prompt = this.ppgUrlLabelStr;
			ppgUrlField.spellCheck = false;
			ppgUrlField.autoCorrect = false;
			ppgUrlField.softKeyboardType = KeyboardType.URL;
			piUrlField.prompt = this.piUrlLabelStr;
			piUrlField.spellCheck = false;
			piUrlField.autoCorrect = false;
			piUrlField.softKeyboardType = KeyboardType.URL;
			launchAppOnPushField.label = this.launchAppOnPushLabelStr;
			
			errorLabel.maxLines = 0;
			var textFormat:TextFormat = new TextFormat();
			textFormat.color = 0xFF0000;
			errorLabel.format = textFormat;
			
			container.scrollDirection = ScrollDirection.VERTICAL;
			container.addChild(radioButtonContainer);
			container.addChild(this.useSDKAsPIField);
			container.addChild(this.appIdField);
			container.addChild(this.ppgUrlField);
			container.addChild(this.piUrlField);
			container.addChild(this.launchAppOnPushField);
			container.addChild(this.errorLabel);
		}

		override public function show():void
		{
			if (!errorText)
			{
				errorLabel.includeInLayout = false;
				errorLabel.visible = false;
			} 
			
			super.show();
		}
		
		private function createNotificationEvent(e:Event):void
		{			
			var evt:ConfigurationDialogEvent = new ConfigurationDialogEvent(ConfigurationDialogEvent.BUTTON_CLICKED);
			
			evt.launchApplicationOnPush = this.launchAppOnPushField.selected;
			
			evt.useSDKAsPushInitiator = this.useSDKAsPIField.selected;
			if (evt.useSDKAsPushInitiator) {
				evt.pushInitiatorUrl = this.piUrlField.text;
			} else {
				evt.pushInitiatorUrl = null;
			}
			
			if (this.publicPPGRadioButton.selected) {
				// Consumer application
				evt.usingPublicPushProxyGateway = true;
				evt.providerApplicationId = this.appIdField.text;
				evt.pushProxyGatewayUrl = this.ppgUrlField.text;
			} else {
				// Enterprise application
				evt.usingPublicPushProxyGateway = false;
				evt.pushProxyGatewayUrl = null;
				
				if (evt.useSDKAsPushInitiator) {
					evt.providerApplicationId = this.appIdField.text;
				} else {
					evt.providerApplicationId = null;
				}
			}
			
			dispatchEvent(evt);
		}
	}
}