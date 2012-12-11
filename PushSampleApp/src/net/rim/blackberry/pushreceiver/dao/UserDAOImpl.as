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
	
	import net.rim.blackberry.pushreceiver.vo.User;
	
	/**
	 * DAO related to the handling / processing of users that will either register 
	 * to receive pushes or unregister from receiving pushes.
	 */	
	public class UserDAOImpl extends BaseDAOImpl implements UserDAO
	{
		public function UserDAOImpl()
		{
			super();
		}
		
		public function createUserTable():void
		{
			var sql:String = "CREATE TABLE IF NOT EXISTS user (userid TEXT, passwd TEXT);";
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = getSQLConnection();
			stmt.text = sql;
			
			try {
				stmt.execute();
			} catch(e:Error) {
				trace("Error executing SQL statement: " + e.message + ".\r" + e.getStackTrace());
			}
		}
		
		public function addOrUpdateUser(user:User):void
		{
			if (hasExistingUser()) {
				updateUser(user);	
			} else {
				addUser(user);
			}
		}
		
		public function addUser(user:User):void
		{
			var sql:String = "INSERT INTO user (userid, passwd) VALUES (?, ?);";
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = getSQLConnection();
			stmt.text = sql;
			stmt.parameters[0] = user.userId;
			stmt.parameters[1] = user.password;
			
			try {
				stmt.execute();
			} catch(e:Error) {
				trace("Error executing SQL statement: " + e.message + ".\r" + e.getStackTrace());
			}
		}
		
		public function updateUser(user:User):void 
		{
			var sql:String = "UPDATE user SET userid = ?, passwd = ?;";
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = getSQLConnection();
			stmt.text = sql;
			stmt.parameters[0] = user.userId;
			stmt.parameters[1] = user.password;
			
			try {
				stmt.execute();
			} catch(e:Error) {
				trace("Error executing SQL statement: " + e.message + ".\r" + e.getStackTrace());
			}
		}
		
		public function removeUser():void
		{
			var sql:String = "DROP TABLE user;";
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = getSQLConnection();
			stmt.text = sql;
			
			try {
				stmt.execute();
			} catch(e:Error) {
				trace("Error executing SQL statement: " + e.message + ".\r" + e.getStackTrace());
			}
		}
		
		public function getUser():User
		{
			var sql:String = "SELECT userid, passwd FROM user;";
			
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
			
			if (result && result.length == 1) {
				return retrieveUser(result[0]);
			} else {
				return null;
			}
		}
		
		public function hasExistingUser():Boolean 
		{
			var sql:String = "SELECT COUNT(*) AS count FROM user;";
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = getSQLConnection();
			stmt.text = sql;
			
			try {
				stmt.execute();
			} catch(e:Error) {
				trace("Error executing SQL statement: " + e.message + ".\r" + e.getStackTrace());
				return false;
			}
			
			var result:Array = stmt.getResult().data;
			
			if (result && result.length == 1) {
				var count:int = result[0].count;
				
				if (count > 0) {
					return true;
				} else {
					return false;
				}
			} else {
				return false;
			}
		}
		
		private function retrieveUser(o:Object):User 
		{
			var user:User = new User();
			user.userId = o.userid;
			user.password = o.passwd;
			
			return user;
		}
	}
}