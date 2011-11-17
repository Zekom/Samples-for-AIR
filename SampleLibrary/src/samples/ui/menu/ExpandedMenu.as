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
    import flash.display.Bitmap;
    import flash.events.MouseEvent;
    import flash.net.URLRequest;
    import flash.net.navigateToURL;
    
    import samples.events.MenuEvent;
    import samples.ui.components.DefaultHistoryRenderer;
    import samples.ui.components.IconLabel;
    
    import qnx.ui.core.Container;
    import qnx.ui.core.ContainerAlign;
    import qnx.ui.core.ContainerFlow;
    import qnx.ui.core.Containment;
    import qnx.ui.core.SizeUnit;
    import qnx.ui.core.UIComponent;
    import qnx.ui.data.DataProvider;
    import qnx.ui.events.ListEvent;
    import qnx.ui.listClasses.ScrollDirection;
    import qnx.ui.listClasses.TileList;
    
    public class ExpandedMenu extends Container
    {
        [Embed(source="/../assets/images/Shadow_divider.png")]
        private static var MenuDivider:Class;
        
        [Embed(source="/../assets/images/Featured_icon.png")]
        private static var HomeIcon:Class;
        
        [Embed(source="/../assets/images/settings.png")] 
        public static var Settings:Class;
        
        [Embed(source="/../assets/images/help_icon.png")] 
        public static var HelpIcon:Class;
        
        internal var _history:TileList;
        private var _background:UIComponent;
        
        private var _rightSection:Container;
        private var _leftSection:Container;
        private var _divider:Bitmap;
        private var _helpContext:String;
        
        private var _handler:IMenuHandler;
        /**
         * Create a menu with options, help buttons and browsing history. Swipe down from the top frame is required to expose this menu. 
         * 
         * @param handler A <code>IMenuHandler</code> instance. Must be of type <code>IMenuHandler</code>.
         * @param home A <code>String</code> for the "Home" button label.
         * @param options A <code>String</code> for the "Options" button label.
         * @param help A <code>String</code> for the "Help" button label.
         * @param helpContext A <code>String</code> the path or URL to launch broswer with for help documentation.
         * @param background  <code>UIComponent</code> graphic used for menu back ground.
         * 
         *  
         **/
        public function ExpandedMenu(handler:IMenuHandler, home:String, options:String, help:String = null, helpContext:String = null, background:UIComponent=null)
        {
            super();
            
            sizeUnit = SizeUnit.PIXELS;
            
            flow = ContainerFlow.HORIZONTAL;
            align = ContainerAlign.NEAR;
            containment = Containment.UNCONTAINED;
            
            _handler = handler;
            
            if(background)
            {
                _background = background;
                addChild(_background);
            }
            
            _leftSection = new Container();
            //_leftSection.debugColor = 0xFF0000;
            _history = new TileList();
            _history.size = 100;
            _history.sizeUnit = SizeUnit.PERCENT;
            _history.scrollDirection = ScrollDirection.HORIZONTAL;
            _history.setSkin(DefaultHistoryRenderer);
            _history.rowCount = 1;
            _history.columnWidth = 100;
            _history.rowHeight = 100;
            _history.cellPadding = 10;
            _history.addEventListener(ListEvent.ITEM_CLICKED, onHistoryItemClicked, false, 0, true);
            _leftSection.addChild(_history);
            addChild(_leftSection);
            
            _rightSection = new Container(250, SizeUnit.PIXELS);
            _rightSection.flow = ContainerFlow.HORIZONTAL;
            _rightSection.containment = Containment.DOCK_RIGHT;
            _rightSection.margins = Vector.<Number>([40, 0, 0, 0]);
            
            _divider = new MenuDivider() as Bitmap;
            _divider.y = -_divider.height;	
            addChild(_divider);
            
            var iconContainer:Container = new Container();
            iconContainer.flow = ContainerFlow.HORIZONTAL;			
            iconContainer.margins[1]=30;
            iconContainer.padding = 30;
            
            _rightSection.addChild(iconContainer);
            
            var homeIcon:IconLabel = new IconLabel(); 
            homeIcon.setImage(new HomeIcon());
            homeIcon.text = home;
            homeIcon.addEventListener(MouseEvent.CLICK, homeButtonHandler, false, 0, true);
            iconContainer.addChild(homeIcon);
            
            var optionsIcon:IconLabel = new IconLabel();
            optionsIcon.setImage(new Settings());
            optionsIcon.text = options;
            optionsIcon.addEventListener(MouseEvent.CLICK, optionsButtonHandler, false, 0, true);
            iconContainer.addChild(optionsIcon);
            
            if (help != null)
            {
                var helpIcon:IconLabel = new IconLabel();
                helpIcon.setImage(new HelpIcon());
                helpIcon.text = help;
                helpIcon.addEventListener(MouseEvent.CLICK, helpButtonHandler, false, 0, true);
                iconContainer.addChild(helpIcon);
                _helpContext = helpContext;
            }
            
            addChild(_rightSection);
        }
        
        /**
         * Called to set tile list for browsing history
         * @param tileList - TileList used to render browsing history
         */ 
        public function set browsingHistoryTileList(tileList:TileList):void
        {
            if(_leftSection.contains(_history))
            {
                _history.removeEventListener(ListEvent.ITEM_CLICKED, onHistoryItemClicked);
                _leftSection.removeChild(_history);
            }
            _history = tileList;
            _history.addEventListener(ListEvent.ITEM_CLICKED, onHistoryItemClicked, false, 0, true);
            _leftSection.addChildAt(_history,0);	
        }
        
        /**
         * Called to get the tile list for browsing history
         * @returns - TileList used to render browsing history
         */ 
        public function get browsingHistoryTileList():TileList
        {
            return _history;
        }
        
        /**
         * Called to set background for the navigation menu
         * @param background - UIcomponent that represents background for the menu
         */ 
        public function set background(background:UIComponent):void
        {
            if(_background && contains(_background))
            {
                removeChild(_background);
            }
            
            _background = background;
            addChildAt(_background, 0);
        }
        
        
        public function refreshHistory():void 
        {
            if (_handler) {
                var data:Array = _handler.getHistory();
                if (data != null)
                {
                    _history.dataProvider = new DataProvider(data);
                }
            }
        }
        
        private function onHistoryItemClicked(event:ListEvent):void 
        {
            var evt:MenuEvent = new MenuEvent(MenuEvent.HISTORY_ITEM_CLICKED);
            evt.param = event.data;
            dispatchEvent(evt);
        }
        
        private function optionsButtonHandler(event:MouseEvent):void
        {
            var evt:MenuEvent = new MenuEvent(MenuEvent.OPTIONS_CLICKED);
            dispatchEvent(evt);
        }
        
        private function helpButtonHandler(event:MouseEvent):void
        {
            //launch browser to Help URL     
            navigateToURL(new URLRequest( _helpContext));
        }
        
        private function homeButtonHandler(event:MouseEvent):void
        {
            var evt:MenuEvent = new MenuEvent(MenuEvent.HOME_CLICKED);
            dispatchEvent(evt);
        }
        
        protected override function draw():void
        {
            _background.setSize(width, size);
            
            _rightSection.x = width - _rightSection.size;
            
            _leftSection.setSize(_rightSection.x, size);
            _leftSection.x = 0;
            
            //vertically center the history list
            _leftSection.y = (height - _history.rowHeight)/2;
        }
        
        public function setHistoryRenderer(skin:Class, cellSize:int):void 
        {
            _history.setSkin(skin);
            _history.columnWidth = cellSize;
            _history.rowHeight = cellSize;
            
            _history.height = cellSize;
            
        }
    }
}