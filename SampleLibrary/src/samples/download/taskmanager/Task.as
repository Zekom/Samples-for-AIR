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
    import flash.utils.getTimer;
    
    import samples.download.taskmanager.ds.SQLTaskDataSource;
    import samples.download.taskmanager.ds.TaskSerializer;
    import samples.download.taskmanager.events.TaskChangeEvent;
    import samples.download.taskmanager.events.TaskProgressEvent;
    import samples.download.taskmanager.utils.ProgressCallback;
    import samples.download.taskmanager.utils.ProgressHandle;
    
    public class Task extends EventDispatcher implements ProgressCallback
    {
        public static const STATUS_INITIALIZED:int   = 0x01;
        public static const STATUS_IN_PROGRESS:int   = 0x02;
        public static const STATUS_SUCCEEDED:int     = 0x03;
        public static const STATUS_FAILED:int        = 0x04;
        public static const STATUS_CANCELLED:int     = 0x05;
        public static const STATUS_PAUSED:int        = 0x06;
        public static const STATUS_PENDING:int   	 = 0x07;
        public static const STATUS_AVAILABLE:int     = 0x08;
        
        public static const NO_CONTEXT:int = -1;
        public static const DEFAULT_APPLICATION_ID:String = "DEFAULT_APPLICATION_ID";
        
        public static function getStatusDescription(s:int):String
        {
            var desc:String = null;
            
            switch (s)
            {
                case STATUS_INITIALIZED:
                    desc = "Initialized";
                    break;
                case STATUS_IN_PROGRESS:
                    desc = "In Progress";
                    break;
                case STATUS_AVAILABLE:
                    desc = "Available";
                    break;
                case STATUS_SUCCEEDED:
                    desc = "Succeeded";
                    break;         
                case STATUS_FAILED:
                    desc = "Failed";
                    break;
                case STATUS_CANCELLED:
                    desc = "Cancelled";
                    break;
                case STATUS_PAUSED:
                    desc = "Paused";
                    break;
                case STATUS_PENDING:
                    desc = "Pending";
                    break;
            }
            return desc;
        }
        
        private var applicationID:String = null;
        
        private var _id:String = null;
        
        private var context:int = NO_CONTEXT;
        
        private var priority:Boolean = false;
        
        private var error:Error = null;
        
        private var serializedError:String = null;
        
        private var startTime:int = 0;
        
        private var endTime:int =  0; 
        
        private var status:int = STATUS_INITIALIZED;
        
        private var progress:ProgressHandle; 
        
        private var associated:Boolean = false;
        
        private var customData:String;
        
        private var _serverSupportsHead:Boolean;
        
        private var _type:int;
        
        /**
         * No need to use an Application Id when the download manager is used by a single application 
         * */
        public function Task(id:String=null, appId:String="DEFAULT_APPLICATION_ID")
        {
            progress = new ProgressHandle();
            progress.setCallback(this);
            applicationID = appId;
            _id = id;
            
            _serverSupportsHead = true;
        }
        
        public function getId():String 
        {
            return _id;
        }
        
        public function setId(id:String):void 
        {
            this._id = id;
        }
        
        public function getApplicationId():String 
        {
            return applicationID;
        }
        
        public function setApplicationId(applicationID:String):void 
        {
            this.applicationID = applicationID;
        }
        
        public function getTaskType():int
        {
            return TaskSerializer.TYPE_DEFAULT_TASK;
        }
        
        public function getContext():int
        {
            return context;
        }
        
        public function setContext(context:int):void
        {
            this.context = context;
        }
        
        public override function toString():String 
        {
            return "Task: " + _id + ", Context: " + context + " [" + getStatusDescription(status) + "]" + " Progress: " + getProgress();
        }
        
        public function isPriority():Boolean 
        {
            return priority;
        }
        
        public function setPriority(priority:Boolean):void 
        {
            this.priority = priority;
        }
        
        public function getStartTime():int
        {
            return startTime;
        }
        
        public function setStartTime(startTime:int):void
        {
            this.startTime = startTime;
        }
        
        public function getEndTime():int
        {
            return endTime;
        }
        
        public function setEndTime(endTime:int):void
        {
            this.endTime = endTime;
        }
        
        public function getDuration():int 
        {
            return this.endTime - this.startTime;
        }
        
        public function getProgress():int
        {
            return progress.getProgress();
        }
        
        public function getProgressHandle():ProgressHandle
        {
            return this.progress;
        }
        
        public function getError():Error 
        {
            return error;
        }
        
        public function setError(error:Error, httpEvent:HTTPStatusEvent):void 
        {
            this.error = error;
            var es:IErrorSerializer = Registry.getInstance().getErrorSerializer();
            if (es != null)
            {
                setSerializedError(es.serialize(error));
            }
        }
        
        public function setSerializedError(serializedError:String):void
        {
            this.serializedError = serializedError;
        }
        
        public function getSerializedError():String
        {
            return serializedError;
        }
        
        public function preRun():void 
        {
            var evt:TaskChangeEvent = new TaskChangeEvent(TaskChangeEvent.TASK_STATUS_CHANGED, this, Task.STATUS_INITIALIZED);
            dispatchEvent(evt);
        }
        
        protected function reset():void
        {
            this.startTime = 0;
            this.endTime = 0;
            this.error = null;
            this.progress.reset();
        }
        
        public function commitToDataSource():void
        {
            var source:SQLTaskDataSource = Registry.getInstance().getTaskDataSource();
            if (source != null) source.saveTask(this);
        }
        
        public function notifyStatusChanged():void
        {
            dispatchEvent(new TaskChangeEvent(TaskChangeEvent.TASK_STATUS_CHANGED, this, getStatus())); 
            Registry.getInstance().notifyTaskStatusChanged(this, getStatus());
        }
        
        public function notifyProgressChanged():void
        {
            dispatchEvent(new TaskProgressEvent(TaskProgressEvent.TASK_PROGRESS_CHANGED, this, getProgressHandle()));
            Registry.getInstance().notifyTaskProgressChanged(this);
        }
        
        public function getCurrentOffset():Number
        {
            return progress.getPosition();
        }
        
        public function advanceCurrentOffset(increase:Number):void
        {
            advanceCurrentOffsetAndFireEvent(increase, true);
        }
        
        public function advanceCurrentOffsetAndFireEvent(increase:Number, fireEvent:Boolean):void
        {
            progress.advancePositionAndFireEvent(increase, fireEvent);
        }
        
        public function setCurrentOffset(currentOffset:Number):void
        {
            setCurrentOffsetAndFireEvent(currentOffset, true);
        }
        
        public function setCurrentOffsetAndFireEvent(currentOffset:Number, fireEvent:Boolean):void
        {
            progress.setPositionAndFireEvent(currentOffset, fireEvent);
        }
        
        public function getContentLength():Number
        {
            return progress.getLength();
        }
        
        public function setContentLength(contentLength:Number):void
        {
            setContentLengthAndFireEvent(contentLength, true);
        }
        
        public function setContentLengthAndFireEvent(contentLength:Number, fireEvent:Boolean):void
        {
            progress.setLengthAndFireEvent(contentLength, fireEvent);
        }
        
        public function progressChanged(handle:ProgressHandle):void
        {
            notifyProgressChanged();
        }
        
        public function getStatus():int
        {
            return status;
        }
        
        
        public function setStatusAndCommit(status:int, commit:Boolean, fireEvent:Boolean):void
        {
            this.status = status;
            switch (status)
            {
                case STATUS_IN_PROGRESS:
                    if (getStartTime() == 0) setStartTime(flash.utils.getTimer());
                    break;
                
                case STATUS_SUCCEEDED:
                case STATUS_CANCELLED:
                case STATUS_FAILED:
                    setEndTime(flash.utils.getTimer());
                    if (getStartTime() == 0) setStartTime(getEndTime());
                    break;
            }
            
            if (commit)
            {
                commitToDataSource();
            }
            
            // fire event for status change
            if (fireEvent)
            {
                notifyStatusChanged();
            }        
        }
        
        public function setStatus(status:int):void
        {
            setStatusAndCommit(status, true, true);
        }
        
        public function isRunnableState():Boolean
        {
            return (status == STATUS_INITIALIZED 
                || status == STATUS_PENDING 
                || status == STATUS_IN_PROGRESS);
        }
        
        public function setPause():Boolean
        {
            if (isRunnableState())
            {
                this.setStatus(Task.STATUS_PAUSED);
                return true;
            }
            return false;
        }
        
        public function setResume():Boolean
        {
            if (status == Task.STATUS_PAUSED)
            {
                this.setStatus(Task.STATUS_PENDING);
                return true;
            }
            return false;
        }
        
        public function setRestart():Boolean
        {
            reset();
            this.setStatus(Task.STATUS_PENDING);
            return true;
        }
        
        public function setQueued():Boolean
        {
            if (status == Task.STATUS_INITIALIZED)
            {
                this.setStatus(Task.STATUS_PENDING);
                return true;
            }
            return false;
        }
        
        public function setCancel():Boolean
        {
            /*if (status == Task.STATUS_INITIALIZED
            || status == Task.STATUS_IN_PROGRESS
            || status == Task.STATUS_PAUSED
            || status == Task.STATUS_FAILED
            || status == Task.STATUS_PENDING)
            {*/
            this.setStatus(Task.STATUS_CANCELLED);
            this.progress.reset();
            return true;
            /*}   
            return false;*/
        }    
        
        public function isAssociated():Boolean
        {
            return associated;
        }
        
        public function setAssociated(associated:Boolean):void
        {
            this.associated = associated;
        }
        
        public function cleanup():void
        {
            throw new IllegalOperationError("Abstract method: must be overridden in a subclass");
        }
        
        public function validateTaskComplete():Boolean
        {
            throw new IllegalOperationError("Abstract method: must be overridden in a subclass");
        }	
        
        public function getCustomData():String
        {
            return customData;
        }
        
        public function setCustomData(data:String):void
        {
            customData = data;
        }
        
        public function set supportsHttpHead(serverSupportsHead:Boolean):void {
            _serverSupportsHead = serverSupportsHead;
        }
        
        public function get supportsHttpHead():Boolean {
            return _serverSupportsHead;
        }
    }
}