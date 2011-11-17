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
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    
    import samples.ui.menu.HistoryThumbnailLabel;
    
    import qnx.ui.listClasses.CellRenderer;
    import qnx.ui.text.Label;
    
    public class DefaultHistoryRenderer extends CellRenderer
    {
        private var _thumb:Thumbnail;
        private var _text:Label;
        
        private static const TEXT_SIZE:int = 12;
        
        public function DefaultHistoryRenderer()
        {
            super();
            
            _text = new Label();
            var format:TextFormat = new TextFormat();
            format.font = "Myriad Pro";
            format.size = TEXT_SIZE;
            format.color = 0xFFFFFF;
            format.align = TextFormatAlign.CENTER;
            
            _text.format = format;
            _text.width = width;
            _text.y = height - TEXT_SIZE;
            
            addChild(_text);
        }
        
        public override function setSkin(object:Object):void {}
        protected override function setLabel( str:String ):void {}
        
        public override function set data(newdata:Object):void 
        {
            if (_thumb) {
                _thumb.dispose();
                removeChild(_thumb);
            }
            
            super.data = newdata;
            var obj:HistoryThumbnailLabel = newdata as HistoryThumbnailLabel;
            
            // Square image
            obj.image.width  = width - TEXT_SIZE;
            obj.image.height = width - TEXT_SIZE;
            
            _text.text = obj.text;
            _thumb = obj.image;
            
            _thumb.y = 0;
            addChild(_thumb);
        }
    }
}