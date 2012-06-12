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
package qnx.sensors
{
	import qnx.events.APREvent;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	
	final public class APRSensor extends EventDispatcher
	{
		private static const ID:int = 3;
		private static const EXT:ExtensionContext = ExtensionContext.createExtensionContext( "qnx.bps.demo", null );
		private static var INSTANCES:int;
		
		static public function isSupported():Boolean
		{
			return( Boolean( EXT.call( "isSensorSupported", ID ) ) );
		}

		
		private var started:Boolean;
		
		
		
		public function APRSensor()
		{
		}
		
		public function start():Boolean
		{
			EXT.addEventListener( StatusEvent.STATUS, statusEvent );
			
			if( INSTANCES == 0 )
			{
				var result:Boolean = Boolean( EXT.call( "startSensor", ID ) );
				if( result ) 
				{
					INSTANCES++;
					started = true;
				}
				
				return( result  );
				
			}
			
			return( true );
		}
		
		public function stop():Boolean
		{
			EXT.removeEventListener( StatusEvent.STATUS, statusEvent );
			if( started )
			{
				var result:Boolean = Boolean( EXT.call( "stopSensor", ID ) );
				if( result )
				{
					INSTANCES--;
					started = false;
				}
				return( result );
			}
			return( false );
		}
		
		private function statusEvent(event:StatusEvent):void
		{
			var dataEvent:Event;
			if( event.level == "newdata" )
			{
				var values:Array = EXT.call( "getAPRValues" ) as Array;
				dataEvent = new APREvent(values[ 0 ], values[ 1 ], values[ 2 ], values[ 3 ], values[ 4 ], values[ 5 ]);
			}
			
			if( dataEvent != null )
			{
				dispatchEvent( dataEvent );
			}
		}
		
		public function skipDuplicateEvents( skipEvents:Boolean ):Boolean
		{
			return( Boolean( EXT.call( "skipDuplicateEvents", ID, skipEvents ) )  );
		}
		
		public function setRequestedUpdateInterval( interval:Number ):Boolean
		{
			return( Boolean( EXT.call( "setSensorRate", ID, interval ) ) );
		}
		
		
		public function getRangeMin():Number
		{
			return( EXT.call( "getSensorRangeMin", ID ) as Number );
		}
		
		public function getRangeMax():Number
		{
			return( EXT.call( "getSensorRangeMax", ID ) as Number );
		}
		
		public function getResolution():Number
		{
			return( EXT.call( "getSensorResolution", ID ) as Number );
		}
		
		public function getDelayMin():int
		{
			return( EXT.call( "getSensorDelayMin", ID ) as int );
		}
		
		public function getDelayMax():int
		{
			return( EXT.call( "getSensorDelayMax", ID ) as int );
		}
		
		public function getDelayDefault():int
		{
			return( EXT.call( "getSensorDelayDefault", ID ) as int );
		}
	}
}
