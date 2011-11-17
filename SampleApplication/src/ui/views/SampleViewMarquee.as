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
    import samples.ui.components.ScrollingMarquee;
    
    import flash.text.TextField;
    import flash.text.TextFormat;
    
    public class SampleViewMarquee extends SampleView
    {
        public function SampleViewMarquee()
        {
            super();
        }
        
        override protected function init():void
        {    
            super.init();// ensure titleContainer is initialized.

            setTitleText("Scrolling Marquee");
            
            var txt:TextField = new TextField();
            var fmt:TextFormat = new TextFormat();    
            fmt.size = 22;
            fmt.bold = true;
            txt.defaultTextFormat = fmt;
            txt.textColor = 0xFFFFFF;//White
            txt.text = "Lorem ipsum dolor sit amet";
            
            
            // Example of a scrolling marquee useful for display of long text 
            var marquee:ScrollingMarquee = new ScrollingMarquee(txt);
            marquee.y = 200;
            addChild(marquee);
            
        }
    }
}