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

package samples.ui.components
{
    
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    
    import samples.utils.Fonts;
    import samples.utils.StringUtils;
    import qnx.ui.progress.ProgressBar;
    import qnx.ui.core.Container;
    import qnx.ui.core.ContainerAlign;
    import qnx.ui.core.ContainerFlow;
    import qnx.ui.core.Containment;
    import qnx.ui.core.SizeUnit;
    
    public class DownloadProgress extends Container 
    {
        protected var progressLabel:TextField;
        protected var progressBar:ProgressBar;
        //strings
        private var _pendingString:String;
        private var _waitingString:String;
        private var _pausedString:String;			
        private var _bytesString:String;
        private var _kbString:String;
        private var _mbString:String;
        
        /**
         * Progress bar with text label
         *  
         * @param size - the width of the progress bar
         * @param pendingString - a localized string for "pending download" state
         * @param waitingString - a localized string for "waiting download" state 
         * @param pausedString - a localized string for "paused download" state
         * @param bytesString - a localized string for "bytes", default = "bytes"
         * @param bytesString - a localized string for "KB", default = "KB"
         * @param bytesString - a localized string for "MB", default = "MB"
         */  
        public function DownloadProgress(size:int, pendingString:String, waitingString:String, pausedString:String, bytesString:String = "bytes", kbString:String = "KB", mbString:String = "MB")
        {
            height = 35;
            this.size = width = size;
            
            sizeUnit = SizeUnit.PIXELS;
            
            _pendingString = pendingString;
            _waitingString = waitingString;
            _pausedString = pausedString;			
            _bytesString = bytesString;
            _kbString = kbString;
            _mbString = mbString;
            
            flow = ContainerFlow.VERTICAL;
            align = ContainerAlign.NEAR;
            
            setupProgressLabel(_pendingString);
            setupProgressBar([0x006600, 0x00cc00]);
        }
        
        private function setupProgressBar(colours:Array):void {
           
            if (progressBar) {
                progressBar.progress = 0;
                return;
            }
            
            progressBar = new ProgressBar();
            progressBar.mouseEnabled = false;
            progressBar.mouseChildren = false;
            
            progressBar.containment = Containment.DOCK_BOTTOM;
            addChild(progressBar);
            
            progressBar.setSize(width, 15);
        }
        
        private function setupProgressLabel(stateString:String):void {
            if (progressLabel) {
                progressLabel.text = stateString;
                return;
            }
            
            var textFormat:TextFormat = new TextFormat();
            textFormat.color = 0x464545;
            textFormat.font = Fonts.REGULAR;
            textFormat.size = 16;
            
            progressLabel = new TextField();
            progressLabel.autoSize = TextFieldAutoSize.RIGHT;
            progressLabel.mouseEnabled = false;
            progressLabel.defaultTextFormat = textFormat;
            progressLabel.selectable = false;
            progressLabel.text = stateString;
            
            addChild(progressLabel);
        }
        
        /**
         * Set the text format for the progress label
         * @param format - TextFormat
         */  
        public function set textFormat(format:TextFormat):void 
        {
            progressLabel.defaultTextFormat = format;
        }
        
        protected override function draw():void 
        {
            super.draw();
            progressBar.y = progressLabel.y + progressLabel.height;
            if (progressBar.visible)
                progressLabel.x = width - progressLabel.width; // Right justify
            else
                progressLabel.x = (width - progressLabel.width) / 2; // Center, when the progress bar is hidden
        }
        
        /**
         * Set progress label to waiting string
         */  
        public function reset():void 
        {
            progressLabel.text = _waitingString;
            invalidate();
        }
        
        /**
         * Set progress label to pending string
         */  
        public function start():void 
        {
            progressLabel.text = _pendingString;
            invalidate();
        }
        
        /**
         * Set progress label to paused string
         */  
        public function pause():void 
        {
            progressLabel.text = _pausedString;
            invalidate();
        }
        
        /**
         * Update the progress bar and progress label with download progress values
         * @param currentOffset - progress offset value
         * @param totalLength - progress total length
         */ 
        public function updateProgressBar(currentOffset:Number, totalLength:Number):void
        {
            progressBar.progress = totalLength > 0 ? currentOffset / totalLength : 0;
            progressLabel.text = StringUtils.formatBytes(currentOffset, true, _bytesString, _kbString, _mbString) + "/ " + StringUtils.formatBytes(totalLength, true, _bytesString, _kbString, _mbString);
            invalidate();
            
        }
    }
}