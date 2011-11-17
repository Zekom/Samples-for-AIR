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
    import flash.display.Sprite;
    
    import qnx.ui.data.DataProvider;
    import qnx.ui.listClasses.List;
    
    public class SuggestionList extends Sprite
    {
        internal var list:List;
        private var _backgroud:Sprite;
        
        public function SuggestionList()
        {
            list = new List();
            list.x = list.y = 5;
            list.rowHeight = 45;
            list.scrollable = false;
            list.setSkin( SuggestionItem );
            
            _backgroud = new Sprite();
            
            addChild( _backgroud );
            addChild( list );
        }
        
        /**
         * Sets the suggestion data for the list
         */
        public function set suggestionData( _suggestionData:Array ):void
        {
            list.dataProvider = new DataProvider( _suggestionData );
            var h:int = list.rowHeight * list.dataProvider.length;
            
            _backgroud.height = h;
            list.height = h;
        }
        
        public override function set width( value:Number ):void 
        {
            _backgroud.width = value;
            list.width = value - list.x;
            
            with (_backgroud.graphics) {
                clear();
                beginFill(0xFFFFFF);
                drawRoundRect(0, 0, value, height, 3, 3);
                endFill();
            }
        }
    }
}