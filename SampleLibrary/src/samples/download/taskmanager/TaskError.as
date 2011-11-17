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
    public class TaskError extends Error
    {
        
        private var fatal:Boolean = false; // queue will go sleep mode
        private var failTask:Boolean = false; // put the task into failed state
        private var pauseTask:Boolean = false; // put the task into pause state
        
        private var cause:int;
        
        public function TaskError(message:String)
        {
            super(message);
        }
        
        public function isFatal():Boolean
        {
            return fatal;
        }
        
        public function setFatal(fatal:Boolean):void
        {
            this.fatal = fatal;
        }
        
        public function getCause():int
        {
            return cause;
        }
        
        public function setCause(cause:int):void
        {
            this.cause = cause;
        }
        
        public function isFailTask():Boolean
        {
            return failTask;
        }
        
        public function setFailTask(failTask:Boolean):void
        {
            this.failTask = failTask;
        }
        
        public function isPauseTask():Boolean
        {
            return pauseTask;
        }
        
        public function setPauseTask(pauseTask:Boolean):void
        {
            this.pauseTask = pauseTask;
        }  
    }
}