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
package samples.download
{
    import flash.errors.IllegalOperationError;
    
    import samples.download.taskmanager.*;
    import samples.download.taskmanager.ds.SQLTaskDataSource;
    import samples.download.taskmanager.listeners.*;
    import samples.download.taskmanager.wakeup.WakeupPolicy;
    
    internal class DownloadManager
    {
        private static var _instance:DownloadManager
        
        private var _wakeup:WakeupPolicy;
        private var _source:SQLTaskDataSource;
        private var _queue:TaskQueue;
        
        private var _taskCount:int;		
        private var _facade:DownloadManagerFacade;
        
        /**
         * Constructor
         * @param enforcer used to enfore the singleton
         * @throws IllegalOperationError if instanciated - use getInstance() instead
         */ 
        public function DownloadManager(enforcer:SingletonEnforcer, dataProvider:DownloadManagerFacade)
        {
            if(!enforcer)
            {
                throw new IllegalOperationError("SessionManager is a singleton, use getInstance()");
            }
            
            _facade = dataProvider;
            
            init();
        }
        
        public static function getInstance(dataProvider:DownloadManagerFacade):DownloadManager
        {
            if(!_instance)
            {
                _instance = new DownloadManager(new SingletonEnforcer(), dataProvider);
            }
            
            return _instance;
        }
        
        /**
         * initialize the download manager
         */
        private function init():void
        {
            _source = new SQLTaskDataSource(_facade.getDBConnection());			
            _queue = TaskQueue.getInstance();
            _taskCount = _queue.getTaskCount();
            
            _wakeup = _facade.getWakeupPolicy();
            
            Registry.getInstance().setWakeupPolicy(_wakeup, _queue);
            Registry.getInstance().setTaskDataSource(_source);
            
            //start Download Manager
            _queue.start();
        }					
        
        /**
         * Stops all download tasks
         * */
        public function stop():void 
        {
            _queue.shutdown();
        }
        
        /**
         * get the download task by its id
         * @param id The id of download task
         * @return the download task
         */
        public function getTaskById(id:String, appId:String="DEFAULT_APPLICATION_ID"):Task
        {
            var source:SQLTaskDataSource = Registry.getInstance().getTaskDataSource() as SQLTaskDataSource;
            if (source != null) return source.getTaskById(id, appId);			
            return null;
        }
        
        /**
         * get all the tasks in the download manager
         * @param id The id of download task
         * @return the download task
         */
        public function getAllTasks(filter:int=-1, appId:String="DEFAULT_APPLICATION_ID"):Array
        {
            var source:SQLTaskDataSource = Registry.getInstance().getTaskDataSource() as SQLTaskDataSource;
            if (source != null) return source.getAllTasks(filter, appId);
            return null;
        }
        
        /** 
         * adds a download
         * @param category          The category which the content belongs to
         * @param content           The content to download
         */
        public function addTask(task:Task):void
        {
            _queue.addTask(task);
        }
        
        public function addTasks(tasks:Array):void
        {
            _queue.addTasks(tasks);
        }
        
        public function restartTask(task:Task):void
        {
            _queue.restartTask(task);
        }
        
        public function cancelTask(task:Task):void
        {
            _queue.cancelTask(task);
        }
        
        public function removeTask(task:Task, cleanup:Boolean=false):void
        {
            _queue.removeTask(task, cleanup);
        }
        
        public function getTaskCount():int 
        {
            return _queue.getTaskCount();
        }
        
        public function removeAllTasks(cleanup:Boolean):void 
        {
            _queue.removeAllTasks(cleanup);
        }
        
        /**
         * add a listener for task progress call back
         * @param listener the listener for task progress call back to add
         */ 
        public function addTaskProgressListener(listener:TaskProgressListener):void
        {
            Registry.getInstance().addTaskProgressListener(listener);
        }
        
        /**
         * remove a listener for task progress call back
         * @param listener the listener for task progress call back to remove
         */ 
        public function removeTaskProgressListener(listener:TaskProgressListener):void
        {
            Registry.getInstance().removeTaskProgressListener(listener);
        }
        
        /**
         * add a listener for task progress call back
         * @param listener the listener for task progress call back to add
         */ 
        public function addTaskRunnerRetryListener(listener:TaskRetryListener):void
        {
            Registry.getInstance().addTaskRunnerRetryListener(listener);
        }
        
        /**
         * remove a listener for task progress call back
         * @param listener the listener for task progress call back to remove
         */ 
        public function removeTaskRunnerRetryListener(listener:TaskRetryListener):void
        {
            Registry.getInstance().removeTaskRunnerRetryListener(listener);
        }
        
        /**
         * add a listener for task queue size change call back
         * @param listener the listener for task queue size change call back to add
         */ 
        public function addTaskQueueSizeListener(listener:TaskQueueSizeListener):void
        {
            Registry.getInstance().addTaskQueueSizeListener(listener);
        }
        
        /**
         * remove a listener for task queue size change call back
         * @param listener the listener for task queue size change call back to remove
         */ 
        public function removeTaskQueueSizeListener(listener:TaskQueueSizeListener):void
        {
            Registry.getInstance().removeTaskQueueSizeListener(listener);
        }		
        
        /**
         * add a listener for task queue status change call back
         * @param listener the listener for task queue status change to add
         */ 
        public function addTaskQueueStatusListener(listener:TaskQueueStatusListener):void
        {
            Registry.getInstance().addTaskQueueStatusListener(listener);
        }
        
        /**
         * remove a listener for task queue status change call back
         * @param listener the listener for task queue status change to remove
         */ 
        public function removeTaskQueueStatusListener(listener:TaskQueueStatusListener):void
        {
            Registry.getInstance().removeTaskQueueStatusListener(listener);
            
        }
        
        /**
         * pause a task in progress
         * @param task to pause
         */ 
        public function pauseTask(task:Task):void
        {
            _queue.pauseTask(task);
        }
        
        /**
         * resume the download of a paused task
         * @param task to resume
         */ 
        public function resumeTask(task:Task):void
        {
            _queue.resumeTask(task);
        }
        
        public function get userAgent():String 
        {
            return _queue ? _queue.userAgent : null;
        }
        
        public function set userAgent(userAgent:String):void
        {			
            //set the user agent and it will apply it for the next task to be downloaded by calling _queue.processQueue()
            if (_queue) 
            {
                _queue.userAgent = userAgent;
            }
        }
    }	
}

internal class SingletonEnforcer {}