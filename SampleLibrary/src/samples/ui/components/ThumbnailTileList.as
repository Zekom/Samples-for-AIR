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
    import flash.display.DisplayObject;
    import flash.events.Event;
    
    import qnx.locale.LocaleManager;
    import qnx.ui.core.UIComponent;
    import qnx.ui.events.ScrollEvent;
    import qnx.ui.listClasses.ICellRenderer;
    import qnx.ui.listClasses.TileList;
    
    public class ThumbnailTileList extends TileList
    {
        public static const REACHING_END_OF_LIST:String = "samples.ui.components.ThumbnailTileList.REACHING_END_OF_LIST";
        private var _eventInProgress:Boolean;
        
        public function ThumbnailTileList(refreshOnLocaleChanges:Boolean=false)
        {
            super();
            scrollBarColor = 0xFFFFFF;
            setSkin(ThumbnailRenderer);			
            rowHeight = 200;
            columnWidth = 200;
            scrollBarOffset = 5;
            
            addEventListener(ScrollEvent.SCROLL_BEGIN, onBegin);
            addEventListener(ScrollEvent.SCROLL_END, onEnd);
            
            if(refreshOnLocaleChanges){
              LocaleManager.localeManager.addEventListener(Event.CHANGE, localeChanged, false, 0, true);
            }
        }
        
        protected function verifyPaging():void 
        {
            if (!lastVisible)
                return;
            
            var pos:int = getItemPosition(lastVisible as DisplayObject);
            var total:int = getTotalMeasurement();
            var cellSize:int = getRowMeasurement();
            
            // Advise new items should be loaded when we reach the end
            // two rows: getRowMeasurement() * 2
            // 50%: total / 2
            if (!_eventInProgress && (pos > total - 2 * cellSize)) {
                _eventInProgress = true;
                dispatchEvent(new Event(REACHING_END_OF_LIST));
            }
        }
        
        private function onBegin(e:ScrollEvent):void 
        {
            Thumbnail.blocked = true;
            
            if (!lastVisibleItem)
                return;
            
            for (var i:int=firstVisibleIndex - 1; i<=lastVisibleItem.index + 1; i++) {
                var cell:ICellRenderer = getCellAtIndex(i);
                if (cell is ThumbnailRenderer) {
                    (cell as ThumbnailRenderer).cancelThumbnailLoad();
                }
            }
        }
        
        private function onEnd(e:ScrollEvent):void 
        {
            Thumbnail.blocked = false;
            
            if (!lastVisibleItem)
                return;
            
            // Do this before we load thumbnails
            verifyPaging();
            
            for (var i:int=firstVisibleIndex; i<=lastVisibleItem.index + 1; i++) {
                // Immediately stop loading thumbnails if user started scrolling
                if (Thumbnail.blocked) 
                    return;
                
                var cell:ICellRenderer = getCellAtIndex(i);
                if (cell is ThumbnailRenderer) {
                    (cell as ThumbnailRenderer).loadThumbnail();
                }
            }
        }
        
        protected override function onAdded():void 
        {
            super.onAdded();
            onEnd(null);
        }
        
        public override function destroy():void 
        {
            for each (var cell:ICellRenderer in __drawnItems) {
                if (cell is UIComponent)
                    (cell as UIComponent).destroy();
            }
            
            super.destroy();
            LocaleManager.localeManager.removeEventListener(Event.CHANGE, localeChanged);
        }
        
        public function get firstVisibleCellIndex():int 
        {
            if (firstVisibleItem)
                return super.firstVisibleIndex;
            else
                return 0;
        }
        
        public function get lastVisibleCellIndex():int 
        {
            if (lastVisibleItem)
                return super.lastVisibleItem.index
            else 
                return 0;
        }
        
        public function clearEvent(moreDataLoaded:Boolean=true):void 
        {
            _eventInProgress = !moreDataLoaded;
        }
        
        public function refresh():void 
        {
            // Skip refresh if list is empty
            if (firstVisible == null || lastVisibleItem == null)
                return;
            
            for (var i:int=firstVisibleIndex; i<=lastVisibleItem.index; i++) {
                var cell:ICellRenderer = getCellAtIndex(i);
                cell.data = dataProvider.data[i];
            }
        }
        
        private function localeChanged(evt:Event):void
        {
            refresh();
        } 
    }
}