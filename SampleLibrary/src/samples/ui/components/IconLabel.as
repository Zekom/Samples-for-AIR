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
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import flash.utils.setInterval;
    
    import qnx.ui.buttons.IconButton;
    import qnx.ui.core.SizeMode;
    import qnx.ui.core.UIComponent;
    import qnx.ui.display.Image;
    import qnx.ui.text.Label;
    
    import samples.ui.menu.MenuListCellRendererSkin;
    import samples.ui.menu.ModalWindow;
    
    /**
    * This class is used in the Expanded Menu to draw a label beneath an image. 
    * 
    */ 
    public class IconLabel extends UIComponent
    {
        private var _label:Label;
        private var _icon:IconButton;
        private var _modal:ModalWindow;
        
        
        public function IconLabel()
        {
            sizeMode = SizeMode.BOTH;
            
            _icon = new IconButton();
            _icon.setSkin(MenuListCellRendererSkin);
            
            _modal = new ModalWindow();

            _label = new Label();
                
            var format:TextFormat = new TextFormat();
            format.font = "Myriad Pro";
            format.size = 18;
            format.color = 0xFFFFFF;
            format.align = TextFormatAlign.CENTER;
            _label.format = format;
            
            
            addChild(_modal);
            addChild(_icon);
            addChild(_label);
            
        }
        
        public override function setSize(w:Number, h:Number):void 
        {
            if (_icon && _icon.width != 0) {
                __width = Math.max(_icon.width, _label.textWidth);
                __height = h;
            } else {
                super.setSize(w, h);
            }
            invalidate();
        }
        
        protected override function draw():void 
        {
            var padding:int = 10;
            _icon.x = (width - _icon.width ) / 2;
            _icon.y = (height - _icon.height - _label.textHeight - padding) / 2;
            _label.x = (width - _label.width ) / 2;
            _label.y = _icon.y + _icon.height + padding;
            _modal.setRectangle(_label.x, 0, width, height);

            __width = _icon.width + 10;
            __height = _label.textHeight + _icon.height

        }

        public function setImage(image:Object):void 
        {
            _icon.setIcon(image);
            if(_icon.icon){
                size = _icon.icon.width + 10;
                _icon.setSize(_icon.icon.height, _icon.icon.width);
            }    

        }
        public function getImage():Bitmap{
            return _icon.icon;
        }
        public function set text(value:String):void 
        {
            _label.text = value;
            
        }
        public function getText():String
        {
            return _label.text;
        }
        public function set format(textFormat:TextFormat):void
        {
            _label.format = textFormat;
        }
        public function get format():TextFormat
        {
            return _label.format;
        }
        
    }
}