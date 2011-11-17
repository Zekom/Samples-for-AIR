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
package samples.cache 
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.display.Stage;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.net.URLRequest;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    import flash.utils.Timer;
    
    import samples.events.CacheEvent;
    import samples.utils.LoaderQueue;
    
    import qnx.events.QNXApplicationEvent;
    import qnx.system.QNXApplication;
    
    //TODO There is no error handling (what if the img doesn’t exist on the server?)
    
    /**
     * Example
     * <pre>
     * <code>
     * private function setup():void 
     * {
     *     var cache:Cache = Cache.instance;
     *     if (cache.getBitmapData(_url) == null) {
     *         cache.addCacheEventListener(_url, loadCompleteHandler);
     *         cache.loadBitmapData(_url);
     *     }
     * } 
     
     * private function loadCompleteHandler(event:Event):void 
     * {
     *     cache.removeEventListener(CacheEvent.BITMAP_LOAD_COMPLETE, loadCompleteHandler);
     *     bitmapData = cache.getBitmapData(_url);
     * }
     * </code>
     * </pre>
     */
    public class Cache extends EventDispatcher
    {
        protected var bitmapCache:Dictionary;
        protected static var _instance:Cache;
        private static var _stage:Stage;
        
        private static var CACHE_ROOT:String        = "cache/";
        private static var CACHE_ROOT_IMAGES:String = CACHE_ROOT + "images/";
        private static var CACHE_ROOT_IMAGES_EXTENSION:String = ".png";
        
        private var _timer:Timer;
        protected var _interrupted:Boolean = false;
        private static var _cacheCleared:Boolean = false;
        
        private static var _loaderQueue:LoaderQueue = new LoaderQueue();
        
        public function Cache():void 
        {
            bitmapCache = new Dictionary();
            
            if (_stage) {
                _timer = new Timer(3000);
                _timer.addEventListener(TimerEvent.TIMER, onUserIdle);
                _stage.addEventListener(MouseEvent.MOUSE_MOVE, onUserPresent);
            }
            
            QNXApplication.qnxApplication.addEventListener(QNXApplicationEvent.LOW_MEMORY, clearCache);
            QNXApplication.qnxApplication.addEventListener(Event.ACTIVATE, onUserPresent);
            QNXApplication.qnxApplication.addEventListener(Event.DEACTIVATE, dispose);
        }
        
        public static function get instance():Cache 
        {
            if (!_instance) {
                _instance = new Cache();
            }
            return _instance;
        }
        
        public static function set stage(stage:Stage):void {
            _stage = stage;
        }
        
        public function getBitmapData(name:String, weakReference:Boolean=false):BitmapData 
        {
            if (bitmapCache[name] == null)
                return null;
            
            if (!weakReference) {
                var refCount:int = bitmapCache[name].refCount as int;
                bitmapCache[name].refCount = refCount ? refCount + 1: 1;
                // Output cache refcounts for debugging purposes
                //trace(bitmapCache[name].refCount);
            }
            return bitmapCache[name].data;
        }
        
        public function setBitmapData(name:String, data:BitmapData):void 
        {
            if (bitmapCache[name] == null) {
                bitmapCache[name] = new Object();
                bitmapCache[name].refCount = 1;
            }
            bitmapCache[name].data = data;
        }
        
        public function disposeBitmapData(name:String):void 
        {
            if (bitmapCache[name] == null)
                return;
            
            var refCount:int = bitmapCache[name].refCount as int;
            bitmapCache[name].refCount = refCount ? refCount - 1: 0;
            
            if (bitmapCache[name].loader)
                bitmapCache[name].loader.unloadAndStop(false); // Do not force the GC
        }
        
        protected function getFileName(i_url:String):String
        {
            i_url = i_url.replace(/[^A-Za-z0-9]+/g, "_");
            i_url += CACHE_ROOT_IMAGES_EXTENSION;
            return i_url;
        }
        
        public function loadBitmapData(url:String, fsOnly:Boolean, customName:String=null):void
        {
            var logString:String = "Loading Bitmap " + url;
            var value:String = customName ? customName : url;
            
            if (bitmapCache[value] && bitmapCache[value].data) {
                logString += " ... from memory";
                dispatchEvent(new CacheEvent(value));
            }
            else {
                if (loadLocal(value)) {
                    logString += " ... from local filesystem";
                    
                } else if (!fsOnly) {
                    logString += " ... from server";
                    loadRemote(url, customName);
                    
                } else {
                    dispatchEvent(new CacheEvent(value, false));
                }
            }
            
            //trace(logString);    
        }
        
        //-------------------------------------
        //  load the bmp from LOCAL filesystem
        //-------------------------------------
        protected function loadLocal(url:String):Boolean 
        {
            var file:File = File.applicationStorageDirectory;
            file = file.resolvePath(CACHE_ROOT_IMAGES + getFileName(url));
            if (!file.exists) 
                return false;
            
            var stream:FileStream = new FileStream();
            var onFileOpened:Function = function onFileOpened(event:Event):void
            {
                try {
                    var byteArray:ByteArray = new ByteArray();
                    stream.readBytes(byteArray, 0, file.size);
                    
                    var loader:Loader = new Loader();
                    loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleLocalFileLoadComplete);
                    loader.name = url;
                    loader.loadBytes(byteArray);
                    
                    stream.close();
                    
                } catch (error:Error) {
                    // delete the local file and redownload it
                    if (stream)
                        stream.close();
                    
                    try{
                        if(file.exists){
                            file.deleteFile();
                        }
                    } catch (err:Error) {
                        // delete file quietly...
                    }
                    
                    loadRemote(url, null);
                }
            };
            stream.addEventListener( Event.COMPLETE, onFileOpened );
            stream.openAsync( file, FileMode.READ );
            
            return true;
        }
        
        protected function handleLocalFileLoadComplete(obj:Object):void
        {
            var event:Event = obj as Event;
            var name:String = event.target.loader.name as String;
            var localBitmapData:BitmapData = event.target.content.bitmapData;
            
            event.target.loader.removeEventListener(Event.COMPLETE, handleLocalFileLoadComplete);
            
            if (bitmapCache[name] == null)
                bitmapCache[name] = new Object();
            bitmapCache[name].data = event.target.content.bitmapData;
            bitmapCache[name].persisted = true;
            bitmapCache[name].image = event.target.bytes;
            
            dispatchEvent(new CacheEvent(name));
        }
        
        //-------------------------------------
        //  load the bmp from REMOTE filesystem
        //-------------------------------------
        protected function loadRemote(url:String, customName:String):void 
        {
            var urlRequest:URLRequest = new URLRequest(url);
            
            var loader:Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleRemoteFileLoadComplete);
            loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, cacheIoError);
            loader.name = customName ? customName : url;
            
            if (bitmapCache[loader.name] == null)
                bitmapCache[loader.name] = new Object();
            bitmapCache[loader.name].loader = loader;
            bitmapCache[loader.name].persisted = false;
            
            _loaderQueue.add(loader, urlRequest);
        }
        
        protected function cacheIoError(event:IOErrorEvent):void 
        {
            trace("ImageCache IO Error: " + event.text);
        }
        
        private function handleRemoteFileLoadComplete(event:Event):void 
        {
            var loader:Loader = event.target.loader as Loader;
            var loaderInfo:LoaderInfo = event.target as LoaderInfo;
            var bitmap:Bitmap = loaderInfo.content as Bitmap;
            var name:String = loader.name;
            
            loaderInfo.removeEventListener(Event.COMPLETE, handleRemoteFileLoadComplete);
            
            if (bitmapCache[name] == null)
                bitmapCache[name] = new Object();
            
            bitmapCache[name].data = bitmap.bitmapData;
            bitmapCache[name].image = event.target.bytes;
            
            dispatchEvent(new CacheEvent(name));
        }
        
        //-------------------------------------
        //  write the bmp to LOCAL filesystem as a png
        //-------------------------------------
        public function persistBitmapData(url:String, destinationPath:String=null):void 
        {
            var imgBytes:ByteArray = bitmapCache[url].image;
            if (imgBytes == null)
                return;
            
            var file:File = destinationPath == null 
                ? File.applicationStorageDirectory.resolvePath(CACHE_ROOT_IMAGES + getFileName(url))
                : new File(destinationPath);
            
            var errorHandler:Function = function(evt:IOErrorEvent):void {
                trace("Cache: can't write image " + url + " to folder " + file.nativePath);
            };
            
            // Write or overwrite the file
            var stream:FileStream = new FileStream();
            stream.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
            stream.openAsync( file, FileMode.WRITE );
            // Skip the first 49 bytes and last 17 bytes. The image is wrapped within a SWF
            // source: http://www.jamesward.com/2009/07/09/flex-example-right-click-save-image-as/
            stream.writeBytes(imgBytes, 49, imgBytes.length - 49 - 17);
            stream.close();
        }
        
        private function onUserIdle(event:Event):void 
        {
            // Return immediately if we're already disposing elements
            if (!_interrupted) return;
            
            // Stop the timer until we get interrupted
            if (_timer)
                _timer.stop();
            
            _interrupted = false;
            
            persistItems();
            
            // Release the lock
            _interrupted = true;
        }
        
        protected function persistItems(force:Boolean=false):void 
        {
            // Persist in memory items, delete those who have no reference
            for (var name:String in bitmapCache) {
                if (_interrupted && !force) {
                    onUserPresent(null);
                    return;
                }
                
                if (!bitmapCache[name].persisted && bitmapCache[name].image) {
                    persistBitmapData(name);
                    bitmapCache[name].persisted = true;
                }
                
                if (bitmapCache[name].refCount == 0 && bitmapCache[name].data) {
                    bitmapCache[name].data.dispose();
                    bitmapCache[name].data = null;
                    bitmapCache[name].image = null;
                    delete bitmapCache[name];
                }
            }
        }
        
        private function onUserPresent(event:Event):void 
        {
            _interrupted = true;
            if (_timer) {
                _timer.reset();
                _timer.start();
            }
        }
        
        private function clearCache(event:Event):void 
        {
            bitmapCache = new Dictionary();
        }
        
        public function dispose(event:Event=null):void 
        {
            // Free up as much memory as possible when app is going to sleep
            if (_timer)
                _timer.stop();
            persistItems(true);
            
            // We only want to perform this task once during the application lifetime
            if (_cacheCleared)
                return;
            
            _cacheCleared = true;
            
            var file:File = File.applicationStorageDirectory;
            file = file.resolvePath(CACHE_ROOT_IMAGES);
            
            // Return if no folder exists
            if (!file.exists)
                return;
            
            var files:Array = file.getDirectoryListing();
            
            // Delete any file older than 30 days
            var time:Number = new Date().time - 30 * 24 * 60 * 60 * 1000;
            for each (file in files) {
                try {
                    if (file.modificationDate.time < time) {
                        file.deleteFileAsync();
                    }
                } catch (error:Error) {
                    trace("Cache diposal error: " + error.message);
                }
            }
        }
    }
}