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

package net.rim.blackberry.pushreceiver.dao
{
	import flash.data.SQLConnection;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.filesystem.File;
	
	import net.rim.blackberry.pushreceiver.ui.ListContainer;
	
	import qnx.fuse.ui.dialog.AlertDialog;
	
	/**
	 * The base class for the DAO (Data Access Object) classes.
	 */
	public class BaseDAOImpl
	{
		protected var connection:SQLConnection;
		
		public function BaseDAOImpl()
		{
		}
		
		public function getSQLConnection():SQLConnection {
			if (connection) {
				return connection;
			}
			
			connection = new SQLConnection();
			
			var database:File = File.applicationStorageDirectory.resolvePath("pushreceiver.db");
			
			try
			{
				connection.open(database);
			}
			catch (error:ErrorEvent)
			{				
				var alertDialog:AlertDialog = new AlertDialog();
				alertDialog.title = "Database Error (" + error.errorID + ")";
				alertDialog.message = "Error: " + error.text;
				alertDialog.addButton("Ok");
				alertDialog.show();
				
				connection = null;
			}
			
			return connection;
		}
	}
}