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
package qnx.samples.starshipsettings
{

	import qnx.fuse.ui.theme.ThemeGlobals;
	import qnx.samples.starshipsettings.views.StarshipSettingsView;
	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.utils.ByteArray;

	[SWF(backgroundColor="#272727", frameRate="60")]
	public class StarshipSettings extends Sprite
	{
		[Embed(source="../assets/styles/styles.css", mimeType="application/octet-stream")]
		private var STYLES : Class;
		private var _mainView : StarshipSettingsView;

		public function StarshipSettings()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener( Event.RESIZE, stageResize );

			NativeApplication.nativeApplication.addEventListener( Event.EXITING, onApplicationExiting );

			ThemeGlobals.currentTheme = ThemeGlobals.BLACK;
			ThemeGlobals.injectCSS( (new STYLES() as ByteArray).toString() );

			_mainView = new StarshipSettingsView();
			addChild( _mainView );
		}

		private function onApplicationExiting(event : Event) : void
		{
			_mainView.saveSettings();
		}

		private function stageResize(event : Event) : void
		{
			_mainView.setActualSize( stage.stageWidth, stage.stageHeight );
		}
	}
}
