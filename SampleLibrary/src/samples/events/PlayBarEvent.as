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
    import flash.display.BitmapData;
    import flash.events.Event;
    
    public class PlayBarEvent extends Event
    {
        // Actions
        public static const INIT:String	    = "samples.events.playbar.init";
        public static const START:String	= "samples.events.playbar.start";
        public static const PAUSE:String	= "samples.events.playbar.pause";
        public static const STOP:String		= "samples.events.playbar.stop";
        
        // Status
        public static const STARTED:String = "samples.events.playbar.started";
        public static const PAUSED:String  = "samples.events.playbar.paused";
        public static const STOPPED:String = "samples.events.playbar.stopped";
        
        public var url:String;
        public var thumbnail:BitmapData;
        public var thumbnailURL:String;
        public var album:String;
        public var track:String;
        public var artist:String;
        
        /**
         *  Status and action events for playbar.
         * @param type - string for one of the type constants.
         * @param bubbles - bubbles boolean.
         * @param cancelable - cancelable boolean.
         */ 
        public function PlayBarEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
        }
        /** @private **/
        override public function toString():String
        {
            return( formatToString( "PlayBarEvent", "type", "bubbles","cancelable") ); 	
        }
        
        /** @private **/
        override public function clone():Event
        {
            return( new PlayBarEvent(type, bubbles, cancelable));	
        }

    }
}