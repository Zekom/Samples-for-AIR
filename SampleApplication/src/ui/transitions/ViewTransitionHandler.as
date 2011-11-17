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
package ui.transitions
{
    import avmplus.getQualifiedSuperclassName;
    
    import caurina.transitions.Tweener;
    
    import flash.display.Stage;
    import flash.events.Event;
    import flash.net.URLRequest;
    import flash.net.navigateToURL;
    import flash.utils.getQualifiedClassName;
    
    import mx.effects.easing.Back;
    
    import qnx.ui.core.Container;
    import qnx.ui.core.UIComponent;
    
    import samples.events.MenuEvent;
    import samples.events.NavigationEvent;
    import samples.events.TransitionEvent;
    import samples.ui.menu.Menu;
    import samples.ui.transitions.TransitionHandler;
    import samples.utils.MusicAppLauncherUtil;
    
    import ui.views.SampleView;
    import ui.views.SampleViewBackButton;
    
    /**
     * The ViewTransitionHandler class handles animation transitions from view to view when 
     * buttons on the navigation bar are selected.
     * 
     */ 
    public class ViewTransitionHandler extends TransitionHandler
    {
        private var _currentView:Container;
        
        public function ViewTransitionHandler(handler:Container, view:Container) 
        {
            super(handler);
            
            _currentView = view;
        }
        
        public function get current():Container {
            return _currentView;
        }
        
        /**
         * Performs an actual view animation, views can have 
         * custom transitions or use the default ones (sliding)
         * */
        protected override function doTween(event:TransitionEvent):void 
        {
            var from:UIComponent = event.from = _container.getChildAt(0) as Container;
            var to:UIComponent = _currentView = event.to as Container;
            
            
            if (_useAlphaTransitions) {
                to.alpha = 0;
            } else {
                var offset:Number = event.positive ? from.width: -from.width;
                to.setPosition(offset, from.y);
            }
            _container.addChild(to);
            
            // Set the view size
            if (to.width != from.width || to.height != from.height) {
                to.setSize(from.width, from.height);
            }
            
            
            _current = event;
            if (_useAlphaTransitions) {
                Tweener.addTween(this, {time:0.5, transition:"easeInOut", executeTweenOffset:0, onComplete:onTweenRemoveCompleted});
            } else {
                Tweener.addTween(this, {time:0.5, transition:"easeInOut", executeTweenOffset:-offset, onComplete:onTweenRemoveCompleted});
            }
        }
        
        /**
         * Removes the view that was animated out of the display area and adds the new view 
         * */
        private function onTweenRemoveCompleted():void 
        {
            _container.removeChild(_current.from);
            var nextView:Container = _current.to as Container;
            var positive:Boolean = _current.positive;
            
            
            // Clear the previous array when we hit a menu item
            if (nextView is SampleViewBackButton ) {
                // Don't add the previous item to the stack if we closed a child view 
                if (positive) {
                    _previous.push(_current.from);
                } else {
                    _current.from.destroy();
                }
            } else {
                // Destroy any child view that will no longer be accessible
                for each (var view:SampleView in _previous) {
                    if (view is SampleViewBackButton )
                        view.destroy();
                }
                // Also destroy the current view
                if (_current.from is SampleViewBackButton  ) {
                    _current.from.destroy();
                }
                _previous = [];
            }
            
            
            _current = null;
            
            // Send a global event, and notify the view
            var evt:TransitionEvent = new TransitionEvent(TransitionEvent.TWEENER_COMPLETED, positive);
            _currentView.dispatchEvent(evt);
            tweenCompleted(evt);
        }
        
        /**
         * Handles view animations to tween them in and out.
         *   ADD - a child view is being created
         *   BACK - a child view is being removed, then deleted
         *   NAVIGATION - a menu item has been clicked 
         * */
        public function viewNavigationHandler(evt:Event):void 
        {
            var nextView:Container;
            var isPositive:Boolean;
            var event:NavigationEvent = evt as NavigationEvent;
            
            switch (evt.type) {
                case NavigationEvent.ADD:
                    if (event.param != null) {
                        nextView = new event.classname(event.param);
                    } else {
                        nextView = new event.classname();
                    }
                    isPositive = true;
                    
                    // Do not allow duplicated views
                    if (_currentView == nextView) {
                        nextView.destroy();
                        return;
                    }
                    break;
                case MenuEvent.BACK:
                case NavigationEvent.BACK:
                    if (_previous.length == 0)
                        return;
                    nextView = _previous.pop();
                    isPositive = false;
                    break;
                
                
                case NavigationEvent.PLAY_TRACK:
                    var url:String;
                    if (event.param && event.param.length && event.param.length == 2)
                        url = MusicAppLauncherUtil.launchAlbumTracks(event.param[0], event.param[1]);
                    else // fallback
                        url = MusicAppLauncherUtil.launchAllSongs();
                    navigateToURL(new URLRequest(url));
                    return;
            }
            
            var tween:TransitionEvent = new TransitionEvent(TransitionEvent.TWEENER_ADDED, isPositive);
            tween.to = nextView;
            dispatchEvent(tween);
        }
        
    }
}