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
package ui.views
{
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.filesystem.File;
    import flash.text.TextFormat;
    
    import qnx.dialog.AlertDialog;
    import qnx.display.IowWindow;
    import qnx.ui.buttons.LabelButton;
    import qnx.ui.core.Container;
    import qnx.ui.core.ContainerAlign;
    import qnx.ui.core.ContainerFlow;
    import qnx.ui.core.Containment;
    import qnx.ui.skins.SkinStates;
    import qnx.ui.text.Label;
    
    import samples.download.DownloadManagerFacade;
    import samples.download.taskmanager.FileTransferTask;
    import samples.download.taskmanager.Task;
    import samples.download.taskmanager.events.TaskChangeEvent;
    import samples.download.taskmanager.events.TaskProgressEvent;
    import samples.ui.components.DownloadProgress;
    import samples.utils.Fonts;
    
    
    /**
     * Example class that demonstrates how to add and remove download tasks to the download manager.
     * 
     */  
    public class SampleViewDownloadManager  extends SampleView
    {
        
        // SET URL TO DOWNLOAD FROM HERE Before running application
        private var FILE_TO_DOWNLOAD_URL:String  = "http://replace_with_valid_url.com";
        
        // Unique Task id assigned to download tasks, used to retrieve  
        // task from download manager. Since this a demo the same ID is used 
        // over and over again and it's removed after each download.
        private var  TASK_ID:String = "100001"; 
        
        // Download manager declarations
        private var _progressBar:DownloadProgress;
        private var _task:FileTransferTask;
        private var _mgr:DownloadManagerFacade;
        private var _btnAddTask:LabelButton;
        private var _btnPauseTask:LabelButton;
        private var _btnRemoveTask:LabelButton;
        private var _downloading:Boolean = false;
        private var _downloadItem:Container;
        private var _downloadItemTitle:Label;
        private var _alertDialog:AlertDialog;
        
        
        public function SampleViewDownloadManager()
        {
            super();
            
            setTitleText("Download Manager");
            
        }
        
        override protected function init():void
        {
            super.init();// ensure titleContainer is initialized.

            _mgr = new DownloadManagerFacade();
            
            // This is not a necessary step. Example of deleting task queue. 
            // Only use it if you want to delete persisted tasks remaining from a previous session.
            // Since this demo uses the same ID over and over again, it's removed after each download
            _mgr.removeAllTasks(true);
            
            // create and add progress bar
            _downloadItemTitle = new Label();
            _downloadItemTitle.text = "Download task";
            _downloadItemTitle.textField.textColor = 0x464545;
            _downloadItemTitle.width = 180;
            _downloadItemTitle.opaqueBackground = 0x999999;
            
            _progressBar = new DownloadProgress(125, "pending","waiting","paused");
            _progressBar.opaqueBackground = 0x999999;
            
            
            _downloadItem = new Container();
            _downloadItem.flow = ContainerFlow.HORIZONTAL;
            _downloadItem.containment = Containment.UNCONTAINED;
            _downloadItem.align = ContainerAlign.NEAR;
            _downloadItem.opaqueBackground = 0x999999;
            _downloadItem.padding = 10;
            
            var textFormat:TextFormat = new TextFormat();
            textFormat.size = 12;
            
            // create and add buttons to allow control of task.
            _btnAddTask = new LabelButton();
            _btnAddTask.label_txt.defaultTextFormat = textFormat;
            
            
            _btnAddTask.addEventListener(MouseEvent.CLICK, buttonClicked_Add, false, 0, true);
            _btnAddTask.enabled = true;
            _btnAddTask.label = "Start download";
            _btnAddTask.getTextFormatForState(SkinStates.UP).size = 12;
            _btnAddTask.getTextFormatForState(SkinStates.DOWN).size = 12;
            _btnAddTask.getTextFormatForState(SkinStates.SELECTED).size = 12;
            _btnAddTask.getTextFormatForState(SkinStates.DISABLED).size = 12;
            
            
            // create and add buttons to allow control of task.
            _btnPauseTask = new LabelButton();
            _btnPauseTask.addEventListener(MouseEvent.CLICK, buttonClicked_PauseResume, false, 0, true);
            _btnPauseTask.enabled = false;
            _btnPauseTask.label = "Pause download";
            _btnPauseTask.getTextFormatForState(SkinStates.UP).size = 12;
            _btnPauseTask.getTextFormatForState(SkinStates.DOWN).size = 12;
            _btnPauseTask.getTextFormatForState(SkinStates.SELECTED).size = 12;
            _btnPauseTask.getTextFormatForState(SkinStates.DISABLED).size = 12;
            _btnPauseTask.label_txt.defaultTextFormat = textFormat;
            
            
            
            
            _btnRemoveTask = new LabelButton();
            _btnRemoveTask.addEventListener(MouseEvent.CLICK, buttonClicked_Remove, false, 0, true);
            _btnRemoveTask.enabled = false;
            _btnRemoveTask.label = "Remove download";
            _btnRemoveTask.getTextFormatForState(SkinStates.UP).size = 12;
            _btnRemoveTask.getTextFormatForState(SkinStates.DOWN).size = 12;
            _btnRemoveTask.getTextFormatForState(SkinStates.SELECTED).size = 12;
            _btnRemoveTask.getTextFormatForState(SkinStates.DISABLED).size = 12;
            _btnRemoveTask.label_txt.defaultTextFormat = textFormat;
            
            
            _downloadItem.addChild(_downloadItemTitle);
            _downloadItem.addChild(_btnAddTask);
            _downloadItem.addChild(_btnPauseTask);
            _downloadItem.addChild(_btnRemoveTask);
            _downloadItem.addChild(_progressBar);
            
            
            addChild(_downloadItem);
            
        }
        protected override function draw():void 
        {
            super.draw();
            
            if (stage == null) return;
            
            _downloadItem.x = 10;
            _downloadItem.y = height/2;
            _downloadItem.width = width;
            _downloadItem.height = _progressBar.height + 4;
            
            
            _downloadItemTitle.width = 200;
            
            // set each button size to the largest text label size
            var lblwidth:Number = Math.max(_btnAddTask.label_txt.textWidth , _btnPauseTask.label_txt.textWidth ,_btnRemoveTask.label_txt.textWidth) + 2;
            var lblheight:Number = Math.max(_btnAddTask.label_txt.textHeight, _btnPauseTask.label_txt.textHeight,_btnRemoveTask.label_txt.textHeight) + 2;
            
            _btnAddTask.width = lblwidth;
            _btnAddTask.height = lblheight;
            
            _btnPauseTask.width = lblwidth;  
            _btnPauseTask.height = lblheight;  
            
            _btnRemoveTask.width = lblwidth;
            _btnRemoveTask.height = lblheight;
            
            _progressBar.x = width - (_progressBar.width + 10);
            
        }
        
        /**
         * Example call back that is invoked when down completes
         */
        private function downloadSuccess(event:Event):void
        {
            
            // Download complete success
            
            // Delete task from queue so it can be added again for demo
            _mgr.removeTask(_task, true);
            
            //Reset progress bar to give visual clue that download is cancelled
            _progressBar.updateProgressBar(0,0);
            _progressBar.reset();
            
            
            // Reset demo controls 
            //hide and disable Pause/Resume button to prevent user from causing an exception
            _btnAddTask.enabled = true;// Enable add button
            
            // disable control while no active download
            _btnPauseTask.enabled = false;
            
            // disable control while no active download
            _btnRemoveTask.enabled = false;
            
            
            
            // clean up 
            removeEventListener(Event.COMPLETE,downloadSuccess);
            removeEventListener(Event.CHANGE,downloadError);
            
        }
        
        /**
         * Example call back that is invoked when down fails
         */
        private function downloadError(event:Event):void
        {
            
            // Remove is the only operation that makes sense in this state
            _btnAddTask.enabled = false;// Disable add button
            _btnPauseTask.enabled = false; // Disable pause
            _btnRemoveTask.enabled = true; // enable remove
            
            
            _alertDialog = new AlertDialog();
            _alertDialog.addEventListener(Event.SELECT, onDialogDismissed);
            _alertDialog.addButton("close");
            _alertDialog.message = "Download from: " + _task.getRemoteFileURL()+ " completed with error: " + _task.getError().message ;
            _alertDialog.title = "Download complete";
            _alertDialog.show(IowWindow.getAirWindow().group);
            
        }		
        
        /**
         * This is our callback method for TaskProgressEvent events.
         * We will use it to update the progress bar.
         */
        public function taskProgressChanged(event:TaskProgressEvent):void 
        {
            var offset:int = event.task.getCurrentOffset();
            _progressBar.updateProgressBar(offset, event.task.getContentLength());
        }
        
        /**
         * This is our callback method for TaskChangeEvent events.
         * Used to update the progress bar and dispatch event 
         * that will trigger other parts of the app.
         */
        public function taskStatusChanged(event:TaskChangeEvent):void 
        {
            setDownloadState(event.status);            
        }
        
        private function setDownloadState(state:int=-1):void 
        {
            switch (state) {
                case Task.STATUS_PENDING:
                    if (_task){
                        _progressBar.updateProgressBar(_task.getCurrentOffset(), _task.getContentLength());
                    }
                    _progressBar.reset();
                    
                    
                    break;
                
                case Task.STATUS_INITIALIZED:
                    _downloading = true;
                case Task.STATUS_IN_PROGRESS:
                    var offset:int = _task.getCurrentOffset();
                    _progressBar.updateProgressBar(offset, _task.getContentLength());
                    
                    break;
                
                case Task.STATUS_FAILED:
                    
                    
                    dispatchEvent(new Event(Event.CHANGE));
                    
                    break;
                
                case Task.STATUS_CANCELLED:
                case Task.STATUS_AVAILABLE:
                    break;
                
                case Task.STATUS_SUCCEEDED:
                    //Sample of how you would dispatch an event to registered listeners
                    dispatchEvent(new Event(Event.COMPLETE));
                    
                    break;
                
                case Task.STATUS_PAUSED:
                    
                    _progressBar.pause();
                    
                    break;
                
                default:
                    break;
            }
        }
        
        
        private function buttonClicked_Add(event:MouseEvent):void
        {
            
            // Since we're sharing one task ID for this demo, make sure it does not exist
            _mgr.removeAllTasks(true);
            
            var file:File = File.applicationStorageDirectory.resolvePath("DownloadTest.TMP");
            _task = new FileTransferTask(TASK_ID, FILE_TO_DOWNLOAD_URL, file.url, true);
            
            
            // Add listeners to your task to be notified of its changes by the Download Manager
            _task.addEventListener(TaskChangeEvent.TASK_STATUS_CHANGED, taskStatusChanged);
            _task.addEventListener(TaskProgressEvent.TASK_PROGRESS_CHANGED, taskProgressChanged);
            
            
            addEventListener(Event.COMPLETE,downloadSuccess);
            addEventListener(Event.CHANGE,downloadError);
            
            
            _btnAddTask.enabled = false;// Disable add button
            _btnPauseTask.enabled = true; // Enable pause/remove controls
            _btnRemoveTask.enabled = true; // Enable remove
            
            
            // Adding your task to the Download Manager will add it to the task queue.
            // The task will automatically start when the manager reaches it in the queue.
            // If it is the only task in the queue, it will begin immediately.
            _mgr.addTask(_task);
            
            
        }
        
        
        private function buttonClicked_PauseResume(event:MouseEvent):void
        {
            
            if (_downloading){
                //If track is downloading, pause the download and change text on button
                _btnPauseTask.label = "Resume download";
                validate();
                _mgr.pauseTask(_task);
                _downloading = false;
            }else{
                //If track is NOT downloading, resume the download and change text on button
                _btnPauseTask.label = "Pause download";
                validate();
                _mgr.resumeTask(_task);
                _downloading = true;
            }
        }
        
        // The demo app is unusable once this button is clicked because all functionality becomes disabled.
        // You will have to relaunch the app to continue testing.
        private function buttonClicked_Remove(event:MouseEvent):void
        {
            
            //hide and disable Pause/Resume button to prevent user from causing an exception
            _btnAddTask.enabled = true;// Enable add button
            
            // disable control while no active download
            _btnPauseTask.enabled = false;
            
            // disable control while no active download
            _btnRemoveTask.enabled = false;
            
            
            _mgr.removeTask(_task, true);
            
            //Reset progress bar to give visual clue that download is cancelled
            _progressBar.updateProgressBar(0,0);
            _progressBar.reset();
            
        }
        
        /**
         * AlertDialog Call back
         */ 
        private function onDialogDismissed(event:Event):void 
        {
            if (_alertDialog == null) {
                return;
            }
            
            if (event.target.selectedIndex == 0) {
                _alertDialog.cancel();
                _alertDialog = null;
            } 
        }
        
        
        
    }
}