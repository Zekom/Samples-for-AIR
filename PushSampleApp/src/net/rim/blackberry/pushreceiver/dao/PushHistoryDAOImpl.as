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
	import flash.data.SQLStatement;
	
	import net.rim.blackberry.pushreceiver.vo.PushHistoryItem;
	
	/**
	 * DAO related to the handling / processing items in the push history.
	 * The push history is used to check for potential duplicate pushes being sent.
	 * Any duplicate pushes that are detected will be discarded and not displayed to the user.
	 */
	public class PushHistoryDAOImpl extends BaseDAOImpl implements PushHistoryDAO
	{
		public function PushHistoryDAOImpl()
		{
			super();
		}
		
		public function createPushHistoryTable():void
		{
			var sql:String = "CREATE TABLE IF NOT EXISTS pushhistory (rownum INTEGER PRIMARY KEY AUTOINCREMENT, itemid TEXT);";
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = getSQLConnection();
			stmt.text = sql;
			
			try {
				stmt.execute();
			} catch(e:Error) {
				trace("Error executing SQL statement: " + e.message + ".\r" + e.getStackTrace());
			}
		}
		
		public function addPushHistoryItem(item:PushHistoryItem):void
		{
			var sql:String = "INSERT INTO pushhistory (rownum, itemid) VALUES (?, ?);";
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = getSQLConnection();
			stmt.text = sql;
			stmt.parameters[0] = null;
			stmt.parameters[1] = item.itemId;
			
			try {
				stmt.execute();
			} catch(e:Error) {
				trace("Error executing SQL statement: " + e.message + ".\r" + e.getStackTrace());
			}
		}
		
		public function removeOldestPushHistoryItem():void
		{
			var sql:String = "DELETE FROM pushhistory WHERE rownum = (SELECT min(rownum) FROM pushhistory);";
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = getSQLConnection();
			stmt.text = sql;
			
			try {
				stmt.execute();
			} catch(e:Error) {
				trace("Error executing SQL statement: " + e.message + ".\r" + e.getStackTrace());
			}
		}
		
		public function removeAllPushHistoryItems():void
		{
			var sql:String = "DROP TABLE pushhistory;";	
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = getSQLConnection();
			stmt.text = sql;
			
			try {
				stmt.execute();
			} catch(e:Error) {
				trace("Error executing SQL statement: " + e.message + ".\r" + e.getStackTrace());
			}
		}
		
		public function getPushHistoryItem(pushHistoryItemId:String):PushHistoryItem
		{
			var sql:String = "SELECT rownum, itemid FROM pushhistory WHERE itemid = ?;";
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = getSQLConnection();
			stmt.text = sql;
			stmt.parameters[0] = pushHistoryItemId;
			
			try {
				stmt.execute();
			} catch(e:Error) {
				trace("Error executing SQL statement: " + e.message + ".\r" + e.getStackTrace());
				return null;
			}
			
			var result:Array = stmt.getResult().data;
			
			if (result && result.length == 1) {
				return retrievePushHistoryItem(result[0]);
			} else {
				return null;
			}
		}
		
		public function getPushHistoryCount():int
		{
			var sql:String = "SELECT COUNT(*) AS count FROM pushhistory;";
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = getSQLConnection();
			stmt.text = sql;
			
			try {
				stmt.execute();
			} catch(e:Error) {
				trace("Error executing SQL statement: " + e.message + ".\r" + e.getStackTrace());
				return -1;
			}
			
			var result:Array = stmt.getResult().data;
			
			if (result && result.length == 1) {
				return result[0].count;
			} else {
				return -1;
			}
		}
		
		private function retrievePushHistoryItem(o:Object):PushHistoryItem 
		{
			var pushHistoryItem:PushHistoryItem = new PushHistoryItem();
			pushHistoryItem.seqNum = o.rownum;
			pushHistoryItem.itemId = o.itemid;
			
			return pushHistoryItem;
		}
	}
}