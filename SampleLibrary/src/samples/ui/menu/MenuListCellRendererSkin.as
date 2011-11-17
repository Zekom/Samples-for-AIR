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

package samples.ui.menu {
    
    import flash.display.DisplayObject;
    
    import qnx.ui.skins.SkinStates;
    import qnx.ui.skins.UISkin;
    
    public class MenuListCellRendererSkin extends UISkin {
        
        [Embed(source="/../assets/images/topMenuButton_selected.png", scaleGridTop="10", scaleGridLeft="25", scaleGridRight="75", scaleGridBottom="20")]
        public static var TopMenuButtonSelected:Class;
        
        protected override function initializeStates():void 
        {
            var upState:DisplayObject = new TopMenuButtonSelected();
            upState.alpha = 0;
            showSkin( upState );
            var downState:DisplayObject = new TopMenuButtonSelected();
            
            setSkinState(SkinStates.UP, upState);
            setSkinState(SkinStates.DOWN, upState);
            setSkinState(SkinStates.SELECTED, downState);
            setSkinState(SkinStates.DISABLED, upState);
        }
    }
}