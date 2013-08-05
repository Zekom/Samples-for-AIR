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
package qnx.fuse.ui
{
	import caurina.transitions.Tweener;

	import qnx.events.QNXApplicationEvent;
	import qnx.fuse.ui.applicationMenu.ApplicationMenu;
	import qnx.fuse.ui.core.UIComponent;
	import qnx.fuse.ui.navigation.BasePane;
	import qnx.fuse.ui.navigation.TabbedPane;
	import qnx.fuse.ui.tween.TweenUtils;
	import qnx.fuse.ui.utils.MathUtils;
	import qnx.system.QNXApplication;

	import flash.desktop.NativeApplication;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.SoftKeyboardEvent;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	/**
	 * The <code>Application</code> class is the root class for all applications. 
	 * <p>Your main document class should exten this class. 
	 * This class is responsible for setting the main scene of your applicaiton and managing the z order of certain elements of the application.
	 * Not using this class can potentially cause issues with certain parts of the application.</p>
	 */
	public class Application extends UIComponent
	{
	
		
		static private var __instance:Application;
		
		/**
		* Gets a single instance of the class. 
		**/
		static public function get application():Application
		{
			return( __instance );
		}
				
		/**
		* Gets or sets the scene of the application.
		* <p>
		* The scene of the application is the class that handles navigation in your application. 
		* <code>TabbedPane</code> and <code>NavigationPane</code> are two classes that help with dealing with navigation.
		* If you wish to handle navigation on your own, you can set your scene to any <code>BasePane</code> subclass.
		* </p>
		* 
		* <p>
		* When a <code>TabbedPane</code> is set as the scene, its <code>tabOverflowParent</code> property is automatically set. 
		* This property should not be set when using a <code>TabbedPane</code> as your scene.
		* </p>
		**/
		public function get scene():BasePane
		{
			return( __scene );
		}
		
		public function set scene( value:BasePane ):void
		{
			if( __scene != value )
			{
				if( __scene )
				{
					if( __scene is TabbedPane )
					{
						TabbedPane( __scene ).tabOverflowParent = null;
					}
					
					
					if( contains( __scene ) )
					{
						removeChild( __scene );
					}
				}
				
				if( value is TabbedPane )
				{
					if( __taboverflow == null )
					{
						__taboverflow = new Sprite();
						addChildAt(__taboverflow, 0);
					}
					TabbedPane( value ).tabOverflowParent = __taboverflow;
				}
				__scene = value;
				addChild( __scene );
				invalidateDisplayList();
			}
		}
		
		private var __scene:BasePane;
		private var __taboverflow:Sprite;
		private var __menuCover:Sprite;
		
		private var __menu:ApplicationMenu;
		private var __startMouseY:Number;
		private var __coverDownId:int;
		
		/**
		 * Enables the top down swipe application menu.
		 * <p>
		 * When set to <code>true</code> the applicaiton menu will appear when swiped down from the top.
		 * If no actions have been added to the menu, it will not appear even if this is set to <code>true</code>.
		 * </p>
		 * @default false;
		 */
		public var enableMenu:Boolean = false;
		
		
		/**
		 * Gets a reference to the top swipe Application Menu.
		 */
		public function get menu():ApplicationMenu
		{
			if( __menu == null )
			{
				__menu = new ApplicationMenu();
				
				__menu.y = -menu.height;
				addChildAt( __menu, 0 );
				
				__menuCover = new Sprite();
				var g:Graphics = __menuCover.graphics;
				g.beginFill(0x000000);
				g.drawRect( 0,0,10,10);
				g.endFill();
				__menuCover.alpha = 0;
				
				
				if( stage )
				{
					__menu.width = stage.stageWidth;
					__menuCover.width = stage.stageWidth;
					__menuCover.height = stage.stageHeight;
				}
				
				QNXApplication.qnxApplication.addEventListener(QNXApplicationEvent.SWIPE_START, swipeStart );
			}
			
			return( __menu );
		}

		
		
		/**
		* Creates a <code>Application</code> instance.
		**/
		public function Application()
		{
			if( __instance == null )
			{
				__instance = this;
			}
			super();
		}
		
		/** @private **/
		override protected function init():void
		{
			var appDescriptor:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = appDescriptor.namespace();
			var skb:String = appDescriptor.ns::initialWindow.ns::softKeyboardBehavior;
			
			if( skb && skb == "none" )
			{
				initSoftKeyboard();
			}
			
			super.init();
		}

		private function initSoftKeyboard():void
		{
			stage.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATE, onKeyboardActivate );
			stage.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE, onKeyboardDeactivate );
		}

		private function onKeyboardDeactivate( event:SoftKeyboardEvent ):void
		{
			scene.softKeyboardDeactivated();
		}

		private function onKeyboardActivate( event:SoftKeyboardEvent ):void
		{
			scene.softKeyboardActivated();
		}
		
		/** @private **/
		override protected function onAdded():void
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener( Event.RESIZE, stageResize );
			super.onAdded();
		}

		private function stageResize( event:Event ):void
		{
			layout();
		}
		
		private function layout():void
		{
			if( __scene )
			{
				__scene.width = stage.stageWidth;
				__scene.height = stage.stageHeight;
			}
			
			if( __menu )
			{
				__menu.width = stage.stageWidth;
			}
			
			if( __menuCover )
			{
				__menuCover.width = stage.stageWidth;
				__menuCover.height = stage.stageHeight;
			}
		}
		
		/** @private **/
		override protected function updateDisplayList( unscaledWidth:Number, unscaledHeight:Number ):void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			layout();
		}
		
		
		/////////////////////// MENU METHODS ////////////////////////////////////
		private function swipeStart( event:QNXApplicationEvent ):void
		{
			if( !enableMenu )
			{
				return;
			}
			__startMouseY = NaN;
			addEventListener(Event.ENTER_FRAME, onEnterFrame );
			stage.addEventListener( MouseEvent.MOUSE_UP, onMouseUp );
			addChild( __menuCover );
		}

		private function onMouseUp( event:MouseEvent ):void
		{
			removeEventListener(Event.ENTER_FRAME, onEnterFrame );
			stage.removeEventListener( MouseEvent.MOUSE_UP, onCoverUp );
			stage.removeEventListener( MouseEvent.MOUSE_UP, onMouseUp );
			animateMenu();
		}
		
		private function animateMenu( percent:Number = NaN ):void
		{
			
			if( isNaN( percent ) )
			{
				percent = Math.abs( ( Math.abs( __menu.y )/__menu.height ) - 1 );
			}
			
			if( percent > 0.5 )
			{
				Tweener.addTween( __menu, { y:0, time:percent * .3, transition:TweenUtils.STANDARD_EASE, onUpdate:menuUpdateAnimation, onComplete:menuShowComplete } );
			}
			else
			{
				Tweener.addTween( __menu, { y:-__menu.height, time:Math.abs( percent - 1 ) * 0.3, transition:TweenUtils.STANDARD_EASE, onUpdate:menuUpdateAnimation, onComplete:menuHideComplete } );
			}
		}
		
		private function menuShowComplete():void
		{
			__menuCover.addEventListener(MouseEvent.MOUSE_DOWN, onCoverDown );
		}

		private function onCoverDown( event:MouseEvent ):void
		{
			__menuCover.removeEventListener(MouseEvent.MOUSE_DOWN, onCoverDown );
			__startMouseY = NaN;
			addEventListener(Event.ENTER_FRAME, onEnterFrame );
			stage.addEventListener( MouseEvent.MOUSE_UP, onMouseUp );
			stage.addEventListener( MouseEvent.MOUSE_UP, onCoverUp );
			__coverDownId = setTimeout(clearCoverUp, 250);
		}
		
		private function clearCoverUp():void
		{
			stage.removeEventListener( MouseEvent.MOUSE_UP, onCoverUp );
		}
		
		private function onCoverUp( event:MouseEvent ):void
		{
			clearTimeout( __coverDownId );
			stage.removeEventListener( MouseEvent.MOUSE_UP, onCoverUp );
			if( isNaN( __startMouseY ) || Math.abs( __startMouseY - stage.mouseY ) < 5 )
			{
				animateMenu( 0 );
			}
		}
		
		private function menuHideComplete():void
		{
			removeChild( __menuCover );
		}
		
		private function menuUpdateAnimation():void
		{
			scene.y = Math.floor( __menu.y + __menu.height );
			__menuCover.y = scene.y;
			
			var percent:Number = Math.abs( ( Math.abs( __menu.y )/__menu.height ) - 1 );
			__menuCover.alpha = Math.max( 0, percent - 0.5 );
		}
		
		private function onEnterFrame( e:Event ):void
		{
			//We sometimes get bad mouse event positions when swiping from the top bezel.
			if( stage.mouseY > stage.stageHeight )
			{
				return;
			}
			
			if( isNaN( __startMouseY ) )
			{
				__startMouseY = stage.mouseY - __menu.y;
			}
			
			var posy:Number = MathUtils.constrain( Math.round( stage.mouseY - __startMouseY ), -__menu.height, 0 );
			__menu.y = posy;
			menuUpdateAnimation();
		}
	}
}
