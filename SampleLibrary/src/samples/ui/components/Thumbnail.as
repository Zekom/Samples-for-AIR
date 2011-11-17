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

package samples.ui.components {
    
    import caurina.transitions.Tweener;
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.events.Event;
    
    import samples.cache.Cache;
    import samples.events.CacheEvent;
    
    
    /**
     * 
     * NOTE: This class caches images to the file system and is only necessary if your application 
     * is downloading large quantities of images and keeping them for extended periods of time. 
     * Otherwise, @see <code>Image</code> and <code>ImageCache</code>. 
     * 
     * Extends the Bitmap class by caching any image to the filesystem. If stretch or scale is set to true, 
     * it will also attempt to resize the image to fit the width or height set before the url is set. The resulting thumbnail 
     * size can be read by listening to a Event.CHANGE event. <br/>
     * Developers can block images from loading by using the blocked static member. This was added to block thumbnails 
     * while the user is scrolling through a list.
     * 
     * <pre>
     * <code>
     * private function addThumbnail(url:String, availableWidth:int, availableHeight:int) {
     *     var thumb:Thumbnail = new Thumbnail;
     *     thumb.width = availableWidth;
     *     thumb.height = availableHeight;
     *     thumb.addEventListener(Event.CHANGE, onSizeChanged);
     *     thumb.url = url;
     * }
     * 
     * private function onSizeChanged(event:Event) {
     *     trace(event.target.width);
     *     trace(event.target.height);
     *     trace(event.target.bitmapData.width);
     *     trace(event.target.bitmapData.height);
     * }
     * </code>
     * </pre>
     * 	@see #blocked blocked
     * 	@see #scale scale
     * 	@see #stretch stretch
     * */
    public class Thumbnail extends Bitmap 
    {
        /** Blocks the load() method of every thumbnail to avoid sending network requests and potentially causing UI lag */
        public static var blocked:Boolean;
        
        private static var _cache:Cache = Cache.instance;
        private var _url:String;
        
        private var _width:Number;
        private var _height:Number;
        private var _customeCacheName:String;
        private var _stretch:Boolean = true;
        private var _scale:Boolean = true;
        
        
        /** Sets the desired width */
        public override function set width(value:Number):void {
            _width = value;
            
            if (bitmapData)
                super.width = _width;
        }
        
        /** Sets the desired height */
        public override function set height(value:Number):void {
            _height = value;
            
            if (bitmapData)
                super.height = _height;
        }
        
        public function get url():String {
            return _url;
        }
        
        /**
         * Sets the image url to load, then calls load() unless Thumbnail.blocked is true.
         * @see #blocked blocked 
         * */
        public function set url(value:String):void 
        {
            if (value == null || value == "") return;
            
            _url = value;
            // Do not fetch the image unless it is already in memory
            if (!blocked || _cache.getBitmapData(_customeCacheName ? _customeCacheName: _url, true))
                load();
        }
        
        public function set customeCacheName(name:String):void 
        {
            _customeCacheName = name;
        }
        
        /**
         * Will attempt to stretch the image to fill all the available width and height set after the bitmap data is loaded 
         * */
        public function set stretch(value:Boolean):void 
        {
            _stretch = value;
            _scale = !value;
        }
        
        /**
         * Will scale the image to fit the available width and height previously set 
         * */
        public function set scale(value:Boolean):void 
        {
            _scale = value;
            _stretch = !value;
        }
        
        /**
         * Loads an image after the url has been set.
         * @param force  Will attempt to load/reload the image, regardless if we already have bitmapData. In some cases,  
         *               this can be useful to swap a current thumbnail with a different one, but keeping the current image 
         *               until the next one is ready.
         **/
        public function load(force:Boolean=false):void 
        {
            if (_url == null && _customeCacheName == null || (bitmapData && !force))
                return;
            
            var tmpData:BitmapData = _cache.getBitmapData(_customeCacheName ? _customeCacheName : _url);
            if (tmpData == null) {
                _cache.addEventListener(_customeCacheName ? _customeCacheName : _url, loadCompleteHandler);
                _cache.loadBitmapData(_url, false, _customeCacheName);
            } else if (bitmapData != tmpData) {
                bitmapData = tmpData;
            }
            
            if (bitmapData) {
                fitImage();
            } else {
                height = _height;
            } 
        }
        
        public function cancelLoad():void
        {
            if (_url || _customeCacheName) {
                _cache.removeEventListener(_customeCacheName ? _customeCacheName : _url, loadCompleteHandler);
            }
        }
        
        public function dispose():void 
        {
            bitmapData = null;
            if (_url) {
                _cache.disposeBitmapData(_customeCacheName ? _customeCacheName : _url);
                _cache.removeEventListener(_customeCacheName ? _customeCacheName : _url, loadCompleteHandler);
            }
            _url = null;
        }
        
        private function loadCompleteHandler(event:CacheEvent):void 
        {
            if (_url == null) {
                return;
            }
            
            _cache.removeEventListener(_url, loadCompleteHandler);
            var doTween:Boolean = true;
            if (bitmapData)
                doTween = false;
            
            bitmapData = _cache.getBitmapData(_customeCacheName ? _customeCacheName : _url);
            
            if (bitmapData) {
                fitImage();
            } else {
                height = _height;
            }
            
            if (doTween) {
                alpha = 0;
                Tweener.addTween(this, {time:0.5, alpha:1, transition:"linear"});
            }
        }
        
        private function fitImage():void 
        {
            if (_scale) {
                if (bitmapData.height < bitmapData.width) {
                    super.width = _width;
                    super.height = _height * (bitmapData.height / bitmapData.width);
                } else {
                    super.height = _height;
                    super.width = _width * (bitmapData.width / bitmapData.height);
                }
                dispatchEvent(new Event(Event.CHANGE));
            }
            
            if (_stretch) {
                if (bitmapData.height < bitmapData.width) {
                    super.height = _height;
                    super.width = _width * (bitmapData.width / bitmapData.height);
                } else {
                    super.width = _width;
                    super.height = _height * (bitmapData.height / bitmapData.width);
                }
                dispatchEvent(new Event(Event.CHANGE));
            }
        }
    }
}