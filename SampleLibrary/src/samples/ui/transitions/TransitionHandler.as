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
package samples.ui.transitions
{
    import flash.events.EventDispatcher;
    
    import samples.events.TransitionEvent;
    
    import qnx.ui.core.Container;
    
    public class TransitionHandler extends EventDispatcher
    {
        // A tween queue needs to be used, else animations will be distorted when a user generates 
        // more than one transition simultaneously (e.g. quickly clicking on several MenuItems)
        protected var _tweenQueue:Array;
        protected var _useAlphaTransitions:Boolean = false;
        protected var _previous:Array;
        protected var _current:TransitionEvent;
        protected var _container:Container;
        
        public function TransitionHandler(handler:Container)
        {
            _container = handler;
            
            _tweenQueue = new Array();
            _previous = new Array();
            
            addEventListener(TransitionEvent.TWEENER_ADDED, tweenAdded);
            addEventListener(TransitionEvent.TWEENER_COMPLETED, tweenCompleted);
        }
        
        public function destroy():void 
        {
            for each (var container:Container in _previous) {
                container.destroy();
            }
            _previous = [];
        }
        
        protected function doTween(event:TransitionEvent):void {}
        
        /**
         * Appends a transition to the pending animation list
         * */
        private function tweenAdded(event:TransitionEvent):void 
        {
            _tweenQueue.push(event);
            if (_tweenQueue.length == 1) {
                doTween(event);
            }
        }
        
        /**
         * Executes the next pending animation when a previous one completed
         * */
        protected function tweenCompleted(event:TransitionEvent):void 
        {
            // Remove completed event from stack and perform the next pending one
            _tweenQueue.shift();
            event = _tweenQueue[_tweenQueue.length - 1] as TransitionEvent;
            // We no longer allow having more than one pending event, the other ones are discarded.
            if (event != null) {
                _tweenQueue = [event];
                doTween(event);
            }
        }
        
        public function set executeTweenOffset(offset:Number):void 
        {
            var event:TransitionEvent = _current;
            if (_useAlphaTransitions) {
                event.from.alpha = offset;
                event.to.alpha = 1 - offset;
            } else {
                event.from.x = offset;
                event.to.x = event.from.x + (event.positive ? event.from.width: -event.from.width);
            }
        }
        public function get executeTweenOffset():Number 
        {
            if (_useAlphaTransitions)
                return _current.from.alpha;
            return _current.from.x;
        }
    }
}