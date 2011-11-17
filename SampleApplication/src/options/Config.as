
/*
* Copyright (c) 2011 Research In Motion Limited.
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
package options
{
    import flash.data.SQLConnection;
    import flash.data.SQLResult;
    import flash.data.SQLStatement;
    import flash.events.SQLErrorEvent;
    import flash.filesystem.File;
    
    
    public class Config
    {
        private static var _instance:Config;
        private static var _connection:SQLConnection;
        private var _dbfile:File = File.applicationStorageDirectory.resolvePath("sample.db");
        private var _history:Array;
        
        
        private static const MAX_SEARCH_HISTORY:int = 100;
        private static const MAX_SEARCH_HISTORY_RESULTS:int = 5;
        private static const MAX_BROWSE_HISTORY:int = 20;
        private static const MAX_BROWSE_HISTORY_RESULTS:int = 10;
        public static const OPTION_ONE:String 	    = "OptionOne";
        public static const OPTION_TWO:String 	    = "OptionTwo";
        public static const OPTION_THREE:String 	    = "OptionThree";
        
        public static const OPTION_ONE_DEFAULT:String = "1";  //"1" == true
        public static const OPTION_TWO_DEFAULT:String = "0";  //"0" == false
        public static const OPTION_THREE_DEFAULT:String = "1";  //"1" == true
        
        public function get DataBaseConnection():SQLConnection 
        {
            return _connection;
        }
        
        /*use getConfig to create a Config, this is a singleton*/
        public function Config()
        {
            initConfig();
        }
        protected function initConfig():void
        {
            _connection = new SQLConnection();
            _connection.addEventListener(SQLErrorEvent.ERROR, sqlError);
            _connection.open(_dbfile);
            
            var query:SQLStatement = new SQLStatement();
            query.sqlConnection = _connection;
            
            query.text = "create table if not exists config (propertyName STRING NOT NULL, value STRING NOT NULL);";
            query.execute();
            
            query.text = "create table if not exists search_history (text STRING NOT NULL UNIQUE, creation_time DATETIME NOT_NULL DEFAULT CURRENT_TIMESTAMP);";
            query.execute();
            
            query.text = "create table if not exists browse_history (releaseId NUMERIC NOT NULL UNIQUE, releaseXml STRING NOT NULL, creation_time DATETIME NOT_NULL DEFAULT CURRENT_TIMESTAMP);";
            query.execute();
            
            _history = new Array();
        
        }
        
        public static function getConfig():Config 
        {
            if (_instance == null) {
                _instance = new Config();	
            }
            return _instance;
        }
        
        
        public function getValue(propertyName:String, defaultValue:String):String
        {
            var value:String = defaultValue;
            var query:SQLStatement = new SQLStatement();
            query.sqlConnection = _connection;
            
            query.text = "select * FROM config where propertyName = (:propertyName);";
            query.parameters[":propertyName"] = propertyName;
            query.execute(1);
            var result:SQLResult = query.getResult();
            if (result.data == null) {
                
                //set db value to false if value not set                 
                query = new SQLStatement();
                query.sqlConnection = _connection;
                query.text = "INSERT into config(propertyName, value) VALUES (:propertyName, :value);";
                query.parameters[":propertyName"] = propertyName;
                query.parameters[":value"] = defaultValue;
                query.execute();
                
            } else{
                value = result.data[0].value;
            }
            
            return value;
        }    
        
        public function saveValue(propertyName:String, value:String):void 
        {
            var query:SQLStatement = new SQLStatement();
            query.sqlConnection = _connection;
            query.text = "UPDATE config SET value = (:value) WHERE propertyName = (:propertyName);";
            query.parameters[":value"] = value;
            query.parameters[":propertyName"] = propertyName;
            query.execute();
            var result:SQLResult = query.getResult();
        }
        
        private function sqlError(evt:SQLErrorEvent):void {
            trace(evt.text);
        }
        
        /**
         * Should be called when the application is closing
         * */
        public static function dispose():void 
        {
            if (_connection)
                _connection.close();
            _instance = null;
        }
        
        
        public function getSearchHistory(currentText:String=null):Array 
        {
            var query:SQLStatement = new SQLStatement();
            query.sqlConnection = _connection;
            
            query.text = "SELECT * FROM search_history";
            if (currentText) {
                query.text += " WHERE text LIKE '%" + currentText + "%'";
            }
            query.text += " ORDER BY creation_time DESC LIMIT " + MAX_SEARCH_HISTORY_RESULTS;
            query.execute(MAX_SEARCH_HISTORY_RESULTS);
            
            var result:SQLResult = query.getResult();
            var history:Array = new Array();
            for each (var item:Object in result.data) {
                history.push(item["text"]);
            }
            return history;
        }
        
        
        public function saveSearchHistory(currentText:String):void 
        {
            // Keep a MAX_SEARCH_HISTORY in the database 
            var query:SQLStatement = new SQLStatement();
            query.sqlConnection = _connection;
            query.text = "SELECT COUNT(*) FROM search_history;";
            query.execute();
            
            var result:SQLResult = query.getResult();
            var count:int = result.data[0]["COUNT(*)"] as int;
            if (count > MAX_SEARCH_HISTORY) {
                query.text = "DELETE FROM search_history where rowid = (select rowid from search_history ORDER BY creation_time LIMIT " + (count - MAX_SEARCH_HISTORY) + ");";
                query.execute();
            }
            
            // Do not save empty searches
            if (currentText == null || currentText == "") {
                return;
            }
            
            query.text = "INSERT OR REPLACE into search_history (text) VALUES (:searchInput);";
            query.parameters[":searchInput"] = currentText;
            query.execute();
        }
        
        public function OptionOne():Boolean
        {
            var value:Boolean;
            switch ( Config.getConfig().getValue(Config.OPTION_ONE,Config.OPTION_ONE_DEFAULT ) ) {
                case "1":
                    value= true;
                    break;
                
                default:
                    value = false;
                    break;                    
            }
            return value;
        }
        public function OptionTwo():Boolean
        {
            var value:Boolean;
            switch ( Config.getConfig().getValue(Config.OPTION_TWO,Config.OPTION_TWO_DEFAULT ) ) {
                case "1":
                    value= true;
                    break;
                
                default:
                    value = false;
                    break;                    
            }
            return value;
        }
        public function OptionThree():Boolean
        {
            var value:Boolean;
            switch ( Config.getConfig().getValue(Config.OPTION_THREE,Config.OPTION_THREE_DEFAULT ) ) {
                case "1":
                    value= true;
                    break;
                
                default:
                    value = false;
                    break;                    
            }
            return value;
        }
        
        public function deleteBrowseHistory():void 
        {
            var query:SQLStatement = new SQLStatement();
            query.sqlConnection = _connection;
            
            query.text = "DELETE FROM browse_history";
            query.execute();
        }
        
    }
}