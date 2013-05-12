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
package qnx.samples.tabbedpane
{
	import qnx.fuse.ui.Application;
	import qnx.fuse.ui.navigation.Tab;
	import qnx.fuse.ui.navigation.TabbedPane;
	import qnx.samples.tabbedpane.tabs.Tab1;
	import qnx.samples.tabbedpane.tabs.Tab2;
	import qnx.samples.tabbedpane.tabs.Tab3;
	import qnx.samples.tabbedpane.tabs.Tab4;
	import qnx.samples.tabbedpane.tabs.Tab5;

	public class TabbedPaneSample extends Application
	{
		public function TabbedPaneSample()
		{
		}

		override protected function onAdded():void
		{
			super.onAdded();
			
			var pane:TabbedPane = new TabbedPane();
			
			var tabs:Vector.<Tab> = new Vector.<Tab>();
			
			tabs.push( new Tab( "Tab 1", null, null, Tab1 ) );
			tabs.push( new Tab( "Tab 2", null, null, Tab2 ) );
			tabs.push( new Tab( "Tab 3", null, null, Tab3 ) );
			tabs.push( new Tab( "Tab 4", null, null, Tab4 ) );
			tabs.push( new Tab( "Tab 5", null, null, Tab5 ) );
			
			pane.tabs = tabs;
			pane.activeTab = tabs[ 0 ];
			scene = pane;
		}

	}
}
