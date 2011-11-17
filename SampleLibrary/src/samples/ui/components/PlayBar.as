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
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import assets.ControlBar;
    import samples.utils.EllipsisUtil;
    import qnx.utils.TimeFormatter;
    
    import qnx.events.AudioManagerEvent;
    
    import qnx.system.AudioManager;
    import qnx.system.AudioOutput;
    import qnx.ui.core.*;
    import qnx.ui.events.MediaControlEvent;
    import qnx.ui.media.*;
    import qnx.ui.slider.VolumeSlider;
    
    
    /**
     * The PlayBar class handles nearly all the work that is required to manipulate the play bar
     * that is located on the bottom of the screen. This component has the ability to be dismissed,
     * or expanded as necessary. It registers itself with the media player to listen to state changes
     * that occur with the player to be able to update the UI. In addition, it allows the user to
     * manipulate the player model using the buttons in this UI.<br>
     * <br>
     * The current track that is being played is reflected in the list, and as soon as the track
     * changes the list scrolls to update itself. We always try to keep the currently playing track
     * centered in the list. If the user scrolls the list and leaves it idle for 5 seconds, the
     * list scrolls back the focus to the currently playing track.<br>
     * <br>
     * The play bar is composed of several parts. The control buttons manipulate playback are on
     * the left, and there is a information bar to display the currently playing track's artwork,
     * total duration, and current progress. On this information bar there also exists buttons to
     * manipulate the player's playlist state such as changing the repeat mode and turning the
     * shuffle mode on or off. Finally, there also exists a volume slider which can be used to
     * change the player's volume.
     *
     */
    public class PlayBar extends UIComponent
    {
        /** The height of this component when it is in landscape mode and in the <code>PlayBar.STATE_REDUCED</code> state. */
        public static const REDUCED_SIZE_LANDSCAPE:Number = 70;
        
        /** The height of this component when it is in portrait mode and in the <code>PlayBar.STATE_REDUCED</code> state. */
        public static const REDUCED_SIZE_PORTRAIT:Number = 147;
        
        /** The height of the shadow associated with this component. */
        public static const SHADOW_HEIGHT:Number = 15;
        
        /** The height of the Flash skin. Needed due a bug with AIR SDK where an invalid <code>_component.height</code> value is returned. */
        private static var componentHeight:Number;
        
        /** The Flash skin we are rendering. */
        private var _component:ControlBar;
        
        /** The media control buttons. */
        private var _controls:MediaControl;
        
        /** The initial progress bar width from the .fla file. This is used to determine what is the maximum width we can expand the progess bar to. */
        private var _initialProgressWidth:Number;
        
        /** Has the clicked down and is currently dragging the scrubber to be in the process of seeking? */
        private var _seeking:Boolean;
        
        /** The total duration of the current track playing. This is retained to constantly be fed into the information bar. */
        private var _trackDuration:uint;
        
        /** Volume control scrubber. */
        private var _volume:VolumeSlider;
        
        
        /**
         * Creates an instance of PlayBar so that the component can be used in an application.
         */
        public function PlayBar()
        {
            _component = new ControlBar();
            componentHeight = _component.height;
            
            _component.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
                event.stopPropagation();
            });
            
            _component.addEventListener(MouseEvent.MOUSE_DOWN, function(event:MouseEvent):void {
                event.stopPropagation();
            });
            
            _initialProgressWidth = _component.centerBar.progress.width;
            
            addChild(_component);
            
            _controls = new MediaControl();
            _controls.setOption(MediaControlOption.PLAY_PAUSE, true);
            _controls.setOption(MediaControlOption.NEXT, true);
            _controls.setOption(MediaControlOption.PREVIOUS, true);
            _controls.setOption(MediaControlOption.STOP, true);
            _controls.setOption(MediaControlOption.DURATION, true);
            _controls.setOption(MediaControlOption.BACKGROUND, false);
            addChild(_controls);
            
            _component.centerBar.album.text = "No track loaded";
            _component.centerBar.trackName.text = "";
            _component.centerBar.seeker.addEventListener(MouseEvent.MOUSE_DOWN, seekerClicked);
            _component.centerBar.shuffleOn.visible = _component.centerBar.repeatTrack.visible = _component.centerBar.repeatAll.visible = false;
            
            _volume = new VolumeSlider();
            _component.volume.addChild(_volume);
            
            super();
            
            sizeUnit = SizeUnit.PIXELS;
            sizeMode = SizeMode.BOTH;
            containment = Containment.BACKGROUND;
            
            _seeking = false;
            
            handlePlayerStopped();
            
            //set audio boost state and also handle audio boost state change event
            _volume.audioBoostEnabled = AudioManager.audioManager.audioBoostEnabled;
            _volume.maximum = AudioManager.audioManager.getMaxOutputLevel();
            AudioManager.audioManager.addEventListener(AudioManagerEvent.HP_BOOST_CHANGED, function(e:AudioManagerEvent):void {
                _volume.audioBoostEnabled = AudioManager.audioManager.audioBoostEnabled;
                _volume.maximum = AudioManager.audioManager.getMaxOutputLevel();
            });
            
            // disable volume slider for music app when HDMI or A2DP is the connected output because volume slider
            // will not be functional in these two cases. However, we should revisit this logic for A2DP when AVRCP 1.4 is
            // supported since the volume slider can be used for control BT volume using the protocol
            var audioManager:AudioManager = AudioManager.audioManager;
            _volume.active = audioManager.connectedOutput != AudioOutput.HDMI && audioManager.connectedOutput != AudioOutput.A2DP;
            
            audioManager.addEventListener(AudioManagerEvent.CONNECTED_OUTPUT_CHANGED, function(event:AudioManagerEvent):void {
                _volume.active = audioManager.connectedOutput != AudioOutput.HDMI && audioManager.connectedOutput != AudioOutput.A2DP;
            });
        }
        
        
        /** The center bar where all the track information is loaded. */
        protected function get centerBar():MovieClip
        {
            return _component.centerBar;
        }
        
        
        /** @copy #_controls */
        protected function get controls():MediaControl
        {
            return _controls;
        }
        
        
        /** The container of the now playing slider area. */
        protected function get nowPlayingBar():DisplayObjectContainer
        {
            return _component.nowPlayingBar;
        }
        
        
        /** @copy #_volume */
        protected function get volume():VolumeSlider
        {
            return _volume;
        }
        
        
        /**
         * Adjusts the layout according to the current orientation.
         */
        override protected function draw():void
        {
            if (width > 0 && height > 0)
            {
                var landscape:Boolean = stage.stageWidth > stage.stageHeight;
                
                _component.centerBar.y = 6;
                _component.centerBar.trackName.width = _component.centerBar.album.width = _component.centerBar.currentTime.x-_component.centerBar.trackName.x-5;
                
                if (landscape)
                {
                    size = REDUCED_SIZE_LANDSCAPE;
                    
                    _controls.x = 12;
                    _controls.y = 0;
                    _component.background.portrait.visible = false;
                    _component.background.landscape.visible = true;
                    _component.volume.x = width-_volume.width-18;
                    _component.volume.y = (_component.centerBar.y+_component.centerBar.height-_volume.height)/2;
                    _component.nowPlayingBar.y = 0.28966*componentHeight;
                    _component.centerBar.x = _component.volume.x-_component.centerBar.width-15;
                }
                    
                else
                {
                    size = REDUCED_SIZE_PORTRAIT;
                    
                    _controls.x = 30;
                    _component.background.portrait.visible = true;
                    _component.background.landscape.visible = false;
                    _controls.y = _component.centerBar.y+_component.centerBar.height;
                    _component.volume.x = width-_volume.width-48;
                    _component.volume.y = 0.3034*componentHeight;
                    _component.nowPlayingBar.y = 0.5345*componentHeight;
                    _component.centerBar.x = 45;
                }
            }
        }
        
        /**
         * Callback when a control button was clicked. This should be overriden by all subclasses.
         * @param e Query the <code>property</code> of this event to determine which button was clicked.
         * This will be one of <code>MediaControlState.PLAY</code>, <code>MediaControlState.STOP</code>,
         * <code>MediaControlState.PAUSE</code>, <code>MediaControlOption.PREVIOUS</code>, or <code>MediaControlOption.NEXT</code>.
         */
        protected function handleButtonClicked(e:MediaControlEvent):void
        {
        }
        
        
        /**
         * Callback to handle what to do when the player has stopped. We reset our progress bar to
         * be in the beginning, we set the play button to be visible and the pause button to be
         * invisible, we reset the current track information and we tween this component to the
         * dismissed state.
         * @param e The event associated with this stop. This value is ignored and exists only so
         * this method does not need to be delegated.
         */
        protected function handlePlayerStopped(e:Event=null):void
        {
            _component.centerBar.progress.width = 0;
            _controls.setState(MediaControlState.STOP);
            
            updateTime(0,0);
        }
        
        
        /**
         * Handles a current track position update from the media player. If the previous button is
         * faded out and we pass 3 seconds, we fade the previous button back in. We update both the
         * progress bar as well as the information bar in this method.
         * @param e The event associated with the position update. The data is used to determine the
         * current position.
         */
        protected function handlePositionUpdate(e:uint): void
        {
            if (!_seeking)
            {
                _component.centerBar.progress.width = _trackDuration > 0 ? Math.min( _initialProgressWidth, (e*_initialProgressWidth)/_trackDuration ) : 0;
                updateTime(e, _trackDuration);
            }
        }
        
        
        /**
         * Enables the rewind button on the play bar.
         * @param event This value is ignored.
         */
        protected function handleRewindEnabled(event:Event=null):void
        {
            if ( !_controls.getOptionEnabled(MediaControlOption.PREVIOUS) ) {
                _controls.setOptionEnabled(MediaControlOption.PREVIOUS, true);
            }
        }
        
        
        /**
         * Registers this component to listen for events from its sub-components and controls the
         * initial visibilities of some of its buttons.
         */
        override protected function onAdded():void
        {
            _controls.addEventListener(MediaControlEvent.OPTION_CLICK, handleButtonClicked);
            _controls.addEventListener(MediaControlEvent.STATE_CHANGE, handleButtonClicked);
            stage.addEventListener(MouseEvent.MOUSE_UP, seekerReleased);
            
            super.onAdded();
        }
        
        
        /**
         * Unregisters this component to listen for events from its sub-components.
         */
        override protected function onRemoved():void
        {
            _controls.removeEventListener(MediaControlEvent.OPTION_CLICK, handleButtonClicked);
            _controls.removeEventListener(MediaControlEvent.STATE_CHANGE, handleButtonClicked);
            stage.removeEventListener(MouseEvent.MOUSE_UP, seekerReleased);
            
            super.onRemoved();
        }
        
        
        /**
         * This <b>abstract</b> method should be overridden to tell the player model to seek to the
         * specified position.
         * @param position The position to seek to in milliseconds.
         */
        protected function requestSeek(position:uint):void
        {
        }
        
        
        /**
         * Callback when the user attempts to seek the current track to a specific position. We attach
         * ourself to listen to mouse movements so we can update the progress bar smoothly to reflect
         * on the current position of the user's finger.
         * @param m The mouse event associated with this click. This value is ignored.
         */
        protected function seekerClicked(m:MouseEvent): void
        {
            if (!_seeking)
            {
                stage.addEventListener(MouseEvent.MOUSE_MOVE, seekerMoved);
                _seeking = true;
            }
        }
        
        
        /**
         * Updates the metadata of the track in the center bar. Adds the ellipsis as necessary.
         * @param title The title of the track.
         * @param album The album associated with the media.
         */
        protected function setMetaData(title:String, album:String):void
        {
            _component.centerBar.album.text = album;
            _component.centerBar.trackName.text = title;
            
            EllipsisUtil.truncate(_component.centerBar.album, _component.centerBar.trackName);
        }
        
        
        /** @copy #_trackDuration */
        protected function set trackDuration(value:uint):void
        {
            if (value != _trackDuration)
            {
                _trackDuration = value;
                updateTime(0, value);
            }
        }
        
        
        /**
         * Gets the adjusted local X value of the user's finger.
         * @param m The event associated with the user's touch movement.
         * @return The relative local x-coordinate of the area the user has touched.
         */
        private function getLocalX(m:MouseEvent):Number
        {
            var localX:Number = 0;
            var gap:Number = _component.centerBar.progress.x+_component.centerBar.x;
            
            if (m.stageX > gap+_initialProgressWidth) {
                localX = _initialProgressWidth;
            }
                
            else if (m.stageX < gap) {
                localX = 0;
            }
                
            else {
                localX = m.stageX-_component.centerBar.x-_component.centerBar.seeker.x;
            }
            
            return localX;
        }
        
        
        /**
         * Callback when the user is in the middle of seeking the current track to a specific position. We update
         * the progress bar to reflect on the current position of the user's finger. If the user
         * moves below the minimum region of the progress bar or past the maximum region, we simply
         * expand the progress bar to the beginning or at the end respectively. We also reflect the
         * current track position they are potentially seeking to in the information bar.
         * @param m The mouse event associated with this click. This object is used to extract the local X
         * and stageX coordinates to know exactly where to seek.
         */
        private function seekerMoved(m:MouseEvent): void
        {
            _component.centerBar.progress.width = getLocalX(m);
            updateTime( (getLocalX(m)*_trackDuration)/_initialProgressWidth, _trackDuration );
            
            m.updateAfterEvent();
        }
        
        
        /**
         * Callback when the user finishes seeking the current track to a specific position. We remove
         * ourself from listening to mouse movements, and we request the media player to seek to the
         * specific position. If the user releases the mouse below the minimum region of the progress bar,
         * we simply seek back to the beginning.
         * @param m The mouse event associated with this click release. This object is used to extract the local X
         * and stageX coordinates to know exactly where to seek.
         */
        private function seekerReleased(m:MouseEvent): void
        {
            if (_seeking)
            {
                stage.removeEventListener(MouseEvent.MOUSE_MOVE, seekerMoved);
                
                requestSeek( ( getLocalX(m)*_trackDuration)/_initialProgressWidth );
                _seeking = false;
            }
        }
        
        
        /**
         * Updates the time information on the playbar.
         * @param current The currently elapsed time.
         * @param duration The total duration of the current track.
         */
        private function updateTime(current:uint, duration:uint):void
        {
            _component.centerBar.currentTime.text = TimeFormatter.formatMilliseconds(current)+" / "+TimeFormatter.formatMilliseconds(duration);
        }
    }
}