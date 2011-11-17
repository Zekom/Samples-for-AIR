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
	import flash.display.DisplayObject;
	
	import qnx.ui.skins.SkinAssets;
	import qnx.ui.skins.SkinStates;
	import qnx.ui.skins.UISkin;

	
	/**
	 * Provides skin for the back button
	 */ 
	public class BackButtonSkin extends UISkin
	{
        [Embed(source="/../assets/images/Back_frame.png", scaleGridTop="4", scaleGridBottom="5", scaleGridLeft="4", scaleGridRight="5")]
        public static var BackButtonSkinUp:Class;
        
		public function BackButtonSkin()
		{
			super();
            initializeStates();
		}

		protected override function initializeStates():void 
		{
			var upSkin:DisplayObject = new BackButtonSkinUp() 
			setSkinState(SkinStates.UP, upSkin);
			
			var downSkin:DisplayObject = new SkinAssets.BackButtonPressedBlack();
			setSkinState(SkinStates.DOWN,downSkin);
			
			setSkinState( SkinStates.SELECTED, downSkin );
			
			setSkinState( SkinStates.DISABLED, new SkinAssets.BackButtonDisabledBlack() );
			
            
			showSkin( upSkin );
		}
	}
}