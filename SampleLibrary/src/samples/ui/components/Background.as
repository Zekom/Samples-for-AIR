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

package samples.ui.components {
    
    import flash.display.Bitmap;
    
    import qnx.ui.core.Containment;
    import qnx.ui.core.SizeUnit;
    import qnx.ui.core.UIComponent;
    
    
    public class Background extends UIComponent {
        
        [Embed(source="/../assets/images/NavBar_bg.png")]
        public static var MenuLandscapeBackground:Class;
        
        [Embed(source="/../assets/images/NavBar_bg_portrait.png")]
        public static var MenuPortraitBackground:Class;
        
        [Embed(source="/../assets/images/Slidedown_bg_cell.png")]
        public static var ExpandedMenuHorizontalBackground:Class;
        
        private var _bg:Bitmap;
        
        /**
         * Create a background that can be added to a component. 
         * @param classType - pass a png image class.
         */
        public function Background(classType:Class):void 
        {
            var obj:Object = new classType();
            _bg = obj as Bitmap;
            
            __height = _bg.height;
            size = __height;
            sizeUnit = SizeUnit.PIXELS;
            containment = Containment.BACKGROUND;
        }
        
        /**
         * Set the size of the background
         * @param width - number for background width
         * @param height - number for background height
         */
        public override function setSize(width:Number, height:Number):void 
        {
            __width = width;
            if (_bg) {
                __height = height;
                invalidate();
            }
        }
        
        protected override function draw():void 
        {
            if (_bg) {
                with (graphics) {
                    clear();
                    beginBitmapFill(_bg.bitmapData);
                    moveTo(0,0);
                    lineTo(width, 0);
                    lineTo(width, height);
                    lineTo(0, height);
                    lineTo(0, 0);
                    endFill();
                }
                __height = _bg.height;
            }
            __width = width;
        }
    }
}