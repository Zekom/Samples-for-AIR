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
package
{
    import flash.desktop.NativeApplication;
    import flash.display.*;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.filesystem.File;
    import flash.utils.Timer;
    
    import options.Config;
    
    import qnx.ui.buttons.LabelButton;
    import qnx.ui.core.Container;
    import qnx.ui.core.Containment;
    import qnx.ui.listClasses.CellRenderer;
    
    import samples.events.MenuEvent;
    import samples.events.NavigationEvent;
    import samples.events.TransitionEvent;
    import samples.ui.components.DownloadProgress;
    import samples.ui.menu.IMenuHandler;
    import samples.ui.menu.Menu;
    
    import ui.transitions.ViewTransitionHandler;
    import ui.views.SampleView;
    import ui.views.SampleViewDownloadManager;
    import ui.views.SampleViewHome;
    import ui.views.SampleViewMarquee;
    import ui.views.SampleViewMediaPlayBar;
    import ui.views.SampleViewOptions;
    import ui.views.SampleViewSearchResults;
    
    [SWF(width="1024", height="600", frameRate="30", backgroundColor="#000000")]
    public class SampleApplication extends Container implements IMenuHandler
    {
        
        
        private var _transitions:ViewTransitionHandler;
        private var _mainContainer:Container;
        
        
        
        // Navigation menu declarations IE: tabs [Featured] [Top Rated] [Most Viewed] [Recne]
        private var _menu:Menu;
        private var _menuTabs:Array;
        private var _currentViewIndex:Number;
        
        
        public static var FEATURED:Number    = 0;
        public static var TOPRATED:Number    = 1;
        public static var MEDIA:Number       = 2;
        public static var DOWNLOADS:Number   = 3;
        
        
        
        
        
        public function SampleApplication()
        {
            super();
            
            var view:Container = new SampleViewHome();
            _mainContainer = new Container();
            _mainContainer.addChild(view);
            
            // Create menu and pass in labels, if you have help documention available online, include a help label and the URL. 
            _menu = new Menu(this,"Home","Options","Help","http://www.blackberry.com/");
            _menuTabs = ["Home", "Marquee", "Media", "Downloads"];
            _menu.Navigation.data = _menuTabs;
            _menu.Navigation.select(FEATURED);
            _menu.containment = Containment.DOCK_TOP;
            
            // To customize the history content to use images implement 
            // an Image Cell renderer instead of using this default
            _menu.Expansion.setHistoryRenderer(CellRenderer, 100);
            
            
            
            addEventListener(MenuEvent.BACK, onMenuItemClicked);
            addEventListener(MenuEvent.SEARCH, onPerformSearch);
            addEventListener(MenuEvent.OPTIONS_CLICKED, onOptionsClicked);
            addEventListener(MenuEvent.HOME_CLICKED, onMenuItemClicked);
            addEventListener(MenuEvent.ITEM_CLICKED, onMenuItemClicked);
            addEventListener(MenuEvent.HISTORY_ITEM_CLICKED, onMenuItemClicked);
            
            _transitions = new ViewTransitionHandler(_mainContainer,view);
            
            addEventListener(NavigationEvent.ADD, _transitions.viewNavigationHandler);
            addEventListener(NavigationEvent.BACK, _transitions.viewNavigationHandler);
            addEventListener(NavigationEvent.PLAY_TRACK, _transitions.viewNavigationHandler);
            
            
            
            // Setup the stage
            stage.nativeWindow.visible = true;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            stage.nativeWindow.activate();
            stage.addEventListener(Event.RESIZE, resize);
            
            
            addChild(_mainContainer);
            addChild(_menu);
            
        }
        
        
        private function resize(event:Event):void 
        {
            setSize(stage.stageWidth, stage.stageHeight);
        }
        
        /**
         * onPerformSearch is a registered call back, that is invoked when users enter search text and hit enter
         * 
         */ 
        private function onPerformSearch(input:MenuEvent):void
        {
            _menu.Navigation.select(-1);
            
            //store current search queury for search history see this.getSearchHistory()
            Config.getConfig().saveSearchHistory(input.query);
            
            
            var navEvent:NavigationEvent = new NavigationEvent(NavigationEvent.ADD);
            navEvent.classname = SampleViewSearchResults;
            navEvent.param = input.query;
            dispatchEvent(navEvent);
            
            
        }
        /**
         * onOptionsClicked is a registered call back, that is invoked when users touch the options icon in the swhipe down menu
         * 
         */ 
        
        private function onOptionsClicked(input:MenuEvent):void
        {
            if (_transitions.current is SampleViewOptions)
                return;
            
            var tween:TransitionEvent = new TransitionEvent(TransitionEvent.TWEENER_ADDED, true);
            tween.to = new SampleViewOptions();
            
            _menu.Navigation.deselect();
            _transitions.dispatchEvent(tween);
            
            
        }
        
        /**
         * onMenuItemClicked is invoked when ever navigation button elements are touched.
         * 
         */ 
        private function onMenuItemClicked(event:MenuEvent):void 
        {
            // do something
            var fromIndex:int = _menu.Navigation.getPreviousIndex();
            
            var toIndex:int = (event.type == MenuEvent.HOME_CLICKED) ? FEATURED : event.index;
            _menu.Navigation.select(toIndex);
            
            var nextView:Container;
            var selected:String =  _menuTabs[toIndex];
            
            switch (toIndex) {
                case FEATURED:
                    //switch to FEATURED view
                    nextView = new SampleViewHome();
                    break;
                case TOPRATED:
                    //switch to Marquee demo view
                    nextView = new SampleViewMarquee();
                    break;
                case MEDIA:
                    //switch to Sample media playbar view
                    nextView = new SampleViewMediaPlayBar();
                    break;
                case DOWNLOADS:
                    //switch to download manager view
                    nextView = new SampleViewDownloadManager();
                    break;                   
                default:
                    return;
                    
            }
            
            
            var direction:Boolean = fromIndex != -1 && toIndex < fromIndex;
            var tween:TransitionEvent = new TransitionEvent(TransitionEvent.TWEENER_ADDED, direction );
            tween.to = nextView;
            
            _transitions.dispatchEvent(tween);
            
            
        }
        
        
        /**
         * IMenuHandler.getSearchHistory(currentText:String):Array
         * 
         *  Return browsing history to display in swipe down menu.
         *  This behaviour is completely optional, return null and the background will be drawn. 
         * 
         */
        public function getHistory():Array {
            
            // generate some sample dummy data 
            var history:Array = new Array();
            for (var i:int=0; i<10; i++) {
                var item:Object = new Object();
                item.label = "item " + i;
                history.push(item);
            }
            return history;
        }
        
        
        /**
         * IMenuHandler.getSearchHistory(currentText:String):Array
         * 
         */
        public function getSearchHistory(currentText:String):Array {
            // Return search history filtered against currentText 
            return Config.getConfig().getSearchHistory(currentText);
        }
        
        
        
    }
}