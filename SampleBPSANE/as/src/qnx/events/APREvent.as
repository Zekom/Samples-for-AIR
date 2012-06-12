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

package qnx.events
{
	import flash.events.Event;
	public class APREvent extends Event
	{
		
		public var azimuth:Number;
		public var pitch:Number;
		public var roll:Number;
		public var timestamp:Number;
		public var accuracy:int;
		
		public static const UPDATE:String = "APRUpdate";
		
		
		public function APREvent(type:String, azimuth:Number, pitch:Number, roll:Number, accuracy:int, timestamp:Number )
		{
			super(type, false, false);
			this.azimuth = azimuth;
			this.pitch = pitch;
			this.roll = roll;
			this.accuracy = accuracy;
			this.timestamp = timestamp;
		}
		
		override public function clone():Event
		{
			return new APREvent( type, azimuth, pitch, roll, accuracy, timestamp );
		}
		
		override public function toString():String
		{
			return( formatToString( "APREvent", "type", "azimuth", "pitch", "roll", "accuracy", "timestamp" ) );
		}
	}
}