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
    import flash.text.TextField;
    import flash.text.TextFormat;
    
    public class SampleViewHome extends SampleView
    {
        private var _description:TextField;
        
        public function SampleViewHome()
        {
            super();
            setTitleText("Home View");

        }
        
        override protected function init():void
        {
            super.init();// ensure titleContainer is initialized.

            var fmt:TextFormat = new TextFormat();
            fmt.color = 0xFFFFFF;
            fmt.font = "Myriad Pro";
            fmt.size = 18;
            
            _description = new TextField();
            _description.defaultTextFormat = fmt;
            _description.htmlText=
                "This sample application demonstrates the various features offered in the sample library for <i>Blackberry Tablet OS SDK for Adobe AIR</i>\n"+
                "\n"+
                "•\tClick buttons in the navigation bar, to view various interactive demos including, scrolling marquee field, \n"+
                " \tmedia playbar and adding and removing download tasks to the download manager.\n"+
                "•\tSwipe down from the top frame to expose a menu complete with options and help buttons and browsing history.\n"+
                "•\tTry out the search search field with search history, that filters as you type. Type in the search \n" +
                " \tfield and hit enter to launch the search results screen, that also demonstrates how to implement a back button.\n" +
                "\n";
            
            
            addChild(_description);
        }
        
        protected override function draw():void 
        {
            super.draw();
            
            if (stage == null) return;
            _description.width = width;
            _description.height = height;
            _description.x = 20;
            
        }
    }
}