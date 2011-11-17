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
    
    import flash.display.Shape;
    import flash.events.TimerEvent;
    import flash.text.TextField;
    import flash.utils.Timer;
    
    import qnx.ui.core.UIComponent;
    
    
    public class ScrollingMarquee extends UIComponent
    {
        private const SPEED:int = 15;
        private const PAUSE:int = 2000;
        
        private var _timer:Timer;
        private var _text:String; // original text
        private var _textField:TextField;
        private var _textField2:TextField;
        
        /**
         * Use to create a scrolling marquee effect for a textfield.  Usually used with text exceeds the avaiable textfield width.
         * @param textField - implement marquee for this field.
         * @param txt - text to scroll.
         */  
        public function ScrollingMarquee(textField:TextField)
        {
            _text = textField.text;
            _textField = textField;
            _textField2 = clone(_textField);
            
            x = _textField.x;
            addChild(_textField);
            addChild(_textField2);
            
            setSize(_textField.width, _textField.height);
            
            _textField.width = _textField.textWidth + 10;
            _textField2.width = _textField.width;
            _textField.x = 0;
            
            var hide:Shape = new Shape();
            hide.graphics.clear();
            hide.graphics.beginFill(0x00ff00, 1);
            hide.graphics.drawRect(0, _textField.y, width, height);
            hide.graphics.endFill();
            hide.width = width;
            addChild(hide);
            
            mask = hide;
        }
        
        protected override function draw():void {}
        
        protected override function onAdded():void 
        {
            if (_timer == null) {
                _timer = new Timer(PAUSE);
                _timer.addEventListener(TimerEvent.TIMER, advanceMarquee);
            }
            _timer.start();
        }
        
        protected override function onRemoved():void 
        {
            _timer.stop();
        }
        
        private function advanceMarquee(evt:TimerEvent):void 
        {
            _timer.delay = SPEED;
            _textField.x = (_textField.x - 1);
            _textField2.x = _textField.x + _textField.textWidth + 50;
            
            // Reset the marquee
            if (_textField2.x <= 0) {
                _textField.x = 0;
                _textField2.x = _textField.x + _textField.textWidth + 50;
                _timer.stop();
                _timer.delay = PAUSE;
                _timer.start();
            }
        }
        
        /**
         * Stop the text scrolling and display the text from the the beginning.
         */  
        public function stopMarquee():void
        {
            if (_timer && _timer.running)
                _timer.stop();
            
            _textField.text = _text;
            _textField.width = width;
            
            removeChild(_textField);
            removeChild(_textField2);
        }
        
        private function clone(txt:TextField):TextField 
        {
            var txt2:TextField = new TextField();
            txt2.defaultTextFormat = txt.defaultTextFormat;
            txt2.text = txt.text;
            txt2.width = txt.width;
            txt2.height = txt.height;
            txt2.y = txt.y;
            
            return txt2;
        }
    }
}