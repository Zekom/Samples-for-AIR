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

package samples.ui.menu
{
    import flash.events.Event;
    import flash.events.MouseEvent;
    
    import qnx.ui.buttons.RadioButtonGroup;
    import qnx.ui.core.Container;
    import qnx.ui.core.ContainerAlign;
    import qnx.ui.core.ContainerFlow;
    import qnx.ui.core.Containment;
    import qnx.ui.core.SizeUnit;
    import qnx.ui.listClasses.ScrollDirection;
    import qnx.ui.listClasses.ScrollPane;
    
    internal class MenuScrollPane extends Container
    {
        private var _scroll:ScrollPane;
        private var _items:Container;
        private var _selectedIndex:int = -1;
        private var _previousSelectedIndex:int = -1;
        
        public function MenuScrollPane()
        {
            _scroll = new ScrollPane();
            _scroll.scrollBarOffset = 0;
            _scroll.scrollDirection = ScrollDirection.HORIZONTAL;
            containment = Containment.DOCK_LEFT;
            align = ContainerAlign.NEAR;
            padding = 5;
            
            addChild(_scroll);
        }
        
        internal function set data(items:Array):void 
        {
            _items = new Container();
            _items.containment = Containment.DOCK_LEFT;
            _items.sizeUnit = SizeUnit.PIXELS;
            _items.flow = ContainerFlow.HORIZONTAL;
            _items.padding = padding;
            
            var grpName:String = "samples.ui.menu.MenuScrollPane";
            var grp:RadioButtonGroup = RadioButtonGroup.getGroup(grpName);
            var w:int;
            for (var i:int=0; i < items.length; i++) {
                var button:ClickableMenuItem = new ClickableMenuItem(i);
                button.label = items[i];
                _items.addChild(button);
                grp.addButton(button);
                button.groupname = grpName;
                button.addEventListener(MouseEvent.CLICK, onSelectionChanged);
                w += button.size + padding;
            }
            _items.width = w;
            _scroll.setScrollContent(_items);
        }
        
        protected override function draw():void 
        {
            super.draw();
            _scroll.setSize(width - ( padding * 2 ), height - padding);
            _scroll.y = (height - _scroll.height);
            _scroll.x = padding;
            _scroll.scrollX = 0;
            
            for (var i:int=0; i<_items.numChildren; i++) {
                var item:ClickableMenuItem = _items.getChildAt(i) as ClickableMenuItem;
                if (item.selected && (item.x + item.width) > width){
                    _scroll.scrollX = (item.x + item.width + padding) - width;
                    break;
                }
            }
            
            _items.setSize(_items.width, _scroll.height);
            _items.drawNow();
            _scroll.update();
        }
        
        private function onSelectionChanged(event:Event):void
        {
            var index:int = ClickableMenuItem( event.target ).index;
            selectedIndex = index;
            dispatchEvent(new Event(Event.CHANGE));
        }
        
        public function set selectedIndex(index:int):void 
        {
            
            var item:ClickableMenuItem; 
            if (_selectedIndex >= 0 && _selectedIndex < _items.numChildren) {
                item = _items.getChildAt(_selectedIndex) as ClickableMenuItem;
                item.selected = false;
            }
            
            if (index >= 0 && index < _items.numChildren) {
                item = _items.getChildAt(index) as ClickableMenuItem;
                item.selected = true;
            }
            _previousSelectedIndex = _selectedIndex; 
            _selectedIndex = index;
        }
        
        public function get selectedIndex():int 
        {
            return _selectedIndex;
        }
        public function get previousSelectedIndex():int
        {
            return _previousSelectedIndex;
        }
        
    }
}