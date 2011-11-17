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
    import samples.download.DownloadManagerFacade;
    import samples.download.taskmanager.ds.SQLTaskDataSource;
    import samples.download.taskmanager.events.TaskChangeEvent;
    import samples.download.taskmanager.listeners.TaskRunnerListener;
    import samples.download.taskmanager.wakeup.WakeupPolicy;
    import samples.download.taskmanager.http.HttpFileDownload;
    
    public class TaskQueue extends GlobalConstants implements TaskRunnerListener
    {	
        private static const _instance:TaskQueue = new TaskQueue(SingletonLock);
        
        // States of Queue
        public static const IDLE:int 		= 0; // Active but has no tasks to process
        public static const BUSY:int  		= 1; // Actively processing tasks
        public static const SLEEPING:int  	= 2; // Suspended by an unsatisfied condition or by a fatal task error
        public static const SUSPENDED:int  	= 3; // Suspended by Application
        public static const TERMINATED:int  = 4; // TERMINATED
        
        private static const DEFAULT_MAX_CONCURRENT_TASKS:int	= 1;
        
        private var status:int = TERMINATED;
        
        private var taskRunners:Object;
        
        private var maxConcurrentTasks:int;
        
        private var _userAgent:String; //for Http user anger header
        
        public static function getInstance():TaskQueue
        {			
            return _instance;
        }
        
        public function TaskQueue(lock:Class)
        {
            // Verify that the lock is the correct class reference.
            if ( lock != SingletonLock )
            {
                throw new Error( "Invalid Singleton access.  Use Registry.getInstance" );
            }
            
            // Initialization
            _userAgent = HttpFileDownload.USER_AGENT;//by default using "BlackBerry9800/5.0.0 profile/MIDP-2.1 Configuration/CLDC-1.1 VendorID/1"
            maxConcurrentTasks = DEFAULT_MAX_CONCURRENT_TASKS;
            taskRunners = new Object();
            Registry.getInstance().clearListeners();	
        }
        
        public function start():void
        {
            switch (status)
            {
                case IDLE:
                case BUSY:
                case SLEEPING:
                case SUSPENDED:
                    break;
                case TERMINATED:
                    setStatus(IDLE);
                    var wp:WakeupPolicy = getWakeupPolicy();
                    if (wp != null)
                    {
                        wp.setWakeupPolicyEnabled(true);
                    }
                    break;
            }
        }
        
        public function shutdown():void
        {
            switch (status)
            {
                case IDLE:
                case BUSY:
                case SLEEPING:
                case SUSPENDED:
                    setStatus(TERMINATED);
                    var wp:WakeupPolicy = getWakeupPolicy();
                    if (wp != null)
                    {
                        wp.setWakeupPolicyEnabled(false);
                    }
                    stopAllTasks();
                    break;
                case TERMINATED:
                    break;
            }
        }
        
        public function wakeup(resumeIfSleep:Boolean):void
        {
            switch (status)
            {
                case IDLE:
                case BUSY:
                    processQueue();
                    break;
                case SLEEPING:
                    if (resumeIfSleep)
                    {
                        setStatus(BUSY);
                        processQueue();
                    }
                    break;
                case SUSPENDED:
                case TERMINATED:
                    break;
            }
        }
        
        public function sleep(cause:int):void
        {
            switch (status)
            {
                case IDLE:
                case BUSY:
                    setStatusAndCause(SLEEPING, cause);
                    stopAllTasks();
                    break;	
                case SLEEPING:
                case SUSPENDED:
                case TERMINATED:
                    break;
            }
        }
        
        public function suspend(cause:int):void
        {	
            switch (status)
            {
                case IDLE:
                case BUSY:
                case SLEEPING:
                    setStatusAndCause(SUSPENDED, cause);
                    stopAllTasks();
                    break;
                case SUSPENDED:
                case TERMINATED:
                    break;
            }
        }
        
        public function resume():void
        {
            switch (status)
            {
                case IDLE:
                case BUSY:
                case SLEEPING:
                    break;
                case SUSPENDED:
                    setStatus(BUSY);
                    getWakeupPolicy().checkConditions();
                    break;
                case TERMINATED:
                    break;
            }
        }
        
        public function invalidateConditions():void
        {
            switch (status)
            {
                case IDLE:
                    setStatus(BUSY);
                case BUSY:
                    processQueue();
                    break;
                case SLEEPING:
                case SUSPENDED:
                    getWakeupPolicy().checkConditions();
                    break;
                case TERMINATED:
                    // nothing
                    break;
            }
        }
        
        public function isStarted():Boolean
        {
            switch (status)
            {
                case IDLE:
                case BUSY:
                case SLEEPING:
                case SUSPENDED:
                    return true;
                case TERMINATED:
                    return false;
                default: return false;			
            }
        }
        
        
        public function isAsleep():Boolean
        {
            switch (status)
            {
                case SLEEPING:
                case SUSPENDED:
                    return true;
                case IDLE:
                case BUSY:
                case TERMINATED:
                    return false;
                default: return false;			
            }
        }
        
        public function isInRunnableState():Boolean
        {
            switch (status)
            {
                case IDLE:
                case BUSY:
                    return true;
                case SLEEPING:
                case SUSPENDED:
                case TERMINATED:
                    return false;
                default: return false;			
            }
        }
        
        private function sizeOf(obj:Object):int
        {
            var size:int = 0;
            for (var prop:String in obj) {
                size++;
            }
            return size;
        }
        
        private function stopTask(task:Task, cleanup:Boolean):Boolean
        {
            var interrupted:Boolean = false;
            var runner:TaskRunner = taskRunners[task.getId()];
            if (runner != null) 
            {
                interrupted = runner.interrupt(cleanup);
                if (interrupted) 
                {
                    if(taskRunners[task.getId()]) 
                    {
                        taskRunners[task.getId()].removeTaskRunnerListener(this);
                        delete taskRunners[task.getId()];						
                    }
                }
            }
            return interrupted;
        }
        
        private function isPausableTask(task:Task):Boolean
        {
            var isPausableTask:Boolean = true;
            var runner:TaskRunner = taskRunners[task.getId()];
            if (runner != null)
            {
                isPausableTask = runner.isPausable();
            }
            return isPausableTask;
        }
        
        private function stopAllTasks():void
        {
            for (var taskID:String in taskRunners) {
                TaskRunner(taskRunners[taskID]).interrupt(false);
                delete taskRunners[taskID];
            }
        }
        
        public function setStatusAndCause(status:int, cause:int):void
        {
            if (this.status == status && cause == OK) return;
            this.status = status;
            
            Registry.getInstance().notifyTaskQueueStatusChanged(status, cause);
        }
        
        public function setStatus(status:int):void
        {
            setStatusAndCause(status, OK);
        }
        
        public function getStatus():int
        {
            return status;
        }
        
        public function addTask(task:Task):void
        {
            var source:SQLTaskDataSource = Registry.getInstance().getTaskDataSource();
            if (source != null)
            {
                source.addTask(task);
                task.setQueued();
                Registry.getInstance().notifyTaskQueueSizeChanged(getTaskCount(task.getApplicationId()));	
            }
            
            invalidateConditions();
        }
        
        public function addTasks(tasks:Array):void 
        {
            var source:SQLTaskDataSource = Registry.getInstance().getTaskDataSource();
            if (source && tasks && tasks.length > 0)
            {
                source.addTasks(tasks);
                //Registry.getInstance().notifyTaskQueueSizeChanged(getTaskCount((tasks[0] as Task).getApplicationId()));	
            }
        }
        
        public function removeTask(task:Task, cleanup:Boolean):void
        {	
            removeTaskInternal(task,cleanup);
            Registry.getInstance().notifyTaskQueueSizeChanged(getTaskCount(task.getApplicationId()));
        }
        
        private function removeTaskInternal(task:Task, cleanup:Boolean):void
        {
            // stop first
            task.setCancel(); // cancel if it's in a cancellable state.
            var cleanupRequired:Boolean = !stopTask(task, cleanup);
            if (cleanup && cleanupRequired) task.cleanup();
            
            // then remove
            var source:SQLTaskDataSource = Registry.getInstance().getTaskDataSource();
            if (source != null) source.removeTask(task);
        }
        
        public function removeTasks(tasks:Array, cleanup:Boolean):void
        {
            for each (var task:Task in tasks) {
                removeTaskInternal(task, cleanup);
            }
            Registry.getInstance().notifyTaskQueueSizeChanged(getTaskCount(task.getApplicationId()));
        }	
        
        public function removeAllTasks(cleanup:Boolean, appId:String="DEFAULT_APPLICATION_ID"):void
        {
            var tasks:Array = getAllTasks(-1, appId);
            
            var source:SQLTaskDataSource = Registry.getInstance().getTaskDataSource();
            if (source != null) source.removeAllTasks(appId);
            
            for each (var task:Task in tasks) {
                task.setCancel(); // cancel if it's in a cancellable state.
                var cleanupRequired:Boolean = !stopTask(task, cleanup);
                if (cleanup && cleanupRequired) task.cleanup();    
            }
            
            Registry.getInstance().notifyTaskQueueSizeChanged(getTaskCount(appId));
        }
        
        public function cancelTask(task:Task):void
        {
            if (task.setCancel())
            {
                // if interrupt succeeds, no need to cleanup manually
                var cleanupRequired:Boolean = !stopTask(task, true);
                if (cleanupRequired) task.cleanup();
                processQueue();
            }
            else
            {
                throw TaskQueueError("Unable to cancel task: task is not in initialized, pending, paused or in progress status");
            }
        }
        
        public function pauseTask(task:Task):void
        {
            if(!isPausableTask(task))
            {
                throw TaskQueueError("Unable to pause this task: this is not a pausable task!");
                return;
            }
            
            if (task.setPause())
            {
                stopTask(task, false);
                processQueue();
            }
            else
            {
                throw TaskQueueError("Unable to pause task: task is not in initialized, pending or in progress status");
            }
        }
        
        public function restartTask(task:Task):void
        {
            if (task.setRestart())
            {
                // if interrupt succeeds, no need to cleanup manually
                var cleanupRequired:Boolean = !stopTask(task, true);
                if (cleanupRequired) task.cleanup();
                invalidateConditions();
            }
            else
            {
                throw TaskQueueError("Unable to restart task");
            }
        }
        
        public function markTaskAs(task:Task, status:int, fireEvent:Boolean):void
        {      
            task.setStatusAndCommit(status, true, fireEvent);        
        }
        
        public function resumeTask(task:Task):void
        {
            if (task.setResume())
            {
                // We move a task to the end of the queue when resuming a task
                var source:SQLTaskDataSource = Registry.getInstance().getTaskDataSource();
                if (source != null) source.resumeTask(task);
                invalidateConditions();
            }
            else
            {
                throw TaskQueueError("Unable to resume task: task is not in resumable status");
            }
        }
        
        public function getAllTasks(filter:int=-1, appId:String="DEFAULT_APPLICATION_ID"):Array
        {
            var source:SQLTaskDataSource = Registry.getInstance().getTaskDataSource();
            if (source != null) return source.getAllTasks(filter, appId);
            
            return new Array();
        }
        
        public function getTaskById(id:String, appId:String="DEFAULT_APPLICATION_ID"):Task
        {
            var source:SQLTaskDataSource = Registry.getInstance().getTaskDataSource();
            if (source != null) return source.getTaskById(id, appId);
            
            return null;
        }
        
        public function getNextTask():Task
        {
            var source:SQLTaskDataSource = Registry.getInstance().getTaskDataSource();
            if (source != null) return source.getNextTask();
            
            return null;
        }
        
        public function containsTask(id:String, appId:String="DEFAULT_APPLICATION_ID"):Boolean
        {
            var source:SQLTaskDataSource = Registry.getInstance().getTaskDataSource();
            if (source != null) return source.containsTask(id, appId);
            return false;
        }
        
        public function getTaskCount(appId:String="DEFAULT_APPLICATION_ID"):int
        {	
            var source:SQLTaskDataSource = Registry.getInstance().getTaskDataSource();
            if (source != null) return source.size(appId);
            
            return 0;
        }
        
        private function getWakeupPolicy():WakeupPolicy
        {
            return Registry.getInstance().getWakeupPolicy(this);
        }
        
        public function taskRunnerComplete(event:TaskChangeEvent):void
        {
            if (taskRunners[event.task.getId()] == null) return;
            if (DownloadManagerFacade.DEBUG)
                trace("TaskQueue: Task Runner completed Task");
            if(taskRunners[event.task.getId()]) 
            {
                taskRunners[event.task.getId()].removeTaskRunnerListener(this);
                delete taskRunners[event.task.getId()];				
            }
            wakeup(false);
        }
        
        private function processQueue():void
        {
            
            if (getStatus() == TERMINATED) return;
            
            
            var runTask:Boolean = false;
            var task:Task = null;
            
            runTask = (getStatus() == BUSY) || (getStatus() == IDLE);
            
            if (!runTask)
            {
                trace("TaskQueue: Run Task Failed: status:" + getStatus());
            }
            else
            {
                task = getNextTask();
                runTask = runTask && (task != null);
                
                if (!runTask)
                {
                    if (DownloadManagerFacade.DEBUG)
                        trace("TaskQueue: No Task to run");
                }
                else
                {
                    runTask = runTask && (sizeOf(taskRunners)< maxConcurrentTasks);
                    if (!runTask)
                    {
                        if (DownloadManagerFacade.DEBUG)
                            trace("TaskQueue: Run Task Failed: Task Runner Size: " + sizeOf(taskRunners));
                    }
                }
            }
            
            
            if (runTask)
            {
                if (DownloadManagerFacade.DEBUG)
                    trace("TaskQueue:  Processing task: " + task.getId());
                var taskRunner:TaskRunner = Registry.getInstance().getTaskRunnerFactory().getTaskRunner(task,_userAgent);
                taskRunner.setWakeupPolicy(getWakeupPolicy());
                taskRunner.addTaskRunnerListener(this);
                taskRunners[task.getId()] = taskRunner;
                taskRunner.run();	
            }
            else
            {
                if (status == BUSY)
                {
                    if (sizeOf(taskRunners) == 0)
                    {
                        setStatus(IDLE);
                    }
                }
            }
            
        }
        
        public function get userAgent():String 
        {
            return _userAgent;
        }
        
        public function set userAgent(userAgent:String):void
        {
            _userAgent = userAgent;
        }
    }
}

/**
 * This is a private class declared outside of the package
 * that is only accessible to classes inside of the TaskQueue.as
 * file.  Because of that, no outside code is able to get a
 * reference to this class to pass to the constructor, which
 * enables us to prevent outside instantiation.
 */
class SingletonLock
{
} // end class