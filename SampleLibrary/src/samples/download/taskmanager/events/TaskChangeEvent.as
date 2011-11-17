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

package samples.download.taskmanager.events
{
    import flash.events.Event;
    
    import samples.download.taskmanager.Task;
    
    public class TaskChangeEvent extends Event
    {
        
        public static const TASK_STATUS_CHANGED:String = "TASK_STATUS_CHANGED";
        public static const TASK_COMPLETE:String = "TASK_COMPLETE";
        
        public var task:Task;
        public var status:int;
        
        public function TaskChangeEvent(type:String, task:Task, status:int)
        {
            super(type,true);
            this.task = task;
            this.status = status;
        }
    }
}