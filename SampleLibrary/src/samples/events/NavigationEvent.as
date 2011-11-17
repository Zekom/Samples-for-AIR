/*
* Copyright (c) 2011 Research In Motion Limited.
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
package samples.events
{
    import flash.events.Event;
    
    public class NavigationEvent extends Event {
        
        public static const ADD:String 		        = "samples.events.NavigationEvent.ADD";
        public static const BACK:String 	        = "samples.events.NavigationEvent.BACK";
        public static const ADD_AND_CLOSE:String    = "samples.events.NavigationEvent.ADD_AND_CLOSE";
        public static const OVERLAY:String 	        = "samples.events.NavigationEvent.OVERLAY";
        public static const PLAY_TRACK:String       = "samples.events.NavigationEvent.PLAY_TRACK";
        
        public var index:Number;
        public var param:Object;
        public var classname:Class;
        
        public function NavigationEvent(type:String, bubbles:Boolean = true, cancelable:Boolean = false):void 
        {
            super(type, bubbles, cancelable);
        }
        
        override public function toString():String
        {
            return( formatToString( "NavigationEvent", "type", "bubbles","cancelable") ); 	
        }
        
        public override function clone():Event 
        {
            var event:NavigationEvent = new NavigationEvent(type, bubbles, cancelable);
            return event;
        }
        
    }
}