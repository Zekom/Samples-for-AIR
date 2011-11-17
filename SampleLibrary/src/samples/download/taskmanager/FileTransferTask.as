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
    import flash.filesystem.File;
    
    import samples.download.taskmanager.ds.TaskSerializer;
    
    public class FileTransferTask extends Task
    {
        private static const TMP_EXT:String = ".tmp";
        
        private var download:Boolean;
        
        private var remoteFileURL:String;
        
        private var localFileURL:String;
        
        private var tmpFileURL:String;
        
        public function FileTransferTask(id:String=null, remoteFileURL:String=null, localFileURL:String=null, download:Boolean=false)
        {
            super(id);
            
            this.remoteFileURL = remoteFileURL;
            this.localFileURL = localFileURL;
            this.download = download;
        }
        
        public override function getTaskType():int
        {
            return TaskSerializer.TYPE_FILE_TRANSFER_TASK;
        }
        
        /**
         * Override this property if you'd like to avoid using temp files
         * */
        public function get useTempFile():Boolean 
        {
            return true;
        }
        
        public function getRemoteFileURL():String
        {
            return remoteFileURL;
        }
        
        public function setRemoteFileURL(remoteFileURL:String):void
        {
            this.remoteFileURL = remoteFileURL;
        }
        
        public function getLocalFileURL():String
        {
            return localFileURL;
        }
        
        public function setLocalFileURL(localFileURL:String):void
        {
            this.localFileURL = localFileURL;
            this.tmpFileURL = null;
        }
        
        public function getTmpFileURL():String
        {
            if (tmpFileURL == null)
            {
                var local:String = getLocalFileURL();
                if (local != null)
                {
                    tmpFileURL = local + TMP_EXT;
                }            
            }
            
            return tmpFileURL;
        }
        
        public function isDownload():Boolean
        {
            return download;
        }
        
        public function setDownload(download:Boolean):void
        {
            this.download = download;
        }
        
        public override function cleanup():void
        {
            if (download)
            {
                var tmpFileURL:String = this.getTmpFileURL();
                
                if (tmpFileURL != null && tmpFileURL.length > 0)
                {
                    var tmpFile:File = new File(tmpFileURL);
                    
                    if (tmpFile.exists)
                        tmpFile.deleteFile();
                }
                
                var localURL:String = this.getLocalFileURL();
                
                if (localURL != null && localURL.length > 0)
                {
                    var localFile:File = new File(localURL);
                    
                    if (localFile.exists)
                        localFile.deleteFile();
                }
            }
        }
        
        public override function validateTaskComplete():Boolean
        {
            return (getContentLength() > 0 && 
                getCurrentOffset() >= getContentLength());
        }
    }
}