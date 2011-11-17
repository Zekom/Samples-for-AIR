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
    import flash.data.SQLConnection;
    import flash.filesystem.File;
    
    import samples.download.taskmanager.Task;
    import samples.download.taskmanager.events.DownloadEvent;
    import samples.download.taskmanager.wakeup.DefaultWakeupPolicy;
    import samples.download.taskmanager.wakeup.WakeupPolicy;
    
    /**
     * <p/>Manages a list of http downloads. Items in the queue can be paused, resumed or removed.<p/>By default the queue and task status are persisted
     * by using a default "downloads.db" SQL database, which can be overriden (getDBConnection) to provide a different SQLConnection. <p/> getWakeupPolicy()
     * uses DefaultWakeupPolicy to react to low disk space, low battery and no wifi events. Additionnal WakeupTriggerBase can be added to a custom 
     * WakeupPolicy to add additionnal resource contraints.
     * */
    public class DownloadManagerFacade
    {
        protected static const SLASH:String = "/";
        public static var DEBUG:Boolean = false;
        protected var _mgr:DownloadManager;
        private var _defaultDB:String = File.applicationStorageDirectory.nativePath + SLASH + "downloads.db";
        private var _wakeupPolicy:DefaultWakeupPolicy;
        
        public function DownloadManagerFacade()
        {
            _mgr = DownloadManager.getInstance(this);
        }
        
        /**
         * SQL connection being used to persist items
         * */
        public function getDBConnection():SQLConnection
        {
            var conn:SQLConnection = new SQLConnection();
            conn.open(new File(_defaultDB));
            return conn;
        }
        
        public function getWakeupPolicy():WakeupPolicy 
        {
            if(_wakeupPolicy == null) 
            {
                _wakeupPolicy = new DefaultWakeupPolicy();
            }
            return _wakeupPolicy;
        }
        
        public function getApplicationID():String 
        {
            return "DEFAULT_APPLICATION_ID";
        }
        
        /**
         * Adds a download
         * */
        public function addTask(task:Task):void
        {
            _mgr.addTask(task);
        }
        
        public function getAllTasks(filter:int=-1, appId:String="DEFAULT_APPLICATION_ID"):Array 
        {
            return _mgr.getAllTasks(filter, appId);
        }
        
        public function pauseTask(task:Task):void
        {
            _mgr.pauseTask(task);
        }
        
        public function resumeTask(task:Task):void
        {
            _mgr.resumeTask(task);
        }
        
        public function removeAllTasks(cleanup:Boolean=false):void 
        {
            _mgr.removeAllTasks(cleanup);
        }
        
        public function restartTask(task:Task):void 
        {
            _mgr.restartTask(task);
        }
        
        public function removeTask(task:Task, cleanup:Boolean=false):void 
        {
            if (cleanup){
                _mgr.removeTask(task, cleanup);
            }else{
                _mgr.cancelTask(task);
            }
        }
        
        /**
         * Completely stops the download manager.
         * */
        public function stop():void 
        {
            _mgr.stop();
        }
        
        public function setHTTPUserAgentHeader(userAgent:String):void
        {
            _mgr.userAgent = userAgent;
        }
    }
}