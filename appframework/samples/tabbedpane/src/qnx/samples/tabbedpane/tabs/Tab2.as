/*
* Copyright (c) 2012 Research In Motion Limited.
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
package qnx.samples.tabbedpane.tabs
{
	import caurina.transitions.Tweener;

	import qnx.fuse.ui.core.Action;
	import qnx.fuse.ui.core.ActionBase;
	import qnx.fuse.ui.display.Image;
	import qnx.fuse.ui.navigation.Page;
	import qnx.fuse.ui.titlebar.TitleBar;
	import qnx.fuse.ui.tween.TweenUtils;
	import qnx.samples.tabbedpane.Assets;

	import flash.display.Sprite;

	/**
	 * @author jdolce
	 */
	public class Tab2 extends Page
	{
		
		private var __riseAction:Action;
		private var __image:Image;
		private var __holder:Sprite;
		
		
		public function Tab2()
		{
		}
		
		
		override protected function onAdded():void
		{
			super.onAdded();
			titleBar = new TitleBar();
			titleBar.title = "Tab 2";
			
			
			__riseAction = new Action( "Rise", Assets.DEFAULT_ACTION );

			var a:Vector.<ActionBase> = new Vector.<ActionBase>();
			a.push( __riseAction );

			
			actions = a;
			
			__holder = new Sprite();
			addChild( __holder );
			
			__image = new Image();
			__image.alpha = 0.2;
			__image.setImage( new Assets.PICTURE1() );
			__holder.addChild( __image );
			
			__image.x = -Math.round( __image.width/2 );
			__image.y = -Math.round( __image.height/2 );
		}
		
		override public function onActionSelected( action:ActionBase ):void
		{
			super.onActionSelected( action );
			
			if( __riseAction == action )
			{
				__image.alpha = 0.2;
				Tweener.addTween( __image, { alpha:1, time:0.5, transition:TweenUtils.STANDARD_EASE } );
				
				__holder.scaleX = 1;
				__holder.scaleY = 1;
				Tweener.addTween( __holder, { scaleX:1.5, scaleY:1.5, time:0.5, transition:TweenUtils.STANDARD_EASE } );
			}
		}

		override protected function updateDisplayList( unscaledWidth:Number, unscaledHeight:Number ):void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			
			__holder.x = Math.round( unscaledWidth / 2 );
			__holder.y = Math.round( unscaledHeight / 2 );
		}
		
	}
}
