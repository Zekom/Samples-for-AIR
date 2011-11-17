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

package samples.ui.menu
{
    import flash.text.TextFormat;
    import flash.text.TextLineMetrics;
    import flash.utils.getQualifiedClassName;
    
    import qnx.ui.buttons.RadioButton;
    import qnx.ui.core.SizeMode;
    import qnx.ui.skins.SkinStates;
    import qnx.ui.text.TextTruncationMode;
    import qnx.ui.theme.ThemeGlobals;
    
    public class ClickableMenuItem extends RadioButton
    {
        public var index:int;
        
        public function ClickableMenuItem(position:int)
        {
            super();
            index = position;
        }
        
        override protected function init():void
        {
            if( __defaultSkin == null )
            {
                __defaultSkin = getQualifiedClassName(MenuListCellRendererSkin);	
            }
            
            super.init();
            truncationMode = TextTruncationMode.CLIP;
            sizeMode = SizeMode.BOTH;
        }
        
        protected override function initializeTextFormatForState( state:String ):void 
        {
            var format:TextFormat = ThemeGlobals.getTextFormat(ThemeGlobals.BUTTON_FORMAT_SELECTED);
            format.color = 0xFFFFFF;
            setTextFormatForState(format, state);
        }
        
        override protected function draw():void
        {
            super.draw();
            size = __width;	
        }
        
        override protected function drawLabel():void
        {
            if( label_txt != null )
            {
                label_txt.width = label_txt.textWidth + ThemeGlobals.TEXT_WIDTH_OFFSET;;
                var metrics:TextLineMetrics = label_txt.getLineMetrics(0);
                var textHeight:int = (metrics.ascent + metrics.descent);
                
                label_txt.height = textHeight + ThemeGlobals.TEXT_HEIGHT_OFFSET;
                if( skin != null )
                {
                    label_txt.y = Math.round( ( skin.height-textHeight)/2 ) - ThemeGlobals.TEXT_GUTTER;
                }
                
                __width = label_txt.textWidth + 50;
                label_txt.x = 25;
                size = __width;
                truncateText();
            }
        }
        
        public function updateState(state:String):void 
        {
            if (state == SkinStates.SELECTED){
                selected = true;
            }else{
                selected = false;
            }
            setState(state);
        }
    }
}