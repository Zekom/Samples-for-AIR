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
	
	import net.rim.blackberry.pushreceiver.vo.Configuration;
	
	/**
	 * DAO related to the configuration settings of the application.
	 * Note: In our application, we expose the configuration settings to the user.
	 * However, in an actual push application, you would likely have these settings
	 * hard coded under the covers.  We expose them in our application for testing /
	 * debugging purposes.
	 */
	public class ConfigurationDAOImpl extends BaseDAOImpl implements ConfigurationDAO
	{
		public function ConfigurationDAOImpl()
		{
			super();
		}
		
		public function createConfigurationTable():void
		{
			var sql:String = "CREATE TABLE IF NOT EXISTS configuration (appid TEXT, piurl TEXT, ppgurl TEXT, launchapp BIT, usingpublicppg BIT);";
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = getSQLConnection();
			stmt.text = sql;
			
			try {
				stmt.execute();
			} catch(e:Error) {
				trace("Error executing SQL statement: " + e.message + ".\r" + e.getStackTrace());
			}
		}
		
		public function addOrUpdateConfiguration(config:Configuration):void
		{
			if (hasExistingConfiguration()) {
				updateConfiguration(config);
			} else {
				addConfiguration(config);
			}
		}
		
		public function addConfiguration(config:Configuration):void
		{
			var sql:String = "INSERT INTO configuration (appid, piurl, ppgurl, launchapp, usingpublicppg) VALUES (?, ?, ?, ?, ?);";
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = getSQLConnection();
			stmt.text = sql;
			stmt.parameters[0] = config.providerApplicationId;
			stmt.parameters[1] = config.pushInitiatorUrl;
			stmt.parameters[2] = config.ppgUrl;
			if (config.launchApplicationOnPush) {
				stmt.parameters[3] = 1;
			} else {
				stmt.parameters[3] = 0;
			}
			if (config.usingPublicPushProxyGateway) {
				stmt.parameters[4] = 1;
			} else {
				stmt.parameters[4] = 0;
			}
			
			try {
				stmt.execute();
			} catch(e:Error) {
				trace("Error executing SQL statement: " + e.message + ".\r" + e.getStackTrace());
			}
		}
		
		public function updateConfiguration(config:Configuration):void
		{
			var sql:String = "UPDATE configuration SET appid = ?, piurl = ?, ppgurl = ?, launchapp = ?, usingpublicppg = ?;";
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = getSQLConnection();
			stmt.text = sql;
			stmt.parameters[0] = config.providerApplicationId;
			stmt.parameters[1] = config.pushInitiatorUrl;
			stmt.parameters[2] = config.ppgUrl;
			if (config.launchApplicationOnPush) {
				stmt.parameters[3] = 1;
			} else {
				stmt.parameters[3] = 0;
			}
			if (config.usingPublicPushProxyGateway) {
				stmt.parameters[4] = 1;
			} else {
				stmt.parameters[4] = 0;
			}
			
			try {
				stmt.execute();
			} catch(e:Error) {
				trace("Error executing SQL statement: " + e.message + ".\r" + e.getStackTrace());
			}
		}
		
		public function removeConfiguration():void
		{
			var sql:String = "DROP TABLE configuration;";
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = getSQLConnection();
			stmt.text = sql;
		
			try {
				stmt.execute();
			} catch(e:Error) {
				trace("Error executing SQL statement: " + e.message + ".\r" + e.getStackTrace());
			}
		}
		
		public function getConfiguration():Configuration
		{
			var sql:String = "SELECT appid, piurl, ppgurl, launchapp, usingpublicppg FROM configuration;";
			
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
				return retrieveConfiguration(result[0]);
			} else {
				return null;
			}
		}
		
		public function hasExistingConfiguration():Boolean
		{
			var sql:String = "SELECT COUNT(*) AS count FROM configuration;";
			
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
		
		private function retrieveConfiguration(o:Object):Configuration 
		{
			var config:Configuration = new Configuration();
			config.providerApplicationId = o.appid;
			config.pushInitiatorUrl = o.piurl;
			config.ppgUrl = o.ppgurl;
			if (o.launchapp == 1) {
				config.launchApplicationOnPush = true;
			} else {
				config.launchApplicationOnPush = false;
			}
			if (o.usingpublicppg == 1) {
				config.usingPublicPushProxyGateway = true;
			} else {
				config.usingPublicPushProxyGateway = false;
			}
			
			return config;
		}
	}
}