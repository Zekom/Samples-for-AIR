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
    
    public class MenuEvent extends Event
    {
        // Expanded menu
        public static const HOME_CLICKED:String = "samples.events.MenuEvent.HOME_CLICKED";
        public static const OPTIONS_CLICKED:String = "samples.events.MenuEvent.OPTIONS_CLICKED";
        public static const HISTORY_ITEM_CLICKED:String = "samples.events.MenuEvent.HISTORY_ITEM_CLICKED";
        
        // Navigation menu
        public static const ITEM_CLICKED:String = "samples.events.MenuEvent.ITEM_CLICKED";
        public static const SEARCH:String       = "samples.events.MenuEvent.SEARCH";
        public static const BACK:String         = "samples.events.MenuEvent.BACK";
        
        public var index:int;
        public var param:Object;
        public var classname:Class;
        public var query:String;
        
        /**
         *  events for navigation menu (menu items, search, back) and expanded menu (home, options, browse history).
         * @param type - string for one of the type constants.
         * @param searchText - string for search text.
         * @param bubbles - bubbles boolean.
         * @param cancelable - cancelable boolean.
         */ 
        public function MenuEvent(type:String, searchText:String = null, bubbles:Boolean = true, cancelable:Boolean = false):void 
        {
            super(type, bubbles, cancelable);
            query = searchText;
        }
        override public function toString():String
        {
            return( formatToString( "MenuEvent", "type", "searchText","bubbles","cancelable") ); 	
        }
        
        /** @private **/
        override public function clone():Event
        {
            return( new MenuEvent(type,query,bubbles,cancelable));	
        }

    }
}