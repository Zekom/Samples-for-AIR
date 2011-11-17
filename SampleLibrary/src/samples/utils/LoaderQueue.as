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

package samples.utils
{
    import flash.display.Loader;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.events.TimerEvent;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.utils.Timer;
    
    /**
     * A LoaderQueue appends network requests in one large queue and each request is sequentially performed 
     * to avoid network congestion and reduce any potential UI lag. If a request doesn't complete within 5 seconds,
     * the next request is executed.
     *  
     */    
    public class LoaderQueue extends EventDispatcher
    {
        private static var _network:Object;
        
        private var _queue:Vector.<Object>;
        private var _isActive:Boolean;
        private var _current:Object;
        // Dog watch
        private var _tmr:Timer;
        
        // Support pausing and resuming the queue
        private var _paused:Boolean = false;
        
        private static const LOADER_ADDED:String       = "samples.utils.LoaderQueue.LOADER_ADDED";
        private static const LOADER_COMPLETED:String   = "samples.utils.LoaderQueue.LOADER_COMPLETED";
        private static const LOADER_BLOCKED:String     = "samples.utils.LoaderQueue.BLOCKED";
        private static const LOADER_UNBLOCKED:String   = "samples.utils.LoaderQueue.UNBLOCKED";
        
        private static var TIME_OUT:int = 15 * 1000;
        
        //static
        {
            _network = new Object();
            _network.blocking = false;
            _network.dispatcher = new EventDispatcher();
        }
        
        /**
         * Instantiates a new queue. One application can use more than one queue to allow concurrent network requests. <p/>
         * E.g. having one queue to fetch data and one for images.
         * */
        public function LoaderQueue()
        {
            _queue = new Vector.<Object>();
            addEventListener(LOADER_ADDED, onLoaderAdded);
            addEventListener(LOADER_COMPLETED, onLoaderCompleted);
            
            _network.dispatcher.addEventListener(LOADER_BLOCKED, onNetworkConnectionLost);
            _network.dispatcher.addEventListener(LOADER_UNBLOCKED, onNetworkConnectionRestored);
            
            _tmr = new Timer(TIME_OUT);
            _tmr.addEventListener(TimerEvent.TIMER, dogKicked);
        }
        
        /**
         * Clean disposal of a LoaderQueue. 
         */        
        public function dispose():void
        {
            removeEventListener(LOADER_ADDED, onLoaderAdded);
            removeEventListener(LOADER_COMPLETED, onLoaderCompleted);
            
            _network.dispatcher.removeEventListener(LOADER_BLOCKED, onNetworkConnectionLost);
            _network.dispatcher.removeEventListener(LOADER_UNBLOCKED, onNetworkConnectionRestored);
            
            _tmr.removeEventListener(TimerEvent.TIMER, dogKicked);
            _tmr = null;
            
            for each (var obj:Object in _queue) {
                clearListeners(obj);
            }
        }
        
        /**
         * Blocks or unblocks the queue. Useful if the network goes down and you want to avoid the queue requests to fail.
         *  
         * @param value set this to true if you want to pause the queue, false to resume it
         */        
        public static function set blocked(value:Boolean):void 
        {
            if (_network.blocking == value) return;
            
            _network.blocking = value;
            // If we were halted but and our queue has items, resume
            if (!_network.blocking) {
                _network.dispatcher.dispatchEvent(new Event(LOADER_UNBLOCKED));
            } else {
                _network.dispatcher.dispatchEvent(new Event(LOADER_BLOCKED));
            }
        }
        
        /**
         * @return The current blocked stated of the queue.
         */        
        public static function get blocked():Boolean 
        {
            return _network.blocking;
        }
        
        /**
         * Appends a new loader-request to the queue
         *  
         * @param loader    the Loader or URLLoader object that will be used to perform a network request
         * @param req   the URLRequest to perform 
         * @param priority  if true, the request will be added at the top of the queue, and will be the next one executed.
         */        
        public function add(loader:Object, req:URLRequest, priority:Boolean=false):void 
        {
            var obj:Object = new Object();
            obj.loader = loader;
            obj.req = req;
            if (priority)
                _queue.unshift(obj);
            else
                _queue.push(obj);
            dispatchEvent(new Event(LOADER_ADDED));
        }
        
        /**
         * Removes a loader from the queue
         * 
         * @param loader
         * @param req
         * 
         */        
        public function remove(loader:Object, req:URLRequest):void
        {
            // We set the url to null so we'll skip the entry later on
            if (req.url)
                req.url = null;
        }
        
        /**
         * Intentionnally pause or resume a queue. 
         * <p/>
         * E.g. a user changes the currently viewable item while thumbnails are being loaded. 
         * We probably want to pause loading thumbnails as they have become background, non-visible objects. 
         * And we'll want to resume when they become visible again.
         *  
         * @param value
         * 
         */        
        public function set paused(value:Boolean):void
        {
            _paused = value;
            if (!value)
                dispatchEvent(new Event(LOADER_COMPLETED));
        }
        
        private function onLoaderCompleted(event:Event):void 
        {
            _current = null;
            // Perform the request if our queue is empty and we're not paused and the network is available
            if (_queue.length > 0 && !_paused && !_network.blocking) {
                _current = _queue.shift();
                execute();
            } else {
                _tmr.stop();
            }
        }
        
        private function onLoaderAdded(event:Event):void 
        {
            if (_current == null && !_network.blocking) {
                _tmr.start(); // dog watch
                _current = _queue.shift();
                execute();
            }
        }
        
        private function execute():void 
        {
            // Sometimes a query seems to die without throwing any event
            _tmr.reset();
            _tmr.start();
            
            // The url was set to null, skip this entry
            if (_current.req.url == null) {
                dispatchEvent(new Event(LOADER_COMPLETED));
                return;
            }
            
            if (_current.loader is Loader) {
                _current.loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
                _current.loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIoError, false, 1);
                _current.loader.contentLoaderInfo.addEventListener(Event.UNLOAD, unloaded);
                
            } else if (_current.loader is URLLoader){
                _current.loader.addEventListener(IOErrorEvent.IO_ERROR, onIoError, false, 1);
                _current.loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onIoError, false, 1);
                _current.loader.addEventListener(Event.COMPLETE, onComplete);
                _current.loader.addEventListener(Event.UNLOAD, unloaded);
                //(_current.req as URLRequest).idleTimeout = TIME_OUT;
            }
            
            _current.loader.load(_current.req);
        }
        
        private function onNetworkConnectionLost(event:Event):void 
        {
            _tmr.stop();
        }
        
        private function onNetworkConnectionRestored(event:Event):void 
        {
            if (_current)
                execute();
            else if (_queue.length > 0) {
                onLoaderAdded(null);
            }
        }
        
        private function onComplete(event:Event):void 
        {
            clearListeners(event.target);
            dispatchEvent(new Event(LOADER_COMPLETED));
        }
        
        private function onIoError(event:Event):void
        {
            clearListeners(event.target);
            // Halt the queue until the network connection is re-established
            if (!_network.blocking)
                dispatchEvent(new Event(LOADER_COMPLETED));
            else
                event.stopImmediatePropagation();
        }
        
        private function unloaded(event:Event):void 
        {
            clearListeners(event.target);
            dispatchEvent(new Event(LOADER_COMPLETED));
        }
        
        private function dogKicked(event:TimerEvent):void 
        {
            //trace("LoaderQueue - dog barfed");
            if (!_network.blocking)
                dispatchEvent(new Event(LOADER_COMPLETED));
        }
        
        private function clearListeners(obj:Object):void 
        {    
            if (obj is Loader) {
                obj.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
                obj.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onIoError);
                obj.contentLoaderInfo.removeEventListener(Event.UNLOAD, unloaded);
                
            } else if (obj is URLLoader) {
                obj.removeEventListener(IOErrorEvent.IO_ERROR, onIoError);
                obj.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onIoError);
                obj.removeEventListener(Event.COMPLETE, onComplete);
                obj.removeEventListener(Event.UNLOAD, unloaded);
            }
        }
    }
}