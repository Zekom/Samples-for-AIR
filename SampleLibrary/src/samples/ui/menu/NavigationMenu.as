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
    import caurina.transitions.Tweener;
    
    import flash.display.Bitmap;
    import flash.events.Event;
    import flash.events.FocusEvent;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.text.TextFormat;
    import flash.ui.Keyboard;
    
    import mx.utils.StringUtil;
    
    import samples.events.MenuEvent;
    import samples.ui.buttons.BackButtonSkinned;
    
    import qnx.ui.core.Container;
    import qnx.ui.core.SizeMode;
    import qnx.ui.core.SizeUnit;
    import qnx.ui.core.UIComponent;
    import qnx.ui.data.DataProvider;
    import qnx.ui.events.ListEvent;
    import qnx.ui.text.Label;
    import qnx.ui.text.ReturnKeyType;
    import qnx.ui.text.TextInputIMF;
    import qnx.ui.text.TextInputIconMode;
    
    public class NavigationMenu extends UIComponent
    {
        private static const SEARCH_FIELD_WIDTH:int = 250;
        
        [Embed(source="/../assets/images/Search.png")]
        private static var Search:Class;
        
        private var _currentScroll:Number = 0;
        public var _search:TextInputIMF;
        private var _searchHistory:SuggestionList;
        private var _title:String;
        private var _titleLabel:Label;
        private var _lastSearch:String;
        private var _showLastSearch:Boolean = true;
        
        private var _backButton:BackButtonSkinned;
        private var _extraContainer:Container;
        private var _background:UIComponent;
        private var _customLogo:Bitmap;
        private var _handler:IMenuHandler;
        private var _pane:MenuScrollPane;
        private var _backButtonAndTitleComponent:Container;
        
        /**
         * Navigation bar with navigation buttons and search field.  Part of menu component.
         * @param handler - a IMenuHandler used to provide a search history and a list of thumbnails to keep a browsing history
         * @param backText - a localized string for the "Back" button.  
         * @param background - navigation bar background component.
         * @param hasBackButton - boolean to determine if back button will be displayed.
         * @param hasTitleLabel - boolean to determine if title will be displayed.
         * @param hasSearchHistory - boolean to determine if search history should be displayed.
         * @param hasSearchField - boolean to determine if search field should be displayed.
         */ 
        public function NavigationMenu(handler:IMenuHandler, backText:String=null, background:UIComponent=null, hasBackButton:Boolean=true, hasTitleLabel:Boolean=true, hasSearchHistory:Boolean=true, hasSearchField:Boolean=true):void  
        {
            super();
            
            _handler = handler;
            
            sizeUnit = SizeUnit.PIXELS;
            sizeMode = SizeMode.BOTH;
            
            if(background)
            {
                _background = background;
                addChild(_background);
            }
            
            _pane = new MenuScrollPane();
            _pane.size = 100;
            _pane.sizeUnit = SizeUnit.PERCENT;
            _pane.addEventListener(Event.CHANGE, dispatchNavigateEvent, false, 0, true);
            addChild(_pane);
            
            if (hasSearchField)
            {
                _search = new TextInputIMF();
                _search.returnKeyType = ReturnKeyType.SEARCH;
                _search.addEventListener(KeyboardEvent.KEY_DOWN, handleSearchEnter, false, 0, true);
                _search.addEventListener(FocusEvent.FOCUS_IN, showSearchHistory, false, 0, true);
                _search.addEventListener(FocusEvent.FOCUS_OUT, hideSearchHistory, false, 0, true);
                _search.addEventListener(Event.CHANGE, showSearchHistory, false, 0, true);
                _search.leftIcon = new Search();
                _search.leftIconMode = TextInputIconMode.UNLESS_EDITING;
                addChild(_search);
            }
            
            if(hasBackButton)
            {
                _backButton =  new BackButtonSkinned();
                if (backText)
                    _backButton.label = backText;
                _backButton.addEventListener(MouseEvent.CLICK, closeView, false, 0, true);
                _backButton.visible = false;
                addChild(_backButton);
            }
            
            if(hasSearchHistory && hasSearchField)
            {
                _searchHistory = new SuggestionList();
                _searchHistory.list.addEventListener(ListEvent.ITEM_CLICKED, onPreviousSearchItemClicked, false, 0, true);
                _searchHistory.visible = false;	
            }
            
            if(hasTitleLabel)
            {
                _titleLabel = new Label();
                var textFormat:TextFormat = new TextFormat();
                textFormat.font = "Myriad Pro";
                textFormat.size = 18;
                textFormat.color = 0xFFFFFF;
                _titleLabel.format = textFormat;
                _titleLabel.visible = false;
                addChild(_titleLabel);
            }
        }
        
        internal function localeChanged(back:String):void 
        {
            if (_backButton) {
                _backButton.label = back;
                _titleLabel.x = _backButton.x + _backButton.width + 10;
            }
        }
        
        public override function destroy():void 
        {
            super.destroy();
            _search.removeEventListener(KeyboardEvent.KEY_DOWN, handleSearchEnter);
            _search.removeEventListener(FocusEvent.FOCUS_IN, showSearchHistory);
            _search.removeEventListener(FocusEvent.FOCUS_OUT, hideSearchHistory);
            _search.removeEventListener(Event.CHANGE, showSearchHistory);
            _pane.removeEventListener(Event.CHANGE, dispatchNavigateEvent);
            
            if (_searchHistory)
                _searchHistory.list.removeEventListener(ListEvent.ITEM_CLICKED, onPreviousSearchItemClicked);
        }
        
        /**
         * Called to set the Container that will serve as the back button and title bar for the menu
         * @param container - Container that is displayed when we want to show back button and tite bar
         */ 
        public function set backButtonAndTitleComponent(container:Container):void
        {
            _backButtonAndTitleComponent = container;
            this.addChild(_backButtonAndTitleComponent);
            _backButtonAndTitleComponent.x = 0;
            _backButtonAndTitleComponent.y = 0;
            _backButtonAndTitleComponent.visible = false;
        }
        
        /**
         * Called to get the back button and tite bar component of the menu
         * @returns - Container that is displayed when we want to show back button and tite bar
         */ 
        public function get backButtonAndTitleComponent():Container
        {
            return _backButtonAndTitleComponent;
        }
        
        /**
         * Called to show back button and title label component
         */ 
        public function dislpayBackButtonAndTitleComponent():void
        {
            _pane.visible= false;
            _backButtonAndTitleComponent.visible = true;
            _backButtonAndTitleComponent.invalidate();
        }
        
        /**
         * Called to hideback button and title label component
         */ 
        public function hideBackButtonAndTitleComponent():void
        {
            _pane.visible = true;
            _backButtonAndTitleComponent.visible = false;
            deselect();
            var evt:MenuEvent = new MenuEvent(MenuEvent.ITEM_CLICKED);
            dispatchEvent(evt);
        }
        
        /**
         * Hides the original item list and displays a back button
         * @param title - A string to display next to the back button
         * @param container - a container holding one or more component to be displayed on the left of the search bar
         */        
        public function showBackButton(title:String=null, extra:Container=null):void 
        {
            _title = title;
            
            if (_extraContainer)
            {
                removeChild(_extraContainer);
                _extraContainer = null;
            }
            
            if (extra) {
                _extraContainer = extra;
                _extraContainer.setSize(_extraContainer.width, height);
            }
            
            if (!_titleLabel.visible)
            {
                _pane.alpha = 1;
                Tweener.addTween(_pane, {time:0.5, alpha:0, transition:"linear", onComplete:hideListCompleted});
            } else {
                Tweener.addTween(_titleLabel, {time:0.5, alpha:0, transition:"linear", onComplete:hideListCompleted});
            }
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
        
        /**
         * Add graphic to search field.
         * @param image - graphic to display
         */
        public function set customLogo(image:Bitmap):void 
        {
            if (_search != null)
            {
                // Remove any previous image
                if (_customLogo && contains(_customLogo)) {
                    removeChild(_customLogo);
                    _customLogo = null;
                }
                
                if (image) {
                    _customLogo = image;
                    addChild(_customLogo);
                }
                
                invalidate();
            }
        }
        
        
        /**
         * Setup the navigation buttons
         * @param value - array of localized navigation button labels.
         */
        public function set data(value:Array):void 
        {
            _pane.data = value;
            if (_pane.selectedIndex == -1) {
                _pane.selectedIndex = 0;
            } else {
                // Refresh
                _pane.selectedIndex = _pane.selectedIndex;
            }
            _pane.invalidate();
        }
        
        /**
         *  <deprecated>Deprecated - Use set data() with an array instead </deprecated>
         * */
        public function set dataProvider(dp:DataProvider):void 
        {
            var values:Array = new Array();
            for (var i:int; i < dp.length; i++) {
                values.push(dp.getItemAt(i));
            }
            data = values;
        }
        
        /**
         * Called every time you set the width and height of the component.
         * <p>
         * Subclassing this method allows you to redraw and set the layout for the children of the component in order to accomodate the new dimensions.
         * If you decide to implement your own <code>draw</code> method, you should avoid calling <code>super.draw</code>, as this will cause the 
         * physical dimensions of your component to be resized.
         * </p>
         *
         **/
        protected override function draw():void 
        {
            _background.setSize(width, height);
            
            if(_backButtonAndTitleComponent)
            {
                _backButtonAndTitleComponent.x = 0;
                _backButtonAndTitleComponent.y = 0;
            }
            
            if(_backButton)
            {
                _backButton.x = 7;	
            }
            
            if(_titleLabel)
            {
                _titleLabel.x = _backButton.x + _backButton.width + 10;
            }
            
            
            // Portrait
            if (stage.stageHeight > stage.stageWidth)
            {
                if (_search != null)
                {
                    _search.width = width - 10;
                    _search.x = 5;
                    _search.y = height / 2 + (height / 2 - _search.height) / 2;
                }
                
                _pane.setSize(width, 42);
                
                if(_backButtonAndTitleComponent)
                {
                    _backButtonAndTitleComponent.setSize(width, ((_search != null)?height/2:height));
                }
                
                if(_backButton)
                {
                    _backButton.y = (((_search != null)?height/2:height) - _backButton.height) / 2;
                }
                
                if(_titleLabel)
                {
                    _titleLabel.y = (((_search != null)?height/2:height) - _titleLabel.height) / 2;
                }
                
                
                if(_extraContainer)
                {
                    _extraContainer.x = width - _extraContainer.width;
                    _extraContainer.setSize(_extraContainer.width, ((_search != null)?height/2:height));
                }
            } 	 
            else // Landscape
            {
                if (_search != null)
                {
                    _search.width = SEARCH_FIELD_WIDTH;
                    _search.x = width - _search.width - 10;
                    _search.y = (height - _search.height) / 2;
                }
                _pane.setSize(((_search != null)?_search.x:width), 42);
                
                if(_backButtonAndTitleComponent)
                {
                    _backButtonAndTitleComponent.setSize(((_search != null)?_search.x:width), height);
                }
                
                if(_backButton)
                {
                    _backButton.y = (height - _backButton.height) / 2;
                }
                
                if(_titleLabel)
                {
                    _titleLabel.y = (height - _titleLabel.height) / 2;
                    _titleLabel.width = ((_search != null)?_search.x:width) - 10 - _titleLabel.x;
                }
                
                if(_extraContainer)
                {
                    _extraContainer.x = ((_search != null)?_search.x:width) - 10 - _extraContainer.width;
                    _extraContainer.setSize(_extraContainer.width, height);
                }
            }
            
            if(_searchHistory)
            {
                _searchHistory.x = _search.x;
                _searchHistory.y = _search.y + _search.height;
                _searchHistory.width = _search.width;
            }
            
            // Custom logo
            if(_customLogo && _search)
            {
                _customLogo.x = _search.x + _search.width - _customLogo.width - 10;
                _customLogo.y = _search.y + (_search.height - _customLogo.height) / 2;
            }
        }
        
        /**
         * Deselect the selected navigation button, leaving none selected.
         */
        public function deselect():void 
        {
            _pane.selectedIndex = -1;
        }
        
        /**
         * Select this navigation item.
         * @param index - index of the navigation item to select.
         */
        public function select(index:int):void 
        {
            _pane.selectedIndex = index;
        }
        /**
         * Select this navigation item.
         * @param index - index of the navigation item to select.
         */
        public function getPreviousIndex():Number 
        {
            return _pane.previousSelectedIndex;
        }
        /**
         * Enable search functionality.
         * @param enabledValue - Boolean to enable or disable the search functionality.
         */
        public function enableSearch(enabledValue:Boolean):void 
        {
            if (_search != null)
            {
                _search.enabled = enabledValue;
            }
        }
        
        private function handleSearchEnter(event:KeyboardEvent):void
        {
            if (_search == null)
            {
                return;
            }
            
            if(event.keyCode == Keyboard.ENTER && StringUtil.trim(_search.text) != "")
            {
                deselect();
                stage.focus = null;
                
                if(_searchHistory)
                {
                    hideSearchHistory();					
                }
                
                var evt:MenuEvent = new MenuEvent(MenuEvent.SEARCH, _lastSearch);
                dispatchEvent(evt);
            }
        }
        
        private function dispatchNavigateEvent(event:Event):void 
        {
            var evt:MenuEvent = new MenuEvent(MenuEvent.ITEM_CLICKED);
            evt.index = MenuScrollPane(event.target).selectedIndex;
            dispatchEvent(evt);
        }
        
        private function showSearchHistory(event:Event=null):void 
        {
            if (_handler == null || _search == null)
                return;
            
            if (_lastSearch != null && _showLastSearch){
                _search.text = _lastSearch;
                _showLastSearch = false;
            }
            var history:Array = _handler.getSearchHistory(_search.text);
            if (history && history.length > 0) {
                _searchHistory.width = _search.width;
                _searchHistory.suggestionData = history;
                _searchHistory.visible = true;
                
                if (!contains(_searchHistory)) 
                    addChild(_searchHistory);
                
            } else {
                _searchHistory.visible = false;
            }
            
            if (_customLogo) {
                _customLogo.visible = false;
            }
        }
        
        private function hideSearchHistory(event:Event=null):void 
        {
            if (_search == null)
            {
                return;
            }
            
            var found:Boolean = false;
            if (stage.focus != null) {
                var obj:Object = stage.focus.parent;
                while (obj) {
                    if (obj is SuggestionItem) {
                        found = true;
                        break;
                    }
                    obj = obj.parent;
                }
            } 
            _searchHistory.visible = found;
            
            if (_search.text != ""){
                _lastSearch = _search.text;
                _search.text = "";
            }
            _showLastSearch = true;
            
            if (_customLogo) {
                _customLogo.visible = true;
            }
        }
        
        private function onPreviousSearchItemClicked(event:ListEvent):void 
        {
            if (_search == null)
            {
                return;
            }
            
            _searchHistory.visible = false;
            
            var searchText:String = event.data as String;
            _search.text = searchText; 
            var evt:MenuEvent = new MenuEvent(MenuEvent.SEARCH, searchText);
            dispatchEvent(evt);
            _lastSearch = _search.text;
            _search.text = "";
            _showLastSearch = true;
        }
        
        private function closeView(event:MouseEvent=null):void 
        {
            var menuEvt:MenuEvent = new MenuEvent(MenuEvent.BACK);
            dispatchEvent(menuEvt);
        }
        
        private function hideListCompleted():void 
        {
            _titleLabel.text = _title;
            
            if (!_titleLabel.visible) {
                _pane.visible = false;
                
                _backButton.visible = true;
                _titleLabel.width = _pane.width;
                _titleLabel.visible = true;
            }
            
            if (_extraContainer)
                addChild(_extraContainer)
            
            Tweener.addTween(_titleLabel, {time:0.5, alpha:1, transition:"linear"});
            
            invalidate();
        }
        
        public function hideBackButton():void 
        {
            if (!_pane.visible) {
                _title = null;
                Tweener.addTween(_titleLabel, {time:0.5, alpha:0, transition:"linear", onComplete:hideBackButtonCompleted});
            }
        }
        
        private function hideBackButtonCompleted():void 
        {
            _titleLabel.text = "";
            _titleLabel.visible = false;
            _backButton.visible = false;
            
            if (_extraContainer) {
                removeChild(_extraContainer);
                _extraContainer = null;
            }
            
            _pane.visible = true;
            _pane.alpha = 0; 
            Tweener.addTween(_pane, {time:0.5, alpha:1, transition:"linear"});
            
            invalidate();
        }
        
        /**
         * Returns navigation pane.
         */
        public function get list():MenuScrollPane 
        {
            return _pane;
        }
        
        /**
         * Enable navigation functionality.
         * @param enabledValue - Boolean to enable or disable the navigation functionality.
         */
        public function enable(enabledValue:Boolean):void
        {
            if(_pane)
            {
                _pane.enabled = enabledValue;
                
                if(!enabledValue)
                {
                    _pane.removeEventListener(ListEvent.ITEM_CLICKED, dispatchNavigateEvent);
                }
                else
                {
                    if(!_pane.hasEventListener(ListEvent.ITEM_CLICKED))
                    {
                        _pane.addEventListener(ListEvent.ITEM_CLICKED, dispatchNavigateEvent, false, 0, true);
                    }
                }
            }
        }
    }
}