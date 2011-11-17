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
package ui.views
{
    import samples.events.NavigationEvent;
    import samples.ui.buttons.BackButtonSkinned;
    import flash.events.MouseEvent;
    
    public class SampleViewBackButton extends SampleView
    {
        private var _backButton:BackButtonSkinned;
        
        public function SampleViewBackButton()
        {
            super();
            
        }
        
        override protected function init():void
        {
            super.init();// ensure titleContainer is initialized.

            _backButton =  new BackButtonSkinned();
            _backButton.addEventListener(MouseEvent.CLICK, onBackClicked);
            _backButton.label = "Back";
            // Delay positioning of _backbutton until draw() is called
            
            titleContainer.addChild(_backButton);

        }
        protected override function draw():void 
        {
            super.draw(); 
            if (stage == null) return;
            
            
            // Position back button on the right hand side of screen
            _backButton.x = width - _backButton.width;
            
        }
        
        
        /**
         * Call back invoked when the back button is invoked.
         * Close the current view. 
         */ 
        private function onBackClicked(event:MouseEvent=null):void 
        {
            var navEvt:NavigationEvent = new NavigationEvent(NavigationEvent.BACK);
            dispatchEvent(navEvt);
        }
    }
}