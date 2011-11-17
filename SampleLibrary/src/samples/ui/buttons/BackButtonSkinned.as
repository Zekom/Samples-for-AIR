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

package samples.ui.buttons
{
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    
    import qnx.ui.buttons.BackButton;
    import qnx.ui.core.Containment;
    import qnx.ui.skins.SkinStates;

    /**
     * Provides back button with a customized background
	 */
	public class BackButtonSkinned extends qnx.ui.buttons.BackButton
	{
		/**
		 * This is a stylized back button.  It is transparent, with a border and an arrow graphic.
		 */  
		public function BackButtonSkinned()
		{
			super();
			setSkin(BackButtonSkin);
            containment = Containment.UNCONTAINED;
            
            var format:TextFormat =  new TextFormat("Myriad Pro", 18, 0xe6e6e6);
            setTextFormatForState(format, SkinStates.DOWN);
            setTextFormatForState(format, SkinStates.DOWN_SELECTED);
            setTextFormatForState(format, SkinStates.UP);
            
            label_txt.autoSize = TextFieldAutoSize.LEFT;
		}
        
		/**
		 * Set the text for the button label
		 * @param text - a localized string for button
		 */  
		public override function set label(text:String):void
        {
			if(text) {
                // This is intended. We need to set the text first before we can calculate the new width.
                setLabel(text);
                width = label_txt.textWidth + 50;
                setLabel(text);
            }
        }
        
        protected override function drawLabel():void 
        {
            super.drawLabel();
            label_txt.x = 30; // LEFT_MARGIN - 30;
            truncateText();
        }
	}
}