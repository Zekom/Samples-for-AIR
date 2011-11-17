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
	
	
	import flash.text.AntiAliasType;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import qnx.ui.buttons.Button;
	import qnx.ui.core.Containment;
	import qnx.ui.listClasses.CellRenderer;
	import qnx.ui.skins.SkinStates;
	import qnx.ui.theme.ThemeGlobals;
	
	
	public class MenuListCellRenderer extends CellRenderer {
		private var _button:Button;
        
		public function MenuListCellRenderer():void 
        {
			super();

            setSkin(MenuListCellRendererSkin);
            
            setupTextFormats();
            setupLabel();
            
            //To Do:  This button is added as a hack to increase the clickable area of the menu items.
            _button = new Button();
            _button.containment = Containment.BACKGROUND;
            _button.alpha = 0;
            addChild(_button);
            
            state = SkinStates.UP;
		}
		
		protected override function draw():void 
        {
            skin.setSize(width, height);
		}
		
		override protected function drawLabel():void {
			renderLabel();
		}
		
		private function setupTextFormats():void 
        {
			var format:TextFormat = ThemeGlobals.getTextFormat(ThemeGlobals.CELL_FORMAT_SELECTED);
			
			setTextFormatForState(format, SkinStates.UP);
			setTextFormatForState(format, SkinStates.DOWN);
			setTextFormatForState(format, SkinStates.SELECTED);
			setTextFormatForState(format, SkinStates.DISABLED);
		}
        
		private function setupLabel():void 
        {
			label.textField.antiAliasType = AntiAliasType.ADVANCED;
			label.autoSize = TextFieldAutoSize.LEFT;
		}
        
		private function renderLabel():void {
			if (label == null)
				return;
			
			label.x = Math.round((width - label.textWidth) * 0.5) - 3;
			label.y = Math.round((height - label.textHeight) * 0.5) - 3;
		}
	}
}