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
package qnx.samples.starshipsettings.ui
{

	import flash.events.Event;
	import qnx.fuse.ui.core.UIComponent;
	import qnx.fuse.ui.layouts.LayoutMeasurement;
	import flash.display.Bitmap;

	public class WarpImage extends UIComponent
	{
		[Embed(source="/../assets/images/Warp_Drive.png")]
		public var warpDriveOff : Class;
		[Embed(source="/../assets/images/Warp_Drive_Energy.png")]
		public var warpDriveOn : Class;
		
		private var _warpOff : Bitmap;
		private var _warpOn : Bitmap;
		private var _speed : Number = 50;
		private var _ctr : Number = 0;
		
		private static const TWO_PI : Number = Math.PI * 2;

		public function WarpImage()
		{
			super();
		}

		override protected function init() : void
		{
			super.init();

			_warpOff = new warpDriveOff();
			_warpOn = new warpDriveOn();

			addChild( _warpOff );
			addChild( _warpOn );

			addEventListener( Event.ENTER_FRAME, onUpdate );
		}

		private function onUpdate(event : Event) : void
		{
			_ctr += (_speed / 100) / TWO_PI;

			_warpOn.alpha = ( Math.sin( _ctr ) + 1 ) / 2;
		}

		public function set speed(value : Number) : void
		{
			_speed = value;
		}

		override protected function doMeasure(availableWidth : Number, availableHeight : Number) : LayoutMeasurement
		{
			return new LayoutMeasurement( _warpOn.width, _warpOn.height );
		}
	}
}
