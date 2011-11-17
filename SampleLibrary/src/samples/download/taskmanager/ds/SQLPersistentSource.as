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

package samples.download.taskmanager.ds
{
    import flash.data.SQLConnection;
    import flash.data.SQLResult;
    import flash.data.SQLStatement;
    import flash.errors.SQLError;
    import flash.filesystem.File;
    
    import samples.download.taskmanager.FileTransferTask;
    import samples.download.taskmanager.Task;
    
    internal class SQLPersistentSource
    {
        private var _dbfile:File;
        private var _conn:SQLConnection = new SQLConnection();
        
        private static const FETCH_TASKS:String = "SELECT * from TaskQueue WHERE Application = '";
        private static const FETCH_ALL_TASKS:String = "SELECT * from TaskQueue";
        private static const FETCH_ALL_APPLICATIONS:String = "SELECT DISTINCT Application from TaskQueue";
        private static const INSERT_TASK:String = "INSERT into TaskQueue (Application, ID , Type, Context, Status, Priority , Start_Time, End_Time, Content_Length, Current_Offset, Error, Remote_URL, Local_URL, isDownloaded, SupportHttpHeadRequest, CustomData) VALUES (:Application, :ID , :Type, :Context, :Status, :Priority , :Start_Time, :End_Time, :Content_Length, :Current_Offset, :Error, :Remote_URL, :Local_URL, :isDownloaded, :HttpHeadRequest, :CustomData);";
        private static const DELETE_TASKS:String = "DELETE from TaskQueue WHERE Application= '";
        private static const UPDATE_TASK:String = "UPDATE TaskQueue SET Context = :Context, Status = :Status, Priority = :Priority, Start_Time = :Start_Time, End_Time = :End_Time, Content_Length = :Content_Length, Current_Offset = :Current_Offset, Error = :Error, Remote_URL = :Remote_URL, Local_URL = :Local_URL, isDownloaded = :isDownloaded WHERE Application = :Application AND ID = :ID";
        private static const COUNT_TASK:String = "SELECT COUNT(Application) from TaskQueue WHERE Application = '";
        private static const MASK_TASK:String = "' AND ID = '";
        
        public function SQLPersistentSource(conn:SQLConnection)
        {
            try 
            {
                _conn = conn
                
                var query:SQLStatement = new SQLStatement();
                query.sqlConnection = _conn;
                query.text = "CREATE TABLE IF NOT EXISTS TaskQueue (Type NUMERIC, Application TEXT, Context NUMERIC, ID TEXT, Status NUMERIC, Priority NUMERIC, Start_Time NUMERIC, End_Time NUMERIC, Error TEXT, isDownloaded NUMERIC, Remote_URL TEXT, Local_URL TEXT, Content_Length NUMERIC, Current_Offset NUMERIC, SupportHttpHeadRequest INTEGER, CustomData TEXT);"
                query.execute();
            } catch (err:SQLError) {
                trace("Cannot create DB Connection:" + err.message);
                throw new Error("Cannot create DB Connection:" + err.message);
            }
        }
        
        public function addTask(task:Task):void
        {
            try 
            {
                var insertStmt:SQLStatement = new SQLStatement();
                insertStmt.sqlConnection = _conn;
                insertStmt.text = INSERT_TASK;
                safeModify(insertStmt, task as FileTransferTask);
                insertStmt.parameters[":Type"]            = task.getTaskType();
                insertStmt.parameters[":CustomData"]      = task.getCustomData();
                insertStmt.parameters[":HttpHeadRequest"] = task.supportsHttpHead ? 1: 0;
                insertStmt.execute();
            } catch(err:SQLError) {
                trace("Can't insert task:" + err.message);
            }
        }
        
        public function addTasks(tasks:Array):void
        {
            _conn.begin();
            for each (var task:Task in tasks) {
                addTask(task);
            }
            
            // PR 87374: although we've called begin(), transaction might have been closed already, just skip commit for now.
            if (_conn.inTransaction)
                _conn.commit();
        }
        
        public function removeTask(task:Task):void
        {
            modify(DELETE_TASKS + task.getApplicationId() + MASK_TASK + task.getId() + "'");
        }
        
        public function getAllTasksByAppId(appId:String):Array
        {
            return fetchAllTasksById(appId);
        }
        
        public function getAllTasks():Array
        {
            return fetchAllTasks();
        }
        
        public function getAllApplications():Array
        {
            return fetchAllApplications();
        }
        
        public function removeAllTasks(appId:String):void
        {
            modify(DELETE_TASKS + appId + "'");
        }
        
        public function saveTask(task:Task):void
        {
            try {
                var insertStmt:SQLStatement = new SQLStatement();
                
                insertStmt.sqlConnection = _conn;
                insertStmt.text = UPDATE_TASK;
                safeModify(insertStmt, task as FileTransferTask);
                insertStmt.execute();
            } catch(err:SQLError) {
                trace("Can't save task:" + err.message);
            }
        }
        
        public function size(appId:String):int
        {
            var results:Array = fetch(COUNT_TASK + appId + "'");
            
            if (results == null)
                return 0;
            else 
                return results[0]["COUNT(Application)"];
        }
        
        public function close():void
        {
            _conn.close();
        }
        
        private function fetch(sql:String):Array
        {
            try 
            {
                var selectStmt:SQLStatement = new SQLStatement();
                selectStmt.sqlConnection = _conn;
                selectStmt.text = sql;
                selectStmt.execute();
                var result:SQLResult = selectStmt.getResult();
                if (result.data)
                    return result.data;
                else
                    return null;
            } catch (err:Error) {
                trace("Error executing: " + sql + ": " + err.message);
            }
            return null;
        }
        
        private function safeModify(statement:SQLStatement, task:FileTransferTask):void 
        {
            statement.parameters[":Application"]   = task.getApplicationId();
            statement.parameters[":ID"]            = task.getId();
            statement.parameters[":Context"]       = task.getContext()
            statement.parameters[":Status"]        = task.getStatus();
            statement.parameters[":Priority"]      = task.isPriority() ? 1:0;
            statement.parameters[":Start_Time"]    = task.getStartTime();
            statement.parameters[":End_Time"]      = task.getEndTime();
            statement.parameters[":Content_Length"] = task.getContentLength();
            statement.parameters[":Current_Offset"] = task.getCurrentOffset();
            statement.parameters[":Error"]         = task.getSerializedError();
            statement.parameters[":Remote_URL"]    = task.getRemoteFileURL();
            statement.parameters[":Local_URL"]     = task.getLocalFileURL();
            statement.parameters[":isDownloaded"]  = task.isDownload() ? 1:0;
        }
        
        private function modify(sql:String):void
        {
            try 
            {
                var insertStmt:SQLStatement = new SQLStatement();
                insertStmt.sqlConnection = _conn;
                insertStmt.text = sql;
                insertStmt.execute();
            } catch (err:Error) {
                trace("Error executing:" + sql + ": " + err.message);
            }
        }
        
        private function fetchTaskById(applicationId:String, taskId:String):Task
        {
            var results:Array = fetch(FETCH_TASKS + applicationId + MASK_TASK + taskId + "'");
            
            if (results == null)
                return null;
            
            var tasks:Array = TaskSerializer.deSerialize(results); 
            
            if (tasks.length > 1)
            {
                throw new Error("More than one task is found");
            }	
            
            return tasks[0];
        }		
        
        private function fetchTask(task:Task):Task
        {
            return fetchTaskById(task.getApplicationId(), task.getId());
        }	
        
        private function fetchAllTasksById(appId:String):Array
        {
            var results:Array = fetch(FETCH_TASKS + appId + "'");
            
            if (results == null)
                return null;
            
            return TaskSerializer.deSerialize(results);
        }
        
        private function fetchAllTasks():Array
        {
            var results:Array = fetch(FETCH_ALL_TASKS);
            
            if (results == null)
                return null;
            
            return TaskSerializer.deSerialize(results);
        }
        
        private function fetchAllApplications():Array
        {
            var apps:Array = new Array();
            var results:Array = fetch(FETCH_ALL_APPLICATIONS);
            
            if (results == null)
                return null;
            
            for (var i:int=0;i<results.length;i++)
            {
                if (results[i].Application)
                {
                    apps.push(results[i].Application);
                }
            }
            
            return apps;
        }
        
    }
}