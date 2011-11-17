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
    import samples.download.taskmanager.events.DownloadEvent;
    import samples.download.taskmanager.http.HttpFileDownload;
    
    public class FileTransferTaskRunner extends TaskRunner
    {
        
        public static const HTTP_MODE:String = "HTTP_MODE";
        
        protected var fileDownload:HttpFileDownload;
        
        public function FileTransferTaskRunner(task:FileTransferTask, mode:String, userAgent:String)
        {
            super(task);
            
            switch (mode)
            {
                case HTTP_MODE:
                default:
                    fileDownload = new HttpFileDownload(task, userAgent);
                    break;
            }
        }
        
        public override function isPausable():Boolean
        {
            return fileDownload.isPausable();
        }
        
        public override function preRun(task:Task):void
        {			
            fileDownload.addFileDownloadListener(this);
            addEventListener(DownloadEvent.DOWNLOAD_CANCEL, fileDownload.processEvents, false, 0, true);
            addEventListener(DownloadEvent.DOWNLOAD_START, fileDownload.processEvents, false, 0, true);
            
            super.preRun(task);
        }
        
        public override function postRun(task:Task):void
        {
            super.postRun(task);
            
            fileDownload.removeFileDownloadListener(this);
            removeEventListener(DownloadEvent.DOWNLOAD_CANCEL, fileDownload.processEvents);
            removeEventListener(DownloadEvent.DOWNLOAD_START, fileDownload.processEvents);
        }
    }
}