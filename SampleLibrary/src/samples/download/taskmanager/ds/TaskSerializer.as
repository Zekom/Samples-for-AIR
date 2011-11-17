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

package samples.download.taskmanager.ds
{
    import samples.download.taskmanager.FileTransferTask;
    import samples.download.taskmanager.Task;
    
    public class TaskSerializer
    {
        public static const TYPE_DEFAULT_TASK:int = 0x00;
        public static const TYPE_FILE_TRANSFER_TASK:int = 0x01;
        public static var AVAILABLE_TYPES:Array = [Task, FileTransferTask];
        
        
        public static function serializeForInsert(task:Task):String
        {
            var remote_url:String = "";
            var local_url:String = "";
            var isDownloaded:int = 0;
            var customData:String = "";
            var priority:int = task.isPriority() ? 1:0;
            var errorString:String = "";
            var type:int = task.getTaskType();;
            
            if (task is FileTransferTask)
            {
                remote_url = FileTransferTask(task).getRemoteFileURL();
                local_url = FileTransferTask(task).getLocalFileURL();
                isDownloaded = FileTransferTask(task).isDownload() ? 1:0;
                customData = FileTransferTask(task).getCustomData();
            }
            
            if (task.getSerializedError() != null)
            {
                errorString = task.getSerializedError();
            }
            
            return  "('" 
            + task.getApplicationId() + "' , '" 
                + task.getId() + "' , "
                + type + " , "
                + task.getContext() + " , "
                + task.getStatus() + " , " 
                + priority + " , "
                + task.getStartTime() + " , "
                + task.getEndTime() + " , "
                + task.getContentLength() + " , "
                + task.getCurrentOffset() + " , '"
                + errorString + "' , '"
                + remote_url + "' , '" 
                + local_url + "' , " 
                + isDownloaded + " , '"
                + customData
                + "')";			
        }
        
        public static function serializeForUpdate(task:Task):String
        {
            var remote_url:String = "";
            var local_url:String = "";
            var isDownloaded:int = 0;
            var customData:String = "";
            var priority:int = task.isPriority() ? 1:0;
            var errorString:String = "";
            
            if (task is FileTransferTask)
            {
                remote_url = FileTransferTask(task).getRemoteFileURL();
                local_url = FileTransferTask(task).getLocalFileURL();
                isDownloaded = FileTransferTask(task).isDownload() ? 1:0;
                customData = FileTransferTask(task).getCustomData();
            }
            
            if (task.getSerializedError() != null)
            {
                errorString = task.getSerializedError();
            }
            
            return  "Context =" + task.getContext() + " , "
                + "Status =" + task.getStatus() + " , "
                + "Priority =" + priority + " , "
                + "Start_Time =" + task.getStartTime() + " , "
                + "End_Time =" + task.getEndTime() + " , "
                + "Content_Length =" + task.getContentLength() + " , "
                + "Current_Offset =" + task.getCurrentOffset() + " , "
                + "Error = '" + errorString + "' , "
                + "Remote_URL = '" + remote_url + "' , "
                + "Local_URL = '" + local_url + "' , "
                + "CustomData = '" + customData + "' , "
                + "isDownloaded =" + isDownloaded;		
        }
        
        public static function deSerialize(arr:Array):Array
        {
            
            var taskArray:Array = new Array();
            var task:Task;
            
            for (var i:int=0;i<arr.length;i++)
            {
                arr[i].index = i;
                
                if (!arr[i].Application)
                {
                    continue;
                }
                
                if (!arr[i].ID)
                {
                    continue;
                }
                
                var classname:Class = AVAILABLE_TYPES[arr[i].Type];
                task = new classname(); // each class extending Task must have a default constructor, or provide default values for each param
                
                task.setApplicationId(arr[i].Application);
                task.setId(arr[i].ID);
                
                if (arr[i].Context)
                    task.setContext(arr[i].Context);
                else
                    task.setContext(Task.NO_CONTEXT);
                
                if (arr[i].Status)
                    task.setStatusAndCommit(arr[i].Status, false, false);
                else
                    task.setStatusAndCommit(Task.STATUS_INITIALIZED, false, false);
                
                if (arr[i].Priority)
                {
                    var priority:Boolean = (arr[i].Priority == 1);
                    task.setPriority(priority);
                }
                else
                    task.setPriority(false);
                
                if (arr[i].Start_Time)
                    task.setStartTime(arr[i].Start_Time);
                else
                    task.setStartTime(0);
                
                if (arr[i].End_Time)
                    task.setEndTime(arr[i].Start_Time);
                else
                    task.setEndTime(0);
                
                if (arr[i].Error)
                {
                    task.setSerializedError(arr[i].Error);
                }
                else
                    task.setSerializedError(null);
                
                if (arr[i].Content_Length)
                    task.setContentLengthAndFireEvent(arr[i].Content_Length, false);
                else
                    task.setContentLengthAndFireEvent(0, false);
                
                if (arr[i].Current_Offset)
                    task.setCurrentOffsetAndFireEvent(arr[i].Current_Offset, false);
                else
                    task.setCurrentOffsetAndFireEvent(0, false);
                
                if (arr[i].Remote_URL || arr[i].Local_URL || arr[i].isDownloaded || arr[i].customData || arr[i].SupportHttpHeadRequest)
                {
                    if (arr[i].Remote_URL)
                        FileTransferTask(task).setRemoteFileURL(arr[i].Remote_URL);
                    else 
                        FileTransferTask(task).setRemoteFileURL(null);
                    
                    if (arr[i].Local_URL)
                        FileTransferTask(task).setLocalFileURL(arr[i].Local_URL);
                    else 
                        FileTransferTask(task).setLocalFileURL(null);
                    
                    if (arr[i].isDownloaded != null)
                    {
                        var isDownload:Boolean = (arr[i].isDownloaded == 1);
                        FileTransferTask(task).setDownload(isDownload);
                    }
                    else 
                        FileTransferTask(task).setDownload(false);
                    
                    if (arr[i].CustomData)
                        FileTransferTask(task).setCustomData(arr[i].CustomData);
                    else 
                        FileTransferTask(task).setCustomData(null);
                    
                    if (arr[i].SupportHttpHeadRequest != null)
                        FileTransferTask(task).supportsHttpHead = arr[i].SupportHttpHeadRequest == 1 ? true : false;
                }
                
                taskArray.push(task);
                
            }
            
            return taskArray;
        }
        
    }
}