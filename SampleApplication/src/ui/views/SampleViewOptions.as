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
    import flash.events.MouseEvent;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    
    import options.Config;
    
    import qnx.ui.buttons.CheckBox;
    import qnx.ui.buttons.LabelPlacement;
    import qnx.ui.core.Container;
    import qnx.ui.core.ContainerAlign;
    import qnx.ui.core.ContainerFlow;
    import qnx.ui.core.SizeUnit;
    import qnx.ui.text.Label;
    
    public class SampleViewOptions extends SampleView
    {
        
        private var _checkboxOptionOne:CheckBox;
        private var _checkboxOptionTwo:CheckBox;
        private var _checkboxOptionThree:CheckBox;
        private var _labelOptionOne:Label;
        private var _labelOptionTwo:Label;
        private var _labelOptionThree:Label;
        
        
        public function SampleViewOptions()
        {
             super(); 
        }
        override protected function init():void
        {
            super.init();// ensure titleContainer is initialized.

            setTitleText("Options and Settings View");

            _checkboxOptionOne = new CheckBox();
            _checkboxOptionOne.selected = Config.getConfig().OptionOne();
            _checkboxOptionOne.label_txt.autoSize = TextFieldAutoSize.LEFT;
            _checkboxOptionOne.label = "Option One";
            _checkboxOptionOne.width = 300;	// give it enough room for long text
            _checkboxOptionOne.labelPlacement = LabelPlacement.RIGHT;
            _checkboxOptionOne.addEventListener(MouseEvent.CLICK, optionClicked);
            
            _labelOptionOne = createLabel("Option One");
            
            
            _checkboxOptionTwo = new CheckBox();
            _checkboxOptionTwo.selected = Config.getConfig().OptionTwo();
            _checkboxOptionTwo.label_txt.autoSize = TextFieldAutoSize.LEFT;
            _checkboxOptionTwo.label = "Option Two";
            _checkboxOptionTwo.width = 300;	// give it enough room for long text
            _checkboxOptionTwo.labelPlacement = LabelPlacement.RIGHT;
            _checkboxOptionTwo.addEventListener(MouseEvent.CLICK, optionClicked);
            
            _labelOptionTwo = createLabel("Option Two");
            
            _checkboxOptionThree = new CheckBox();
            _checkboxOptionThree.selected = Config.getConfig().OptionThree();
            _checkboxOptionThree.label_txt.autoSize = TextFieldAutoSize.LEFT;
            _checkboxOptionThree.label = "Option Three";
            _checkboxOptionThree.width = 300;	// give it enough room for long text
            _checkboxOptionThree.labelPlacement = LabelPlacement.RIGHT;
            _checkboxOptionThree.addEventListener(MouseEvent.CLICK, optionClicked);
            
            _labelOptionThree = createLabel("Option Three");
            
            var c:Container = new Container(70, SizeUnit.PIXELS);
            c.padding = 15;
            c.align = ContainerAlign.NEAR
            c.flow = ContainerFlow.VERTICAL;
            
            
            c.addChild(_labelOptionOne);
            c.addChild(_checkboxOptionOne);
            c.addChild(_labelOptionTwo);
            c.addChild(_checkboxOptionTwo);
            c.addChild(_labelOptionThree);
            c.addChild(_checkboxOptionThree);
            
            addChild(c);

        }
        
        private function optionClicked(event:MouseEvent):void{
            
            
            if (event.target == _checkboxOptionOne){
                switch ( _checkboxOptionOne.selected ) {
                    case true:
                        Config.getConfig().saveValue(Config.OPTION_ONE, "1");
                        break;
                    
                    case false:
                        Config.getConfig().saveValue(Config.OPTION_ONE, "0");
                        break;
                }
            }
            
            
            if (event.target == _checkboxOptionTwo){
                
                switch ( _checkboxOptionTwo.selected ) {
                    case true:
                        Config.getConfig().saveValue(Config.OPTION_TWO, "1");
                        break;
                    
                    case false:
                        Config.getConfig().saveValue(Config.OPTION_TWO, "0");
                        break;                    
                }
            }
            
            if (event.target == _checkboxOptionThree){
                
                switch ( _checkboxOptionThree.selected ) {
                    case true:
                        Config.getConfig().saveValue(Config.OPTION_THREE, "1");
                        break;
                    
                    case false:
                        Config.getConfig().saveValue(Config.OPTION_THREE, "0");
                        break;                    
                }
            }
            
            
        }
        
        private function createLabel(text:String, fontSize:int=20, bold:Boolean=false, italic:Boolean=false, textColour:uint=0xFFFFFF):Label {
            var label:Label = new Label();
            label.text = text;
            
            var fmt:TextFormat = new TextFormat();	
            fmt.size = fontSize;
            fmt.bold = bold;
            label.format = fmt;
            label.autoSize = TextFieldAutoSize.LEFT;
            
            label.textField.textColor = textColour;
            label.width = label.label_txt.textWidth + 4;
            label.height = label.label_txt.textHeight + 4;
            
            return label;			
        }
        
    }
}