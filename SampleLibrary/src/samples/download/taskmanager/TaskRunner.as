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
    import flash.errors.IllegalOperationError;
    import flash.events.EventDispatcher;
    import flash.events.HTTPStatusEvent;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    
    import samples.download.DownloadManagerFacade;
    import samples.download.taskmanager.events.DownloadEvent;
    import samples.download.taskmanager.events.TaskChangeEvent;
    import samples.download.taskmanager.listeners.TaskRunnerListener;
    import samples.download.taskmanager.wakeup.WakeupPolicy;
    
    public class TaskRunner extends EventDispatcher
    {	
        public static const DEFAULT_NUM_OF_RETRIES:int = 12;
        public static const DEFAULT_RETRY_INTERVAL_IN_MILLIS:int = 1000; // 10 secs
        
        private var task:Task;
        
        private var wakeupPolicy:WakeupPolicy;
        
        private var numOfRetries:int = DEFAULT_NUM_OF_RETRIES;
        
        private var retryInterval:int = DEFAULT_RETRY_INTERVAL_IN_MILLIS;
        
        private var numOfFailures:int = 0;
        
        private var cleanup:Boolean = false;
        
        private var stop:Boolean = false;
        
        private var running:Boolean = false;
        
        private var handlingException:Boolean = false;  
        
        private var timer:Timer;
        
        public function TaskRunner(task:Task)
        {
            this.task = task;
        }
        
        public function getTask():Task
        {
            return task;
        }
        
        public function setTask(task:Task):void
        {
            this.task = task;
        }
        
        
        public function removeTaskRunnerListener(listener:TaskRunnerListener):void
        {
            removeEventListener(TaskChangeEvent.TASK_COMPLETE, listener.taskRunnerComplete);
        }
        
        public function addTaskRunnerListener(listener:TaskRunnerListener):void
        {
            addEventListener(TaskChangeEvent.TASK_COMPLETE, listener.taskRunnerComplete, false, 0, true);
        }
        
        public function getWakeupPolicy():WakeupPolicy
        {
            return wakeupPolicy;
        }
        
        public function setWakeupPolicy(wakeupPolicy:WakeupPolicy):void
        {
            this.wakeupPolicy = wakeupPolicy;
        }
        
        public function dispose():void
        {
            this.task = null;
            this.wakeupPolicy = null;
        }
        
        public function getNumOfRetries():int 
        {
            return numOfRetries;
        }
        
        public function setNumOfRetries(numOfRetries:int):void 
        {
            this.numOfRetries = numOfRetries;
        }
        
        public function getRetryInterval():int
        {
            return retryInterval;
        }
        
        public function setRetryInterval(retryInterval:int):void
        {
            this.retryInterval = retryInterval;
        }
        
        protected function setCleanupFlag(cleanup:Boolean):void
        {
            this.cleanup = cleanup;
        }
        
        protected function isCleanupFlagSet():Boolean
        {
            return cleanup;
        }
        
        protected function setStopFlag(stop:Boolean):void
        {
            this.stop = stop;
        }
        
        protected function isStopFlagSet():Boolean
        {
            return stop;
        }
        
        protected function handleError(e:Error, httpEvent:HTTPStatusEvent = null):void
        {
            ++numOfFailures;
            
            var task:Task = getTask();        
            if (task == null) return;
            
            var wp:WakeupPolicy = this.getWakeupPolicy();
            
            if (e is TaskError && (TaskError(e)).isFatal())
            {   
                trace("Task Runner: Fatal Error while running task: " + task.getId() + " , " + e.message);
                this.setStopFlag(true);
                if (wp != null)
                {
                    wp.handleException(e);
                }                         
            }
            else if (e is TaskError && (TaskError(e)).isFailTask())
            {
                failTask(task, e, httpEvent);
            }
            else if (e is TaskError && (TaskError(e)).isPauseTask())
            {
                task.setStatus(Task.STATUS_PAUSED);
            }
            else
            {       
                if (numOfFailures > getNumOfRetries())
                {
                    failTask(task, e);
                    
                    trace("Task Runner: Number of Failures: [" + numOfFailures + "] exceeded max retries: [" + getNumOfRetries() + "]");
                }
                else
                {
                    trace("Task Runner: Number of Failures: [" + numOfFailures + "], max retries: [" + getNumOfRetries() + "]");
                    if (wp != null)
                    {
                        wp.handleException(e);
                    }
                    
                    Registry.getInstance().notifyTaskRunnerRetry(task, e, numOfFailures);
                    preRetry(numOfFailures, e);
                }
            }
        }
        
        protected function failTask(task:Task, e:Error, httpEvent:HTTPStatusEvent=null):void
        {
            task.setError(e, httpEvent);
            task.setStatusAndCommit(Task.STATUS_FAILED, false, true);
            task.commitToDataSource();
            trace("Task Runner: Task Failed: " + task.getId());
        }
        
        /**
         * use this if you want to make any changes before retry
         * @param numberOfFailures
         * @param e
         */
        protected function preRetry(numberOfFailures:int, e:Error):void
        {
            // do nothing now.
        }
        
        public function interrupt(cleanup:Boolean):Boolean
        {
            var interrupted:Boolean = false;
            if (running || handlingException)
            {
                setStopFlag(true);
                setCleanupFlag(cleanup);
                interrupted = true;
            }
            
            // Always clear task from runner MKS 1398023
            task.setAssociated(false);
            
            if (interrupted)
            {
                trace("Task Runner: Interrupted task: " + getTask().getId());
                var downloadEvent:DownloadEvent = new DownloadEvent(DownloadEvent.DOWNLOAD_CANCEL, task);
                dispatchEvent(downloadEvent);
                
                processEvents(downloadEvent);
                if (cleanup && task != null) task.cleanup();
                dispose();	
            }
            
            return interrupted;   
        }
        
        
        public function isPausable():Boolean
        {
            throw new IllegalOperationError("Abstract method: must be overridden in a subclass");
        }
        
        public function preRun(task:Task):void
        {
            task.setAssociated(true);
            task.addEventListener(TaskChangeEvent.TASK_STATUS_CHANGED, onTaskReady);
            task.preRun();
        }
        
        public function run():void
        {
            var task:Task = getTask();
            
            if (task != null)
            {
                preRun(task);
            }
        }
        
        private function onTaskReady(event:TaskChangeEvent):void 
        {
            var task:Task = event.task;
            task.removeEventListener(TaskChangeEvent.TASK_STATUS_CHANGED, onTaskReady);
            if (event.status != Task.STATUS_FAILED && task.isRunnableState())
            {
                running = true;
                if (DownloadManagerFacade.DEBUG)
                    trace("Task Runner: DOWMLOAD_START command sent to transport");
                dispatchEvent(new DownloadEvent(DownloadEvent.DOWNLOAD_START, task));
                
            } else {
                var evt:DownloadEvent = new DownloadEvent(DownloadEvent.DOWNLOAD_ERROR, task);
                evt.setError(task.getError());
                processEvents(evt);
            }
        }
        
        public function postRun(task:Task):void
        {
            task.setAssociated(false);  
            // Notify Task Queue
            if (DownloadManagerFacade.DEBUG)
                trace("Task Runner: Sending Task Complete to TaskQueue");
            // We can probably do this with a direct method call
            dispatchEvent( new TaskChangeEvent(TaskChangeEvent.TASK_COMPLETE, task, task.getStatus()));
            dispose();	
        }
        
        public function processEvents(event:DownloadEvent):void
        {
            
            if (event.getTask() != task) return;
            
            var error:Boolean = false;
            
            switch (event.type)
            {
                case DownloadEvent.DOWNLOAD_COMPLETE:
                    if (DownloadManagerFacade.DEBUG)
                        trace("Task Runner: Received DOWNLOAD_COMPLETE from transport");
                    running = false;
                    break;
                case DownloadEvent.DOWNLOAD_ERROR:
                    trace("Task Runner: Received DOWNLOAD_ERROR from transport");
                    handlingException = true;
                    if (!isStopFlagSet())
                    {
                        error = true;
                        handleError(event.getError(), event.getHttpEvent());
                        task.dispatchEvent(event.clone());
                    }
                    handlingException = false;
                    break;
            }
            
            if (error && !isStopFlagSet() && task.getStatus() == Task.STATUS_IN_PROGRESS)
            {
                trace("Task Runner: Non Fatal Error, now retry");
                // We should wait retryInterval then retry Download
                wait(getRetryInterval());
            }
            else
            {
                if (task.getStatus() == Task.STATUS_IN_PROGRESS)
                {
                    //check the file is fully downloaded
                    if (task.validateTaskComplete())
                    {
                        task.setStatus(Task.STATUS_SUCCEEDED);
                    }
                    else
                    {
                        if(event.type == DownloadEvent.DOWNLOAD_COMPLETE) 
                        {
                            //Got the download complete event but the file was not completed (downloaded offset was not equal to the actual file size, corrupt???)
                            //Fail this task so that the task queue can pick the next pending task to start downloading
                            handlingException = true;
                            if (!isStopFlagSet())
                            {
                                error = true;
                                var taskError:TaskError = new TaskError("The file was not fully downloaded but the download was completed");
                                taskError.setFailTask(true);
                                handleError(taskError, null);
                                
                                //clean up the corrupted file
                                cleanup = true;
                            }
                            handlingException = false;
                        }
                        else 
                        {
                            // this is when queue is disabled while transferring the file.
                            task.setStatus(Task.STATUS_PENDING);
                        }
                    }
                }
                
                if (task.getStatus() == Task.STATUS_PAUSED)
                {
                    //this is when task is just finished downloading right after the task is paused
                    if (task.validateTaskComplete())
                    {
                        task.setStatus(Task.STATUS_SUCCEEDED);
                    }
                }
                
                if (isCleanupFlagSet())
                {
                    setCleanupFlag(false); // clear flag
                    task.cleanup();
                }
                
                // paused task shouldn't call the postRun because it does not complete the download
                if ((isStopFlagSet() || !task.isRunnableState()) && task.getStatus() != Task.STATUS_PAUSED)
                {
                    setStopFlag(false); // clear flag
                    // Done
                    postRun(task);
                }
            }
        }
        
        private function wait(interval:int):void
        {
            if(timer && timer.running)
            {
                return;
            }
            
            if(!timer)
            {
                timer = new Timer(interval);
                timer.addEventListener(TimerEvent.TIMER, notify);
            }
            
            timer.start();
        }
        
        private function notify(event:TimerEvent):void
        {
            if(!timer)
            {
                return;
            }
            
            timer.stop();
            timer.removeEventListener(TimerEvent.TIMER, notify);
            timer = null;
            
            dispatchEvent(new DownloadEvent(DownloadEvent.DOWNLOAD_START, task));
            
        }		
    }
}