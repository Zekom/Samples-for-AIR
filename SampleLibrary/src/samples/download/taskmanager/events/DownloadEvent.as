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
    import flash.events.HTTPStatusEvent;
    
    import samples.download.taskmanager.Task;
    
    public class DownloadEvent extends Event
    {	
        public static const DOWNLOAD_START:String = "DOWNLOAD_START";
        public static const DOWNLOAD_COMPLETE:String = "DOWNLOAD_COMPLETE";
        public static const DOWNLOAD_ERROR:String = "DOWNLOAD_ERROR";
        public static const DOWNLOAD_CANCEL:String = "DOWNLOAD_CANCEL";
        
        private var task:Task;
        private var error:Error;
        private var httpEvent:HTTPStatusEvent;
        
        public function DownloadEvent(type:String, task:Task, httpEvent:HTTPStatusEvent = null)
        {
            super(type, true);
            this.task = task;
            this.httpEvent = httpEvent;
        }
        
        public function setError(e:Error):void
        {
            this.error = e;
        }
        
        public function getError():Error
        {
            return error;
        }
        
        public function getTask():Task
        {
            return task;
        }
        
        public function getHttpEvent():HTTPStatusEvent 
        {
            return httpEvent;
        }
        
        public override function clone():Event 
        {
            var event:DownloadEvent = new DownloadEvent(this.type, this.task, this.httpEvent);
            event.error = this.error;
            
            return event;
        }
    }
}