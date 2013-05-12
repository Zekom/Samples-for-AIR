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
package qnx.samples.navigationdrilldown
{
	import qnx.fuse.ui.Application;
	import qnx.fuse.ui.navigation.NavigationPane;

	public class NavigationDrillDown extends Application
	{
		public function NavigationDrillDown()
		{
		}
		
		
		override protected function onAdded():void
		{
			super.onAdded();
			
			var pane:NavigationPane = new NavigationPane();
			pane.push( new ContinentPage() );
			scene = pane;
		}

	}
}
