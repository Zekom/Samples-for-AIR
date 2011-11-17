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
package samples.download.taskmanager
{
    import flash.events.EventDispatcher;
    
    import samples.download.taskmanager.ds.SQLTaskDataSource;
    import samples.download.taskmanager.events.*;
    import samples.download.taskmanager.listeners.*;
    import samples.download.taskmanager.wakeup.DefaultWakeupPolicy;
    import samples.download.taskmanager.wakeup.WakeupPolicy;
    
    public class Registry extends EventDispatcher
    {
        
        private static const _instance:Registry = new Registry(SingletonLock);
        
        public static function getInstance():Registry
        {			
            return _instance;
        }	
        
        public function Registry(lock:Class)
        {
            // Verify that the lock is the correct class reference.
            if ( lock != SingletonLock )
            {
                throw new Error( "Invalid Singleton access.  Use Registry.getInstance" );
            }
            
            // Initialization
        }
        
        private var taskDataSource:SQLTaskDataSource = null;	
        private var taskRunnerFactory:DefaultTaskRunnerFactory = null;
        private var wakeupPolicy:WakeupPolicy = null;
        private var exceptionSerializer:IErrorSerializer = null;
        
        public function getTaskRunnerFactory():DefaultTaskRunnerFactory
        {
            if (taskRunnerFactory == null) taskRunnerFactory = new DefaultTaskRunnerFactory();
            return taskRunnerFactory;
        }
        
        public function setTaskRunnerFactory(taskRunnerFactory:DefaultTaskRunnerFactory):void
        {
            this.taskRunnerFactory = taskRunnerFactory;
        }
        
        public function getTaskDataSource():SQLTaskDataSource
        {
            return taskDataSource;
        }
        
        public function setTaskDataSource(taskDataSource:SQLTaskDataSource):void
        {
            if (this.taskDataSource != null)
            {
                this.taskDataSource.close();
            }
            this.taskDataSource = taskDataSource;
        }
        
        public function getErrorSerializer():IErrorSerializer
        {
            return exceptionSerializer;
        }
        
        public function setErrorSerializer(exceptionSerializer:IErrorSerializer):void
        {
            this.exceptionSerializer = exceptionSerializer;
        }
        
        public function getWakeupPolicy(queue:TaskQueue):WakeupPolicy
        {
            if (wakeupPolicy == null)
            {
                wakeupPolicy = new DefaultWakeupPolicy();
                wakeupPolicy.register(queue);
            }
            return wakeupPolicy;
        }
        
        public function setWakeupPolicy(wakeupPolicy:WakeupPolicy, queue:TaskQueue):void
        {
            if (this.wakeupPolicy != null)
            {
                this.wakeupPolicy.unRegister();
                this.wakeupPolicy = null;
            }
            
            this.wakeupPolicy = wakeupPolicy;
            
            if (this.wakeupPolicy != null)
                this.wakeupPolicy.register(queue);
        }
        
        public function addTaskProgressListener(listener:TaskProgressListener):void
        {
            addEventListener(TaskProgressEvent.TASK_PROGRESS_CHANGED, listener.taskProgressChanged);
        }
        
        public function removeTaskProgressListener(listener:TaskProgressListener):void
        {
            removeEventListener(TaskProgressEvent.TASK_PROGRESS_CHANGED,listener.taskProgressChanged);
        }
        
        public function addTaskRunnerRetryListener(listener:TaskRetryListener):void
        {
            addEventListener(TaskRunnerEvent.TASK_RUNNER_RETRY,listener.taskRunnerRetry, false, 0, true);
        }
        
        public function removeTaskRunnerRetryListener(listener:TaskRetryListener):void
        {
            removeEventListener(TaskRunnerEvent.TASK_RUNNER_RETRY,listener.taskRunnerRetry);
        }
        
        public function addTaskChangeListener(listener:TaskChangeListener):void
        {
            addEventListener(TaskChangeEvent.TASK_STATUS_CHANGED,listener.taskStatusChanged, false, 0, true);
        }
        
        public function removeTaskChangeListener(listener:TaskChangeListener):void
        {
            removeEventListener(TaskChangeEvent.TASK_STATUS_CHANGED,listener.taskStatusChanged);
        }
        
        public function addTaskQueueSizeListener(listener:TaskQueueSizeListener):void
        {
            addEventListener(TaskQueueSizeEvent.TASK_QUEUE_SIZE_CHANGED,listener.queueSizeChanged, false, 0, true);
        }
        
        public function removeTaskQueueSizeListener(listener:TaskQueueSizeListener):void
        {
            removeEventListener(TaskQueueSizeEvent.TASK_QUEUE_SIZE_CHANGED,listener.queueSizeChanged);
        }
        
        public function addTaskQueueStatusListener(listener:TaskQueueStatusListener):void
        {
            addEventListener(TaskQueueStatusEvent.TASK_QUEUE_STATUS_CHANGED,listener.queueStatusChanged, false, 0, true);
        }
        
        public function removeTaskQueueStatusListener(listener:TaskQueueStatusListener):void
        {
            removeEventListener(TaskQueueStatusEvent.TASK_QUEUE_STATUS_CHANGED,listener.queueStatusChanged);
        }
        
        public function clearListeners():void
        {
            // Do we need to keep track of listeners and remove them 
            // manually ?
            // TODO: Override addEventListeners function, in it add to local array of listeners
            // then manually remove all.
        }
        
        public function notifyTaskQueueStatusChanged(status:int, cause:int):void
        {
            dispatchEvent(new TaskQueueStatusEvent(TaskQueueStatusEvent.TASK_QUEUE_STATUS_CHANGED, status, cause ));	
        }
        
        public function notifyTaskQueueSizeChanged(size:int):void
        {
            dispatchEvent(new TaskQueueSizeEvent(TaskQueueSizeEvent.TASK_QUEUE_SIZE_CHANGED, size));	
        }
        
        public function notifyTaskProgressChanged(task:Task):void
        {
            dispatchEvent(new TaskProgressEvent(TaskProgressEvent.TASK_PROGRESS_CHANGED, task, task.getProgressHandle()));	
        }
        
        public function notifyTaskStatusChanged(task:Task, status:int):void 
        {
            dispatchEvent(new TaskChangeEvent(TaskChangeEvent.TASK_STATUS_CHANGED, task, status));	
        }
        
        public function notifyTaskRunnerRetry(task:Task, exception:Error, numOfFailures:int):void
        {
            dispatchEvent(new TaskRunnerEvent(TaskRunnerEvent.TASK_RUNNER_RETRY, task, exception, numOfFailures));	
        }
        
    }
}

/**
 * This is a private class declared outside of the package
 * that is only accessible to classes inside of the Registry.as
 * file.  Because of that, no outside code is able to get a
 * reference to this class to pass to the constructor, which
 * enables us to prevent outside instantiation.
 */
class SingletonLock
{
} // end class