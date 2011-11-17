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

package samples.ui.components
{
    import flash.geom.Matrix;
    
    import samples.cache.Cache;
    
    import qnx.ui.listClasses.CellRenderer;
    
    public class ThumbnailRenderer extends CellRenderer
    {
        protected static var _cache:Cache = Cache.instance;
        protected var _thumbnail:Thumbnail;
        
        public function ThumbnailRenderer()
        {
            _thumbnail = new Thumbnail();
            
            cacheAsBitmap = true;
            cacheAsBitmapMatrix = new Matrix();
        }
        
        public override function destroy():void
        {
            super.destroy();
            
            if (_thumbnail) {
                _thumbnail.dispose()
            }
            _thumbnail = null;
        }
        
        public function loadThumbnail():void 
        {
            if (_thumbnail)
                _thumbnail.load();
        }
        
        public function cancelThumbnailLoad():void 
        {
            if (_thumbnail)
                _thumbnail.cancelLoad();
        }
    }
}