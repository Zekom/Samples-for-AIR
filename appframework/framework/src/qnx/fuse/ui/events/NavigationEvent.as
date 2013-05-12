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


package qnx.fuse.ui.events
{
	import flash.events.Event;

	/**
	 * The <code>NavigationEvent</code> dispatches navigation related events.
	 */
	public class NavigationEvent extends Event
	{
		
		/**
		 * Dispatched by a <code>NavigationPane</code> when a page is popped of its stack.
		 * 
		 *  <p>The NavigationEvent.POP constant defines the value of the
	     *  <code>type</code> property of the event object for an
	     *  <code>panePop</code> event.</p>
	     *
	     *  <p>The properties of the event object have the following values:</p>
	     *  <table class="innertable">
	     *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr><td><code>action</code></td><td>The action that was selected.</td></tr>
	     *     <tr><td><code>bubbles</code></td><td>false</td></tr>
	     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
	     *     <tr><td><code>currentTarget</code></td><td>The object that is actively processing the Event object with an event listener.</td></tr>
	     *     <tr><td><code>type</code></td><td>NavigationEvent.POP</td></tr>
	     *  </table>
	     *
	     *  @eventType panePop
		 * 
		 */
		public static const POP:String = "panePop";
		
		/**
		 * Dispatched by <code>BasePane</code> when pane has transitioned in.
		 * 
		 *  <p>The NavigationEvent.TRANSITION_IN_COMPLETE constant defines the value of the
	     *  <code>type</code> property of the event object for an
	     *  <code>transitionInComplete</code> event.</p>
	     *
	     *  <p>The properties of the event object have the following values:</p>
	     *  <table class="innertable">
	     *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr><td><code>action</code></td><td>The action that was selected.</td></tr>
	     *     <tr><td><code>bubbles</code></td><td>false</td></tr>
	     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
	     *     <tr><td><code>currentTarget</code></td><td>The object that is actively processing the Event object with an event listener.</td></tr>
	     *     <tr><td><code>type</code></td><td>NavigationEvent.TRANSITION_IN_COMPLETE</td></tr>
	     *  </table>
	     *
	     *  @eventType transitionInComplete
		 * 
		 */
		public static const TRANSITION_IN_COMPLETE:String = "transitionInComplete";
		
		/**
		 * Dispatched by <code>BasePane</code> when pane has transitioned out.
		 * 
		 *  <p>The NavigationEvent.TRANSITION_OUT_COMPLETE constant defines the value of the
	     *  <code>type</code> property of the event object for an
	     *  <code>transitionOutComplete</code> event.</p>
	     *
	     *  <p>The properties of the event object have the following values:</p>
	     *  <table class="innertable">
	     *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr><td><code>action</code></td><td>The action that was selected.</td></tr>
	     *     <tr><td><code>bubbles</code></td><td>false</td></tr>
	     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
	     *     <tr><td><code>currentTarget</code></td><td>The object that is actively processing the Event object with an event listener.</td></tr>
	     *     <tr><td><code>type</code></td><td>NavigationEvent.TRANSITION_OUT_COMPLETE</td></tr>
	     *  </table>
	     *
	     *  @eventType transitionOutComplete
		 * 
		 */
		public static const TRANSITION_OUT_COMPLETE:String = "transitionOutComplete";
		
		
		/**
		 * Creates a <code>NavigationEvent</code> instance.
		 * @param type The type of event.
		 * @param bubbles If the event bubbles.
		 * @param cancelable If the event is cancelable.
		 */
		public function NavigationEvent( type:String, bubbles:Boolean = false, cancelable:Boolean = false )
		{
			super( type, bubbles, cancelable );
		}
	}
}
