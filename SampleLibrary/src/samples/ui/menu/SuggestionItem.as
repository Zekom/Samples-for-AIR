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
    import flash.display.MovieClip;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    
    import qnx.ui.core.Container;
    import qnx.ui.core.ContainerAlign;
    import qnx.ui.core.ContainerFlow;
    import qnx.ui.core.SizeUnit;
    import qnx.ui.core.Spacer;
    import qnx.ui.events.ListEvent;
    import qnx.ui.listClasses.CellRenderer;
    import qnx.ui.listClasses.ICellRenderer;
    import qnx.ui.text.Label;
    
    public class SuggestionItem extends CellRenderer implements ICellRenderer
    {
        private var title:Label;
        private var listContainer:Container;
        
        public function SuggestionItem()
        {
            super();
        }
        
        override protected function init():void
        {
            super.init();
            if(skin!=null)
            {
                skin.alpha = 0;
            }
            
            var format:TextFormat = new TextFormat();
            format.size = 16;
            format.color = 0x000000;
            format.align = TextFormatAlign.LEFT;
            
            title = new Label();
            title.format = format;
            
            listContainer = new Container();
            listContainer.addChild(title);
            listContainer.align = ContainerAlign.MID;
            addChild(listContainer);
        }
        
        override public function set data(data:Object):void
        {
            super.data = data;
            title.text = data as String;
        }
        
        override protected function draw():void
        {
            super.draw();
            if (listContainer)
            {
                listContainer.setSize(__width, __height);
                title.width = __width;
                title.y = (height - title.height) / 2;
            }
        }
    }
}