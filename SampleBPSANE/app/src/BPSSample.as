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
package 
{
	import qnx.events.APREvent;
	import qnx.sensors.APRSensor;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.text.TextField;
	
	public class BPSSample extends Sprite
	{
		private var apr:APRSensor;
		private var label:TextField;
		
		public function BPSSample()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			label = new TextField();
			
			label.width = 500;
			label.height = 500;
			addChild( label );
			
			if( APRSensor.isSupported() )
			{
				apr = new APRSensor();
				apr.addEventListener( APREvent.UPDATE, aprUpdate );
				apr.start();
			}
			else
			{
				label.text = "APR Not Supported";
			}
		}
		
		
		private function aprUpdate( event:APREvent ):void
		{
			var str:String = "APR Event\n";
			str += "azimuth = " + event.azimuth + "\n";
			str += "pitch = " + event.pitch + "\n";
			str += "roll = " + event.roll + "\n";
			label.text = str;
		}
	}
}
