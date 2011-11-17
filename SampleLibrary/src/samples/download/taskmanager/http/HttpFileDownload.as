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

package samples.download.taskmanager.http
{
    import flash.events.*;
    import flash.filesystem.*;
    import flash.net.*;
    import flash.utils.ByteArray;
    
    import samples.download.DownloadManagerFacade;
    import samples.download.taskmanager.FileTransferError;
    import samples.download.taskmanager.FileTransferTask;
    import samples.download.taskmanager.FileTransferTaskRunner;
    import samples.download.taskmanager.GlobalConstants;
    import samples.download.taskmanager.Task;
    import samples.download.taskmanager.events.DownloadEvent;
    
    public class HttpFileDownload extends EventDispatcher
    {
        
        protected var task:FileTransferTask;
        private var request:URLRequest;
        private var loader:URLLoader;
        protected var streamer:URLStream;
        protected var tmpFileStream:FileStream;
        private var httpType:int;
        private var _userAgent:String;		
        
        private static const HTTP_1_0:int 			= 0;
        private static const HTTP_1_1:int 			= 1;
        public static const USER_AGENT:String		= "BlackBerry9800/5.0.0 profile/MIDP-2.1 Configuration/CLDC-1.1 VendorID/1";
        
        protected var _buffer:ByteArray;
        protected var _bufferSize:uint;
        private const DEFAULT_BUFFER_SIZE:uint = 1024*1024; //1MB
        
        public function HttpFileDownload(task:FileTransferTask, userAgent:String)
        {
            this.task = task;
            this.httpType = HTTP_1_1;
            _userAgent = userAgent;
            _bufferSize = DEFAULT_BUFFER_SIZE;
        }
        
        public function processEvents(event:DownloadEvent):void
        {
            if (DownloadManagerFacade.DEBUG)
                trace("HTTPFileDownload: Received event from Task Runner: " + event.type);
            
            switch (event.type)
            {
                case DownloadEvent.DOWNLOAD_START:
                    run();
                    break;
                case DownloadEvent.DOWNLOAD_CANCEL:
                    interrupt();
                    break;
            }
        }
        
        public function addFileDownloadListener(runner:FileTransferTaskRunner):void
        {
            addEventListener(DownloadEvent.DOWNLOAD_COMPLETE, runner.processEvents, false, 0, true);
            addEventListener(DownloadEvent.DOWNLOAD_ERROR, runner.processEvents, false, 0, true);
        }
        
        public function removeFileDownloadListener(runner:FileTransferTaskRunner):void
        {
            removeEventListener(DownloadEvent.DOWNLOAD_COMPLETE, runner.processEvents);
            removeEventListener(DownloadEvent.DOWNLOAD_ERROR, runner.processEvents);
        }
        
        public function isPausable():Boolean
        {
            return httpType != HTTP_1_0;
        }
        
        public function isValidResponseCode(code:int):Boolean
        {
            return (code == GlobalConstants.HTTP_OK || code == GlobalConstants.HTTP_PARTIAL);
        }
        
        public function interrupt():void
        {
            if (streamer != null && streamer.connected)
            {
                streamer.close();	
                if (tmpFileStream != null)
                {
                    tmpFileStream.close();
                }
            }
        }
        
        public function run():void
        {
            doRun();
        }
        
        
        public function reconcileCondition(task:FileTransferTask):Boolean
        {
            return (task.supportsHttpHead && task.getContentLength() <= 0);	
        }
        
        public function reconcileTask(task:FileTransferTask):Boolean
        {
            var url:String = task.getRemoteFileURL();
            
            if (reconcileCondition(task))
            {
                request = new URLRequest(url);	
                request.method = URLRequestMethod.HEAD;
                request.cacheResponse = false;
                request.userAgent = _userAgent;
                
                loader = new URLLoader();
                
                loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, OnReconciliationComplete);
                loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
                loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
                
                loader.load(request);
                
                return true;
            }
            else
            {
                return false;
            }
        }
        
        private function OnReconciliationComplete(event:HTTPStatusEvent):void
        {
            
            loader.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, OnReconciliationComplete);
            loader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
            loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
            loader = null;
            
            if(task.getStatus() != Task.STATUS_CANCELLED) 
            {
                if (event.status == GlobalConstants.HTTP_OK)
                {
                    var responseHeaders:Array = event.responseHeaders;
                    
                    var contentLength:Number = 0;
                    
                    for each (var header:URLRequestHeader in responseHeaders)
                    {
                        if (header.name == "Content-Length")
                        {
                            contentLength = Number(header.value);
                            break;
                        }
                    }
                    
                    if (contentLength > 0)
                    {
                        
                        task.setContentLength(contentLength);
                        
                        var redirectURL:String = event.responseURL;
                        if (redirectURL != null && redirectURL.length >0)
                        {
                            if (redirectURL != task.getRemoteFileURL())
                            {
                                task.setRemoteFileURL(redirectURL);
                                task.commitToDataSource();
                            }
                        }				
                        
                        onPostReconciliation();
                    }
                    else 
                    {
                        throwError("Invalid File Size: " + length, false, true, false, GlobalConstants.DEFAULT_CAUSE);	
                    }
                }
                else
                {
                    switch (event.status)
                    {
                        case GlobalConstants.HTTP_FILE_NOT_FOUND:
                            throwError("Failed Reconciliation", false, true, false, GlobalConstants.HTTP_FILE_NOT_FOUND);
                            break;
                        default:
                            throwError("Failed Reconciliation", false, true, false, GlobalConstants.DEFAULT_CAUSE);
                    }	 
                }
            }
            
            request = null;
        }
        
        private function doRun():void
        {
            
            if (this.task == null)
            {
                throwError("Task is null", false, true, false, GlobalConstants.DEFAULT_CAUSE);
                return;
            }
            
            if (!(this.task is FileTransferTask))
            {
                throwError("Invalid Task", false, true, false, GlobalConstants.DEFAULT_CAUSE);
                return;
            }
            
            var remoteFileURL:String = task.getRemoteFileURL();
            
            if (remoteFileURL == null || remoteFileURL.length < 1)
            {
                throwError("Invalid remoteFileURL: " + remoteFileURL, false, true, false, GlobalConstants.DEFAULT_CAUSE);
                return;
            }
            
            var localFileURL:String = task.getLocalFileURL();
            
            if (localFileURL == null || localFileURL.length < 1)
            {
                throwError("Invalid localFileURL: " + localFileURL, false, true, false, GlobalConstants.DEFAULT_CAUSE);
                return;
            }
            
            var tmpFileURL:String = task.getTmpFileURL();
            
            if (tmpFileURL == null || tmpFileURL.length < 1 || (tmpFileURL == localFileURL && task.useTempFile))
            {
                throwError("Invalid tmpFileURL: " + tmpFileURL, false, true, false, GlobalConstants.DEFAULT_CAUSE);
                return;
            }
            
            if (!reconcileTask(task))
                onPostReconciliation();
        }
        
        
        private function onPostReconciliation():void
        {	
            if(task.getStatus() != Task.STATUS_CANCELLED) 
            {
                var contentLength:Number = task.getContentLength();
                if (task.supportsHttpHead && contentLength <= 0)
                {
                    throwError("Invalid Content-Length: " + contentLength, false, false, false, GlobalConstants.DEFAULT_CAUSE);
                    return;
                }
                
                var file:File = new File(task.getLocalFileURL());
                
                if (file == null)
                {
                    throwError("Unable to create file at: " + task.getLocalFileURL(), false, false, false, GlobalConstants.DEFAULT_CAUSE);
                    return;
                }
                
                if (file.exists)
                {
                    if (file.size == contentLength && contentLength > 0)
                    {
                        trace("HTTPFileDownload: File Already exists");
                        task.setCurrentOffset(contentLength);
                        onFileExists();
                        return;
                    }
                    else if (task.useTempFile)
                    {
                        throwError("File exists: " + task.getLocalFileURL(), false, true, false, GlobalConstants.DEFAULT_CAUSE);
                        return;
                    }
                }
                
                file = null;
                tmpFileStream = null;
                
                var fileURL:String = task.useTempFile ? task.getTmpFileURL() : task.getLocalFileURL();
                var tmpFile:File = new File(fileURL);
                // TO DO make hidden
                
                try {
                    tmpFileStream = new FileStream();
                    tmpFileStream.openAsync(tmpFile, FileMode.APPEND);
                    //to register for a closed event on all FileStream objects opened asynchronously that have pending data to write, 
                    //before closing the stream (to ensure that data is written).
                    tmpFileStream.addEventListener(Event.CLOSE, fileClosed);
                } catch (exp:Error) {
                    throwError("File or directory access denied", false, true, false, GlobalConstants.INTERNAL_ERROR);
                    return;
                }
                
                var offset:Number = 0;
                
                if(tmpFile.exists) 
                {
                    offset = tmpFile.size;
                }
                
                task.setCurrentOffset(offset);
                
                // check if there is enough DiskSpace
                var requiredSize:Number = Math.max((contentLength - offset), 0);
                
                if (!checkDiskSpace(requiredSize))
                {
                    throwError("Insufficient disk Space" + requiredSize, false, true, false, GlobalConstants.INSUFFICIENT_DISKSPACE);
                    return;
                }
                
                if (contentLength == 0 || offset < contentLength)
                {
                    request = new URLRequest(task.getRemoteFileURL());
                    request.method = URLRequestMethod.GET;
                    request.cacheResponse = false;
                    request.userAgent = _userAgent;
                    
                    var range:String = "bytes=" + offset + "-" + contentLength;
                    
                    if (offset != 0)
                    {
                        request.requestHeaders = new Array(new URLRequestHeader("Range", range));	
                    }  
                    
                    streamer = new URLStream();
                    
                    streamer.addEventListener(Event.COMPLETE, onDownloadComplete);
                    streamer.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
                    streamer.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
                    streamer.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onResponseStatus);
                    streamer.addEventListener(ProgressEvent.PROGRESS, onDownloadProgress);
                    
                    streamer.load(request);		
                }
                else
                {
                    // Tmp File matches content length, finalize Download
                    finalizeDownload()
                }
                
            }
        }
        
        private function onError(error:Error, httpEvent:HTTPStatusEvent = null):void
        {
            var errEvent:DownloadEvent = new DownloadEvent(DownloadEvent.DOWNLOAD_ERROR, task, httpEvent);
            errEvent.setError(error);
            dispatchEvent(errEvent);
        }
        
        
        private function onNetworkError(errorMsg:String, cause:int, event:HTTPStatusEvent = null):void
        {
            if (loader != null)
            {
                loader.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, OnReconciliationComplete);
                loader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
                loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
                loader.close();
                loader = null;
            }
            
            if (streamer != null)
            {
                streamer.removeEventListener(Event.COMPLETE, onDownloadComplete);
                streamer.removeEventListener(ProgressEvent.PROGRESS, onDownloadProgress);
                streamer.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onResponseStatus);	
                streamer.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
                streamer.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
                streamer.close();
                streamer = null;
            }
            
            throwError(errorMsg, false, true, false, cause, event);
        }
        
        private function onFileExists():void
        {
            dispatchEvent(new DownloadEvent(DownloadEvent.DOWNLOAD_COMPLETE, task));
            if (streamer != null)
            {
                streamer.removeEventListener(Event.COMPLETE, onDownloadComplete);
                streamer.removeEventListener(ProgressEvent.PROGRESS, onDownloadProgress);
                streamer.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onResponseStatus);
                streamer.close();
                streamer = null;
            }
        }
        
        private function finalizeDownload():void
        {
            tmpFileStream.close();
        }
        
        private function fileClosed(event:Event):void 
        {
            trace("Finish download and the file stream is closed");
            var complete:Boolean = task.validateTaskComplete();
            
            if (complete && task.useTempFile)
            {
                var file:File = new File(task.getLocalFileURL());
                var tmpFile:File = new File(task.getTmpFileURL());
                tmpFile.moveToAsync(file, true);
            }
            tmpFileStream.removeEventListener(Event.CLOSE, fileClosed);
            tmpFileStream = null;   
        } 
        
        protected function checkDiskSpace(requiredSize:Number):Boolean
        {
            
            // 250 MBs arbitrary OS limit, use 260 MB as an additionnal protection
            var RESERVED_OS_DISKSPACE:Number = 260 * 1024 * 1024;
            var availableSpace:Number = File.applicationDirectory.spaceAvailable;
            trace("Space left: " + availableSpace);
            
            if ((RESERVED_OS_DISKSPACE + requiredSize) >= availableSpace)
            {
                return false;
            }
            
            return true;
        }
        
        
        private function createError(msg:String, pauseTask:Boolean, failTask:Boolean, fatal:Boolean):FileTransferError
        {
            var e:FileTransferError = new FileTransferError(msg);
            e.setPauseTask(pauseTask);    
            e.setFailTask(failTask);
            e.setFatal(fatal);
            e.setCause(GlobalConstants.DEFAULT_CAUSE);
            return e;
        }
        
        protected function throwError(msg:String, pauseTask:Boolean, failTask:Boolean, fatal:Boolean, cause:int, httpEvent:HTTPStatusEvent = null):void
        {
            var e:FileTransferError = new FileTransferError(msg);
            e.setPauseTask(pauseTask);    
            e.setFailTask(failTask);
            e.setFatal(fatal);
            if (cause != GlobalConstants.DEFAULT_CAUSE) e.setCause(cause);
            onError(e, httpEvent);
        }
        
        public function get userAgent():String 
        {
            return _userAgent;
        }
        
        public function set userAgent(userAgent:String):void
        {
            _userAgent = userAgent;
        }
        
        public function onDownloadComplete(event:Event):void
        {
            try {
                if(_buffer && _buffer.bytesAvailable > 0) 
                {
                    tmpFileStream.writeBytes(_buffer, 0, _buffer.length);				
                    task.advanceCurrentOffset(_buffer.length);	
                    _buffer = null;
                }
                
                finalizeDownload();
                
                dispatchEvent(new DownloadEvent(DownloadEvent.DOWNLOAD_COMPLETE, task));
                streamer.removeEventListener(Event.COMPLETE, onDownloadComplete);
                streamer.removeEventListener(ProgressEvent.PROGRESS, onDownloadProgress);
                streamer.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onResponseStatus);
                streamer.close();
                streamer = null;
            } 
            catch (exp:Error) 
            {
                if (!checkDiskSpace(_buffer.length))				
                {					
                    throwError("Insufficient disk Space" + _buffer.length, false, true, false, GlobalConstants.INSUFFICIENT_DISKSPACE);
                    return;
                }
                else
                {
                    throwError("Cannot write file to file system", false, true, false, GlobalConstants.INTERNAL_ERROR);
                    return;					
                }				
            }
        }
        
        
        public function onIOError(event:IOErrorEvent):void
        {
            trace("HTTPFileDownload: IOError: " + event.type);
            onNetworkError("HTTPFileDownload: IOError: " + event.type, GlobalConstants.DEFAULT_CAUSE);
        }
        
        public function onSecurityError(event:SecurityErrorEvent):void
        {
            trace("HTTPFileDownload: SecurityError: " + event.type);
            onNetworkError("HTTPFileDownload: SecurityError: " + event.type, GlobalConstants.DEFAULT_CAUSE);
        }
        
        public function onResponseStatus(event:HTTPStatusEvent):void
        {
            if (DownloadManagerFacade.DEBUG)
                trace("HTTPFileDownload: ResponseStatus: " + event.status);
            
            if (task.getContentLength() == 0) {
                for each (var header:URLRequestHeader in event.responseHeaders)
                {
                    if (header.name == "Content-Length")
                    {
                        task.setContentLength(Number(header.value));
                        task.commitToDataSource();
                        
                        var fileURL:String = task.useTempFile ? task.getTmpFileURL() : task.getLocalFileURL();
                        var file:File = new File(fileURL);
                        if (file.size == task.getContentLength()) {
                            task.setStatus(Task.STATUS_SUCCEEDED);
                            onDownloadComplete(null);
                            return;
                            
                        } else if (file.size > 0) {
                            // Overwrite a temp file if we didn't have a valid contentLength
                            if (tmpFileStream)
                                tmpFileStream.close();
                            
                            if (file.exists)
                                file.deleteFile();
                            
                            tmpFileStream = new FileStream();
                            tmpFileStream.openAsync(file, FileMode.WRITE);
                            tmpFileStream.addEventListener(Event.CLOSE, fileClosed);
                        }
                        break;
                    }
                }
            }
            
            if (event.status != GlobalConstants.HTTP_OK && event.status != GlobalConstants.HTTP_PARTIAL)
            {
                if (event.status == GlobalConstants.HTTP_OUT_OF_RANGE)
                {
                    // This means the server doesnt support HTTP 1.0
                    // and we only send a range request when tmp file exists
                    // so delete tmp file and start over.
                    
                    this.httpType = HTTP_1_0;
                    
                    tmpFileStream.close();
                    tmpFileStream = null;
                    
                    var tmpFile:File = new File(task.getTmpFileURL());
                    if (tmpFile.exists)
                        tmpFile.deleteFile();
                    
                    tmpFileStream = new FileStream();
                    tmpFileStream.openAsync(tmpFile, FileMode.APPEND);
                    tmpFileStream.addEventListener(Event.CLOSE, fileClosed);
                    
                    var offset:Number = 0;
                    
                    if(tmpFile.exists) 
                    {
                        offset = tmpFile.size;
                    }
                    
                    task.setCurrentOffset(offset);
                    
                    request = new URLRequest(task.getRemoteFileURL());
                    request.method = URLRequestMethod.GET;
                    request.cacheResponse = false;
                    request.userAgent = this.userAgent;
                    
                    streamer.load(request);	
                }
                else if (event.status == GlobalConstants.HTTP_FILE_NOT_FOUND)
                {
                    onNetworkError("Received Invalid Response: " + event.status, GlobalConstants.HTTP_FILE_NOT_FOUND);
                }
                else
                {
                    onNetworkError("Received Invalid Response: " + event.status, GlobalConstants.DEFAULT_CAUSE, event);
                }
            }
            
            // Update the task status
            if (task.getStatus() != Task.STATUS_FAILED)
                task.setStatus(Task.STATUS_IN_PROGRESS);
        }
        
        public function onDownloadProgress(event:ProgressEvent):void
        {			
            if(!_buffer) 
            {
                _buffer = new ByteArray();
            } 
            else if (_buffer.bytesAvailable >= _bufferSize) 
            {
                _buffer.clear();
            }
            
            var dataIncrease:Number = streamer.bytesAvailable;
            
            //read the data from streamer to buffer
            streamer.readBytes(_buffer, _buffer.length, streamer.bytesAvailable);
            
            try
            {
                if(_buffer.bytesAvailable >= _bufferSize) 
                {
                    //write the buffer to the file
                    tmpFileStream.writeBytes(_buffer, 0, _buffer.length);				
                    
                    //fire the download progress event every 1MB, more efficient???
                    //task.advanceCurrentOffset(_buffer.length);
                    
                    _buffer.clear();
                }
                
                //fire the download progress event 			
                task.advanceCurrentOffset(dataIncrease);
            }
            catch (exp:Error) 
            {
                if (!checkDiskSpace(_buffer.length))				
                {					
                    throwError("Insufficient disk Space" + _buffer.length, false, true, false, GlobalConstants.INSUFFICIENT_DISKSPACE);
                    return;
                }
                else
                {
                    throwError("Cannot write file to file system", false, true, false, GlobalConstants.INTERNAL_ERROR);
                    return;					
                }				
            }
        }
        
        public function set bufferSize(bufferSize:uint):void 
        {
            _bufferSize = bufferSize;
        }
    }
}