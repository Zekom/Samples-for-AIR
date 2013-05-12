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
	import qnx.fuse.ui.events.ListEvent;
	import qnx.fuse.ui.listClasses.List;
	import qnx.fuse.ui.titlebar.TitleBar;
	import qnx.fuse.ui.navigation.Page;
	import qnx.ui.data.IDataProvider;

	/**
	 * @author jdolce
	 */
	public class ListPage extends Page
	{
		private var __data:IDataProvider;
		private var __title:String;
		
		public function ListPage( title:String, data:IDataProvider )
		{
			__data = data;
			__title = title;
			super();
		}

		override protected function onAdded():void
		{
			super.onAdded();
			
			titleBar = new TitleBar();
			titleBar.title = __title;
			
			var list:List = new List();
			list.dataProvider = __data;
			list.addEventListener( ListEvent.ITEM_CLICKED, onClick );
			
			content = list;
		}

		private function onClick( event:ListEvent ):void
		{
			goToNextPage( event.data );
		}
		
		protected function goToNextPage( item:Object ):void
		{
			
		}
		
	}
}
