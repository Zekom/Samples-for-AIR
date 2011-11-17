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
    import qnx.ui.core.Container;
    import qnx.ui.core.ContainerAlign;
    import qnx.ui.core.Containment;
    import qnx.ui.core.SizeUnit;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    
    import qnx.ui.core.Container;
    import qnx.ui.text.Label;
    
    
    public class SampleView extends Container
    {
        private var _titleContainer:Container;
        private var _titleLabel:Label = new Label();
        
        
        public function SampleView()
        {
            
            
        }
        public function setTitleText(text:String):void
        {
            _titleLabel.text = text;
        }
        public function get titleContainer():Container
        {
            return _titleContainer;
        } 
        
        override protected function init():void
        {
            super.init();
            
            _titleContainer = new Container(60, SizeUnit.PIXELS);
            _titleContainer.containment = Containment.DOCK_TOP;
            _titleContainer.align = ContainerAlign.NEAR;
            
            addChild(_titleContainer);
            
            var fmt:TextFormat = new TextFormat();	
            fmt.size = 22;
            fmt.bold = true;
            _titleLabel.format = fmt;
            _titleLabel.textField.textColor = 0xFFFFFF;//White
            _titleLabel.width = _titleLabel.label_txt.textWidth + 4;
            _titleLabel.height = _titleLabel.label_txt.textHeight + 4;
            _titleLabel.autoSize = TextFieldAutoSize.LEFT;
            
            _titleContainer.addChild(_titleLabel);
    
        }
        
    }
    
}