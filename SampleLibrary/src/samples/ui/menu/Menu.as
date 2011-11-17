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
package samples.ui.menu {
    
    import samples.events.MenuEvent;
    import samples.ui.components.Background;
    
    import caurina.transitions.Tweener;
    
    import flash.events.Event;
    import flash.events.MouseEvent;
    
    import qnx.events.QNXApplicationEvent;
    import qnx.system.QNXApplication;
    import qnx.ui.core.Container;
    import qnx.ui.core.ContainerFlow;
    import qnx.ui.core.SizeMode;
    import qnx.ui.core.SizeUnit;
    import qnx.ui.core.UIComponent;
    
    public class Menu extends Container 
    {
        public static const NAVMENU_HEIGHT_LANDSCAPE:int = 50;
        public static const NAVMENU_HEIGHT_PORTRAIT:int = 100;
        public static const EXPANDEDMENU_HEIGHT:int = 150
        
        private var _subMenu:ExpandedMenu;
        private var _modal:ModalWindow;
        private var _expanded:Boolean;
        private var _navigation:NavigationMenu;
        private var _handler:IMenuHandler;
        private var _backgroundLandscape:UIComponent = new Background(Background.MenuLandscapeBackground);
        private var _backgroundPortrait:UIComponent = new Background(Background.MenuPortraitBackground);
		private var _backgroundNavigationExpandedMenu:UIComponent = new Background(Background.ExpandedMenuHorizontalBackground);
        private var _hasSearchField:Boolean;
		
        /**
         * Menu that should be docked to the top of a view and supports SLIDE_DOWN to show additionnal content
         *  
         * @param handler - a IMenuHandler used to provide a search history and a list of thumbnails to keep a browsing history
         * @param home - a localized string for the "Home" shortcut of the expanded menu
         * @param options - a localized string for the "Options" shortcut of the expanded menu.  Shortcut will not appear if string is null.
         * @param help - a localized string for the "Help" shortcut of the expanded menu.  Shortcut will not appear if string is null.
         * @param helpContext - a string identifier for the help site.
         * @param navigationBackgroundLandscape - background for navigation bar (landscape).
         * @param navigationBackgroundPortrait - background for navigation bar (portrait).
         * @param back - a localized string for the "Back" button.  
         * @param hasSearchField - boolean to determine of search field should be included in navigation menu.
         */        
        public function Menu(handler:IMenuHandler=null, home:String="Home", options:String="Options", help:String=null, helpContext:String = null,navigationBackgroundLandscape:UIComponent=null, navigationBackgroundPortrait:UIComponent=null, back:String=null, hasSearchField:Boolean=true,navigationBackgroundExpandedMenu:UIComponent=null) 
        {
            super();
            
            flow = ContainerFlow.VERTICAL;
            _handler = handler;
            
			if(navigationBackgroundExpandedMenu != null){
				_backgroundNavigationExpandedMenu =  navigationBackgroundExpandedMenu;
			}
			
            _subMenu = new ExpandedMenu(_handler, home, options, help, helpContext,_backgroundNavigationExpandedMenu);
            addChild(_subMenu);
            
            if (navigationBackgroundLandscape != null){
                _backgroundLandscape = navigationBackgroundLandscape;
            }
            if (navigationBackgroundPortrait != null){
                _backgroundPortrait = navigationBackgroundPortrait;
            }
            
            _hasSearchField = hasSearchField;
            _navigation = new NavigationMenu(_handler, back, _backgroundLandscape, true, true, hasSearchField, hasSearchField);
            addChild(_navigation);
            
            _modal = new ModalWindow();
            _modal.visible = false;
            addChildAt(_modal, 0);
            
            sizeUnit = SizeUnit.PIXELS;
            sizeMode = SizeMode.BOTH;
            
            _subMenu.addEventListener(MenuEvent.HOME_CLICKED, collapseMenu, false, 0, true);
            _subMenu.addEventListener(MenuEvent.OPTIONS_CLICKED, collapseMenu, false, 0, true);
            _subMenu.addEventListener(MenuEvent.HISTORY_ITEM_CLICKED, collapseMenu, false, 0, true);
            
            _navigation.addEventListener(MenuEvent.ITEM_CLICKED, collapseMenu, false, 0, true);
            _navigation.addEventListener(MenuEvent.SEARCH, collapseMenu, false, 0, true);
            _navigation.addEventListener(MenuEvent.BACK, collapseMenu, false, 0, true);
            
            QNXApplication.qnxApplication.addEventListener(QNXApplicationEvent.SWIPE_DOWN, onSwipeDown);
            
            addEventListener(MouseEvent.MOUSE_DOWN, stopPropagation, false, 0, true);
        }
        
		/**
		 * Update strings when locale changes
		 * @param home - a localized string for the "Home" shortcut of the expanded menu
		 * @param options - a localized string for the "Options" shortcut of the expanded menu.  
		 * @param help - a localized string for the "Help" shortcut of the expanded menu.  
		 * @param back - a localized string for the "Back" button.  
		*/  
        public function localeChanged(home:String, options:String, help:String, back:String):void 
        {
            _navigation.localeChanged(back);
        }
        
		/**
		 * Destroy this instance of menu
		 */ 
        public override function destroy():void 
        {
            super.destroy();
            QNXApplication.qnxApplication.removeEventListener(QNXApplicationEvent.SWIPE_DOWN, onSwipeDown);
            removeEventListener(MouseEvent.MOUSE_DOWN, stopPropagation);
        }
        
        private function stopPropagation(event:MouseEvent):void 
        {
            event.stopImmediatePropagation();
        }
        
        /**
         * Sets the width and height of the component.
         * <p>
         * After setting the new dimensions, the <code>setSize</code> function calls the <code>draw</code> method, which allows you to adjust the layout
         * or redraw your component's children.
         * </p>
         * @param w The new width of the component.
         * @param h The new height of the component.
         * @see #draw()
         **/
        public override function setSize(w:Number, h:Number):void 
        {
            if(w >0 && h>0)
            {
                var navBarHeight:int = (stage.stageWidth > stage.stageHeight) ? NAVMENU_HEIGHT_LANDSCAPE : NAVMENU_HEIGHT_PORTRAIT;
                if (!_hasSearchField)
                {
                    navBarHeight = NAVMENU_HEIGHT_LANDSCAPE;
                }
                super.setSize(w, navBarHeight);
                if (_navigation)
                {
                    _subMenu.setSize(w, EXPANDEDMENU_HEIGHT);
                    _subMenu.size = EXPANDEDMENU_HEIGHT;
                    if (navBarHeight == NAVMENU_HEIGHT_PORTRAIT){
                        _navigation.background = _backgroundPortrait;
                    }else{
                        _navigation.background = _backgroundLandscape;
                    }
                    _navigation.setSize(w, navBarHeight);
                    size = navBarHeight;
                }
            }
        }
        
        protected override function draw():void 
        {
            collapseMenu(null);
            
            super.draw();
            
            // Use one pixel offset to avoid the background to flicker when animating the menu
            _subMenu.y = -_subMenu.size + 1;
            
            layout();
        }
        
		/**
		 * Expand (or collapse) the extended menu on swipe down.
		 * @param event - QNXApplicationEvent 
		 */  
        public function onSwipeDown(event:QNXApplicationEvent):void 
        {
            // Only if the menu is visible and enabled
            if(visible && enabled)
            {
                if (_expanded) {
                    collapseMenu(event);
                    return;
                }
                
                _expanded = true;
                _modal.addEventListener(MouseEvent.MOUSE_DOWN, collapseMenu, false, 0, true);
                
                //refresh history before tweening so as to remove flickering effect;
                _subMenu.refreshHistory();
                // Use one pixel offset to avoid the background to flicker when animating the menu
                Tweener.addTween(this, {time:0.5, y:_subMenu.size-1, transition:"easeOutExpo", onComplete:modalWindow});
            }
        }
        
        private function modalWindow():void 
        {
            _modal.visible = _expanded;
            _modal.setRectangle(0, -_subMenu.size, width, stage.stageHeight);
        }
        
		/**
		 * Collapse the extended menu.
		 * @param event - Event 
		 */  
		public function collapseMenu(event:Event):void 
        {
            if (!_expanded)
                return;
            
            _expanded = false;
            _modal.visible = false;
            _modal.removeEventListener(MouseEvent.MOUSE_DOWN, collapseMenu);
            
            if (event) {
                Tweener.addTween(this, {time:0.5, y:0, transition:"easeOutExpo"});
            } else {
                this.y = 0;
                invalidate();
            }
        }
        
		/**
		 * Returns the navigation menu
		 */ 
        public function get Navigation():NavigationMenu 
        {
            return _navigation;
        }
        
		/**
		 * Returns the expanded menu
		 */ 
		public function get Expansion():ExpandedMenu 
        {
            return _subMenu;
        }
        
		
		/**
		 * Enable/disable navigation menu functionality
		 * @param enabledValue - boolean to enable/disable fuctionality. 
		 */ 
		public function enableMenu(enabledValue:Boolean):void
        {
            enabled = enabledValue;
            
            if(!enabledValue)
            {
                _navigation.removeEventListener(MenuEvent.ITEM_CLICKED, collapseMenu);
                _navigation.removeEventListener(MenuEvent.SEARCH, collapseMenu);
                _navigation.removeEventListener(MenuEvent.BACK, collapseMenu);
            }
            else
            {
                _navigation.addEventListener(MenuEvent.ITEM_CLICKED, collapseMenu, false, 0 , true);
                _navigation.addEventListener(MenuEvent.SEARCH, collapseMenu, false, 0 , true);
                _navigation.addEventListener(MenuEvent.BACK, collapseMenu, false, 0 , true);
            }
        }
        
    }
}