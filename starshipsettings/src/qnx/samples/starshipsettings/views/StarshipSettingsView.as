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
package qnx.samples.starshipsettings.views
{

	import qnx.fuse.ui.buttons.CheckBox;
	import qnx.fuse.ui.buttons.LabelPlacement;
	import qnx.fuse.ui.buttons.RadioButton;
	import qnx.fuse.ui.buttons.ToggleSwitch;
	import qnx.fuse.ui.core.Container;
	import qnx.fuse.ui.core.SizeOptions;
	import qnx.fuse.ui.display.Image;
	import qnx.fuse.ui.events.SliderEvent;
	import qnx.fuse.ui.layouts.Align;
	import qnx.fuse.ui.layouts.gridLayout.GridData;
	import qnx.fuse.ui.layouts.gridLayout.GridLayout;
	import qnx.fuse.ui.slider.Slider;
	import qnx.fuse.ui.text.Label;
	import qnx.samples.starshipsettings.ui.WarpImage;
	import flash.net.SharedObject;

	/**
	 * The Main view for the application.
	 */
	public class StarshipSettingsView extends Container
	{
		[Embed(source="../assets/images/Background.png")]
		public var bgImage : Class;
		private var _background : Image;
		private var _controlContainer : Container;
		private var _hyperDriveRadioButton : RadioButton;
		private var _saunaRadioButton : RadioButton;
		private var _warpImage : WarpImage;
		private var _warpSlider : Slider;
		private var _scannerCheckbox : CheckBox;
		private var _gravityToggle : ToggleSwitch;

		public function StarshipSettingsView()
		{
		}

		override protected function init() : void
		{
			super.init();

			_background = createBackground();
			_controlContainer = createContainer();

			createLabel( "DIVERT ALL POWER TO:" );
			_hyperDriveRadioButton = createRadioButton( "HYPERDRIVE", true );
			_saunaRadioButton = createRadioButton( "SAUNA" );

			var layoutData : GridData = new GridData();
			layoutData.hAlign = Align.CENTER;
			layoutData.marginBottom = 30;
			layoutData.setOptions( SizeOptions.NONE );

			_warpImage = new WarpImage();
			_warpImage.layoutData = layoutData;
			_controlContainer.addChild( _warpImage );

			createLabel( "WARP DRIVE SPEED:" );
			_warpSlider = createSlider();

			_scannerCheckbox = createCheckBox( "URANUS SCANNER" );

			var lbl : Label = createLabel( "GRAVITY" );
			lbl.id = "GravityLabel";

			_gravityToggle = createToggleSwitch();

			loadSettings();
		}

		private function createContainer() : Container
		{
			var container : Container = new Container();

			var layout : GridLayout = new GridLayout( 1 );
			layout.paddingLeft = layout.paddingRight = 115;
			layout.paddingTop = 180;
			container.layout = layout;

			var containerData : GridData = new GridData();
			containerData.hAlign = Align.BEGIN;
			containerData.vAlign = Align.BEGIN;
			containerData.setOptions( SizeOptions.RESIZE_BOTH );
			container.layoutData = containerData;

			addChild( container );

			return container;
		}

		private function createLabel(label : String) : Label
		{
			var lbl : Label = new Label();
			lbl.text = label;
			_controlContainer.addChild( lbl );
			return lbl;
		}

		private function createRadioButton(label : String, selected : Boolean = false) : RadioButton
		{
			var layoutData : GridData = new GridData();
			layoutData.hAlign = Align.FILL;
			layoutData.marginTop = 20;
			layoutData.marginBottom = 30;
			layoutData.setOptions( SizeOptions.RESIZE_HORIZONTAL );

			var btn : RadioButton = new RadioButton();
			btn.label = label;
			btn.selected = selected;
			btn.labelPlacement = LabelPlacement.LEFT;
			btn.layoutData = layoutData;
			btn.groupname = "powerTarget";
			_controlContainer.addChild( btn );

			return btn;
		}

		private function createSlider() : Slider
		{
			var layoutData : GridData = new GridData();
			layoutData.hAlign = Align.FILL;
			layoutData.marginTop = 60;
			layoutData.setOptions( SizeOptions.RESIZE_HORIZONTAL );

			var slider : Slider = new Slider();
			slider.layoutData = layoutData;
			slider.animateToValue = false;
			slider.addEventListener( SliderEvent.MOVE, onSliderChange );
			slider.minimum = 10;
			slider.maximum = 100;
			slider.value = 55;
			_controlContainer.addChild( slider );

			return slider;
		}

		private function onSliderChange(event : SliderEvent) : void
		{
			_warpImage.speed = event.value;
		}

		private function createCheckBox(label : String) : CheckBox
		{
			var layoutData : GridData = new GridData();
			layoutData.hAlign = Align.FILL;
			layoutData.marginTop = 40;
			layoutData.marginBottom = 15;
			layoutData.setOptions( SizeOptions.RESIZE_HORIZONTAL );

			var btn : CheckBox = new CheckBox();
			btn.label = label;
			btn.layoutData = layoutData;
			_controlContainer.addChild( btn );

			return btn;
		}

		private function createToggleSwitch() : ToggleSwitch
		{
			var toggle : ToggleSwitch = new ToggleSwitch();
			var layoutData : GridData = new GridData();
			layoutData.hAlign = Align.CENTER;
			layoutData.vAlign = Align.END;
			layoutData.setOptions( SizeOptions.NONE );
			toggle.layoutData = layoutData;

			_controlContainer.addChild( toggle );

			return toggle;
		}

		private function createBackground() : Image
		{
			var img : Image = new Image();
			img.setImage( new bgImage() );
			img.smoothing = true;

			var listData : GridData = new GridData();
			listData.hAlign = Align.FILL;
			listData.setOptions( SizeOptions.RESIZE_BOTH );

			img.layoutData = background;
			addChild( img );

			return img;
		}

		override protected function updateDisplayList(unscaledWidth : Number, unscaledHeight : Number) : void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );

			_background.setActualSize( unscaledWidth, unscaledHeight );
			_controlContainer.setActualSize( unscaledWidth, unscaledHeight );
		}

		public function saveSettings() : void
		{
			var so : SharedObject = SharedObject.getLocal( "starshipSettings" );
			so.data['powerTarget'] = (_saunaRadioButton.selected) ? (_saunaRadioButton.label) : (_hyperDriveRadioButton.label);
			so.data['warpSpeed'] = _warpSlider.value;
			so.data['scannerActive'] = _scannerCheckbox.selected;
			so.data['gravity'] = _gravityToggle.selected;
			so.flush();
		}

		private function loadSettings() : void
		{
			var so : SharedObject = SharedObject.getLocal( "starshipSettings" );
			if (so)
			{
				var selectedBtn : RadioButton = (so.data['powerTarget'] == "SAUNA") ? (_saunaRadioButton) : (_hyperDriveRadioButton);
				selectedBtn.selected = true;

				_warpSlider.value = _warpImage.speed = so.data['warpSpeed'];
				_scannerCheckbox.selected = so.data['scannerActive'];
				_gravityToggle.selected = so.data['gravity'];
			}
		}
	}
}
