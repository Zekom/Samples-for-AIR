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
    import flash.utils.Dictionary;
    
    import samples.download.taskmanager.Task;
    
    public class SQLTaskDataSource
    {
        private var applicationTable:Dictionary = null;
        private var taskTable:Dictionary = null;
        private var taskArray:Array = null;
        private var persistentStore:SQLPersistentSource = null;	
        
        public function SQLTaskDataSource(conn:SQLConnection)
        {
            this.setPersistentSource(new SQLPersistentSource(conn));
        }
        
        protected function setPersistentSource(source:SQLPersistentSource):void
        {
            persistentStore = source;
            
            checkIntegrity(persistentStore);		
            
            taskArray = persistentStore.getAllTasks();
            if (taskArray == null)
                taskArray = new Array();
            
            applicationTable = new Dictionary();
            var apps:Array = persistentStore.getAllApplications();
            
            for each ( var app:String in apps )
            {
                applicationTable[app] =  new Dictionary();
            }
            
            for each ( var task:Task in taskArray )
            {
                applicationTable[task.getApplicationId()][task.getId()] = task;
            }
        }
        
        protected function getPersistentSource():SQLPersistentSource
        {
            return this.persistentStore;			
        }
        
        protected function checkIntegrity(persistentSource:SQLPersistentSource):void 
        {
            // TODO: Make sure no bogus/stale tasks are in source	
        }
        
        public function getNextTask():Task
        {
            var task:Task = null;
            for each ( var candidate:Task in taskArray )
            {	
                if (candidate != null && candidate.isRunnableState() && !candidate.isAssociated())
                {
                    task = candidate;
                    break;
                }
            }
            return task;
        }
        
        public function addTask(task:Task):void 
        {
            addInternalTask(task);
            getPersistentSource().addTask(task);
        }
        
        public function addTasks(tasks:Array):void 
        {
            for each (var task:Task in tasks)
            addInternalTask(task);
            getPersistentSource().addTasks(tasks);
        }
        
        private function addInternalTask(task:Task):void
        {
            var key:String = task.getId();
            var app:String = task.getApplicationId();
            
            if (key == null && app != null)
            {
                throw new Error("Task and Application Id cannot be null");
            }
            else if ( applicationTable[app] != null &&  applicationTable[app][task.getId()] != null)
            {
                throw new Error("Task Id: " + task.getId() + " already exists");
            }
            
            taskTable = applicationTable[app];
            
            if (taskTable == null) taskTable = new Dictionary();
            
            taskTable[task.getId()] = task;
            applicationTable[app] =  taskTable;
            taskArray.push(task);
        }
        
        private function removeInternal(task:Task):void
        {
            if (task != null)
            {
                delete applicationTable[task.getApplicationId()][task.getId()];
                var index:int = taskArray.indexOf(task); 
                if (index != -1) taskArray.splice(index, 1);
                getPersistentSource().removeTask(task);
            }
        }
        public function removeTask(task:Task):void
        {
            removeInternal(task);
        }
        
        public function removeAllTasks(appId:String="DEFAULT_APPLICATION_ID"):void
        {
            taskTable = applicationTable[appId];
            
            for each ( var task:Task in taskTable)
            {
                var index:int = taskArray.indexOf(task); 
                if (index != -1) taskArray.splice(index, 1);
            }
            
            taskTable = new Dictionary();
            applicationTable[appId] = taskTable;
            
            getPersistentSource().removeAllTasks(appId);
        }
        
        public function saveTask(task:Task):void
        {
            applicationTable[task.getApplicationId()][task.getId()] = task;
            var index:int = taskArray.indexOf(task); 
            if (index != -1) taskArray[index] = task;
            getPersistentSource().saveTask(task);
        }
        
        public function getAllTasks(filter:int=-1, appId:String="DEFAULT_APPLICATION_ID"):Array
        {
            //TODO: Order might be messed up since 
            // Dictionary doesn't maintain it.. 
            /// maybe filter taskArray by appId
            
            var tasks:Array = new Array();
            
            for each ( var task:Task in taskArray)
            {
                if (task != null && task.getStatus() != filter && task.getApplicationId() == appId)
                    tasks.push(task);
            }
            return tasks;
        }
        
        public function getTaskById(id:String, appId:String="DEFAULT_APPLICATION_ID"):Task
        {
            if (applicationTable[appId] == null) return null;
            return applicationTable[appId][id];
        }
        
        public function containsTask(id:String, appId:String="DEFAULT_APPLICATION_ID"):Boolean
        {
            if (applicationTable[appId] == null) return false;
            return applicationTable[appId][id] != null;
        }
        
        public function size(appId:String=""):int
        {
            return getPersistentSource().size(appId);
        }
        
        public function close():void
        {
            applicationTable = new Dictionary();
            taskTable = new Dictionary();
            taskArray = new Array();
            getPersistentSource().close();
        }
        
        public function resumeTask(task:Task):void 
        {
            for ( var i:int=0; i<taskArray.length; i++) {
                if (taskArray[i].getId() == task.getId() && taskArray[i].getApplicationId() == task.getApplicationId()) {
                    // Move the item to the end of the queue
                    var temp:Object = taskArray[i];
                    taskArray.splice(i, 1);
                    taskArray.push(temp);
                    break;
                }
            }
        }
    }
}