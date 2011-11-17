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
    import flash.display.Stage;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import flash.utils.Timer;
    
    import qnx.ui.buttons.LabelButton;
    import qnx.ui.core.Container;
    import qnx.ui.core.Containment;
    import qnx.ui.skins.SkinStates;
    import qnx.ui.theme.ThemeGlobals;
    
    import samples.events.PlayBarEvent;
    import samples.ui.components.MediaPlayBar;
    import samples.ui.components.PlayBar;
    
    
    /**
     * Example class that demonstrates how to create and control 
     *  an the inline media control bar, which slides in and out of view.
     * 
     */  
    public class SampleViewMediaPlayBar  extends SampleView
    {
        
        
        // SET URL TO PREVIEW FROM HERE Before running application
        private var FILE_TO_PREVIEW_URL:String  = "http://replace_with_valid_path_or_url.com";
        
        
        // Media Playbar
        private var _playBar:MediaPlayBar;
        
        // Button used to show and hide the media playbar
        private var _showHidePlayerButton:LabelButton;
        
        
        public function SampleViewMediaPlayBar()
        {
            super();
            
        }

        override protected function init():void
        {
            super.init();// ensure titleContainer is initialized.

            setTitleText("Media Playbar Sample");
            
            var textFormat:TextFormat = ThemeGlobals.getTextFormat(ThemeGlobals.CELL_FORMAT_SELECTED);
            textFormat.color = 0x00000;
            textFormat.align = TextFormatAlign.CENTER;
            textFormat.bold = false;
            
            
            // Button used to show and hide the media playbar
            _showHidePlayerButton = new LabelButton();
            _showHidePlayerButton.setTextFormatForState(textFormat, SkinStates.UP);
            _showHidePlayerButton.setTextFormatForState(textFormat, SkinStates.DOWN);
            _showHidePlayerButton.setTextFormatForState(textFormat, SkinStates.SELECTED);
            _showHidePlayerButton.setTextFormatForState(textFormat, SkinStates.DISABLED);
            _showHidePlayerButton.width = 300;// give it some width to fit the label text 
            _showHidePlayerButton.label = "Show/Hide Media Playbar";
            _showHidePlayerButton.addEventListener(MouseEvent.CLICK, onShowHideButtonPressed, false, 0, true);
            
            addChild(_showHidePlayerButton);
            
            
            
            _playBar = new MediaPlayBar();
            _playBar.containment = Containment.UNCONTAINED;
            
            addEventListener(PlayBarEvent.INIT, playBarHandler);
            addEventListener(PlayBarEvent.START, playBarHandler);
            addEventListener(PlayBarEvent.STOP, playBarHandler);
            addEventListener(PlayBarEvent.STOPPED, playBarHandler);
            addEventListener(PlayBarEvent.PAUSE, playBarHandler);
            
            addChild(_playBar);

        }
 
        protected override function onAdded():void
        {
            _playBar.setPosition(0, stage.stageHeight + y); // Init the playbar hidden
        }
        
        private function onShowHideButtonPressed(event:MouseEvent):void{
            
            
            if (_playBar.isDisplayed){
                
                dispatchEvent(new PlayBarEvent(PlayBarEvent.STOP));
            }else{
                
                
                // Send an event to initialize the player
                // This information will appear in the media player 
                var initEvent:PlayBarEvent = new PlayBarEvent(PlayBarEvent.INIT);
                initEvent.album  = "This is an album title";
                initEvent.track  = "This is a track title";
                initEvent.artist = "This is an artist name";
                
                // Initialize the player 
                dispatchEvent(initEvent);
                
                
                var startEvent:PlayBarEvent = new PlayBarEvent(PlayBarEvent.START);
                // Update this path to use
                startEvent.url = FILE_TO_PREVIEW_URL;
                
                // Start playback  
                dispatchEvent(startEvent);
                
            }
        }

        protected override function onRemoved():void
        {
            super.onRemoved();
            
            // This is how you stop the player....
            var stopEvent:PlayBarEvent = new PlayBarEvent(PlayBarEvent.STOP);
            dispatchEvent(stopEvent);
            
        }		
        private function resize(event:Event):void 
        {
            setSize(stage.stageWidth, stage.stageHeight);
            _playBar.setSize(stage.stageWidth, stage.stageHeight);
        }
        
        
        
        private function playBarHandler(event:PlayBarEvent):void 
        {
            switch (event.type) {
                case PlayBarEvent.INIT:
                    if (!_playBar.isDisplayed) 
                    {
                        _playBar.setPosition(0, height);
                        _playBar.initPlayer (event);// Initialize the player
                        _playBar.show();
                    }
                    break;
                
                case PlayBarEvent.START:
                    if (!_playBar.isDisplayed) 
                    {
                        _playBar.setPosition(0, height);
                        _playBar.show();
                    }
                    
                    // Set a file path or URL of a song  
                    if (event.url != null) {
                        _playBar.playTrack(event); // begin playback
                        
                    }
                    break;
                
                case PlayBarEvent.PAUSE:
                    break;
                
                case PlayBarEvent.STOPPED:
                case PlayBarEvent.STOP:
                    if (_playBar.isDisplayed) {
                        _playBar.stop();
                        _playBar.hide();
                    }
                    break;
            }
        }
        
        
    }
}