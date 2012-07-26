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
	
	import net.rim.blackberry.pushreceiver.vo.Push;
	
	/**
	 * DAO related to the handling / processing of pushes.
	 */
	public class PushDAOImpl extends BaseDAOImpl implements PushDAO
	{
		public function PushDAOImpl()
		{
			super();
		}
		
		public function createPushTable():void
		{
			var sql:String = "CREATE TABLE IF NOT EXISTS push (seqnum INTEGER PRIMARY KEY AUTOINCREMENT, "
                + "pushdate TEXT, type TEXT, pushtime TEXT, extension TEXT, content BLOB, unread TEXT);";
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = getSQLConnection();
			stmt.text = sql;
			
			try {
				stmt.execute();
			} catch(e:Error) {
				trace("Error executing SQL statement: " + e.message + ".\r" + e.getStackTrace());
			}
		}
		
		public function addPush(push:Push):int
		{
			var sql:String = "INSERT INTO push (seqnum, pushdate, type, pushtime, extension, content, unread) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?);";
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = getSQLConnection();
			stmt.text = sql;
			stmt.parameters[0] = null;
			stmt.parameters[1] = push.pushDate;
			stmt.parameters[2] = push.contentType;
			stmt.parameters[3] = push.pushTime;
			stmt.parameters[4] = push.fileExtension;
			stmt.parameters[5] = push.content;
			if (push.unread) {
				stmt.parameters[6] = "T";
			} else {
				stmt.parameters[6] = "F";
			}
			
			try {
				stmt.execute();
				
				return stmt.getResult().lastInsertRowID;
			} catch(e:Error) {
				trace("Error executing SQL statement: " + e.message + ".\r" + e.getStackTrace());
			}
			
			return -1;
		}
		
		public function removePush(pushSeqNum:int):void
		{
			var sql:String = "DELETE FROM push WHERE seqnum = ?;";	
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = getSQLConnection();
			stmt.text = sql;
			stmt.parameters[0] = pushSeqNum;
			
			try {
				stmt.execute();
			} catch(e:Error) {
				trace("Error executing SQL statement: " + e.message + ".\r" + e.getStackTrace());
			}
		}
		
		public function getPush(pushSeqNum:int):Push
		{
			var sql:String = "SELECT seqnum, pushdate, type, pushtime, extension, content, unread FROM PUSH WHERE seqnum = ?";
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = getSQLConnection();
			stmt.text = sql;
			stmt.parameters[0] = pushSeqNum;
			
			try {
				stmt.execute();
			} catch(e:Error) {
				trace("Error executing SQL statement: " + e.message + ".\r" + e.getStackTrace());
				return null;
			}
			
			var result:Array = stmt.getResult().data;
			
			if (result && result.length == 1) {
				return retrievePush(result[0]);
			} else {
				return null;
			}
		}
		
		public function getUnreadPushCount():int {
			var sql:String = "SELECT COUNT(*) AS count FROM push WHERE unread = ?;";
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = getSQLConnection();
			stmt.text = sql;
			stmt.parameters[0] = "T";
			
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
		
		public function removeAllPushes():void 
		{
			var sql:String = "DROP TABLE push;";	
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = getSQLConnection();
			stmt.text = sql;
			
			try {
				stmt.execute();
			} catch(e:Error) {
				trace("Error executing SQL statement: " + e.message + ".\r" + e.getStackTrace());
			}
		}
		
		public function markPushAsRead(pushSeqNum:int):void 
		{
			var sql:String = "UPDATE push SET unread = ? WHERE seqnum = ?;";	
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = getSQLConnection();
			stmt.text = sql;
			stmt.parameters[0] = "F";
			stmt.parameters[1] = pushSeqNum;
			
			try {
				stmt.execute();
			} catch(e:Error) {
				trace("Error executing SQL statement: " + e.message + ".\r" + e.getStackTrace());
			}		
		}
		
		public function markAllPushesAsRead():void 
		{
			var sql:String = "UPDATE push SET unread = ?;";	
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = getSQLConnection();
			stmt.text = sql;
			stmt.parameters[0] = "F";
			
			try {
				stmt.execute();
			} catch(e:Error) {
				trace("Error executing SQL statement: " + e.message + ".\r" + e.getStackTrace());
			}
		}
		
		public function getAllPushes():Array
		{
			var sql:String = "SELECT seqnum, pushdate, type, pushtime, extension, content, unread "
                        + "FROM push ORDER BY seqnum desc;";
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = getSQLConnection();
			stmt.text = sql;
			
			try {
				stmt.execute();
			} catch(e:Error) {
				trace("Error executing SQL statement: " + e.message + ".\r" + e.getStackTrace());
				return null;
			}
			
			var result:Array = stmt.getResult().data;
			
			var pushes:Array = [];
			if (result && result.length >= 1) {
				
				for (var i:uint = 0; i < result.length; i++) {
					var push:Push = retrievePush(result[i]);
					
					pushes.push(push);
				}
			} 
			
			return pushes;
		}
		
		private function retrievePush(o:Object):Push 
		{			
			var push:Push = new Push();
			
			push.seqNum = o.seqnum;
			push.pushDate = o.pushdate;
			push.contentType = o.type;
			push.pushTime = o.pushtime;
			push.fileExtension = o.extension;
			push.content = o.content;
			
			var unreadStr:String = o.unread;
			
			if (unreadStr == "T") {
				push.unread = true;
			} else {
				push.unread = false;
			}
			
			return push;
		}
	}
}