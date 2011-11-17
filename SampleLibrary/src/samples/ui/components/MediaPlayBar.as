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
    import caurina.transitions.Tweener;
    
    import flash.display.Bitmap;
    import flash.display.Sprite;
    import flash.events.ErrorEvent;
    import flash.events.MouseEvent;
    
    import qnx.dialog.AlertDialog;
    import qnx.display.IowWindow;
    import qnx.events.AudioManagerEvent;
    import qnx.events.MediaPlayerEvent;
    import qnx.events.MediaServiceConnectionEvent;
    import qnx.events.MediaServiceRequestEvent;
    import qnx.media.MediaPlayer;
    import qnx.media.MediaPlayerMetadata;
    import qnx.media.MediaPlayerState;
    import qnx.media.MediaServiceConnection;
    import qnx.system.AudioManager;
    import qnx.ui.events.MediaControlEvent;
    import qnx.ui.events.SliderEvent;
    import qnx.ui.media.MediaControlOption;
    import qnx.ui.media.MediaControlState;
    import qnx.ui.progress.ActivityIndicator;
    
    import samples.events.PlayBarEvent;
    
    public class MediaPlayBar extends PlayBar
    {
        
        
        /** Is the playbar currently displayed? */
        private var _displayed:Boolean;
        
        /** An overlay that is shown on the playbar. */
        private var _overlay:Sprite;
        
        /** Displays a progress bar animation while a track is loading. */
        private var _progress:ActivityIndicator;
        
        
        private var _mp:MediaPlayer;
        private var _initializing:Boolean;
        /** The QNX now playing screen that allows easy and quick accessing of the media player controls. */
        private var _mpService:MediaServiceConnection;
        private var _metaData:Object;
        
        public function MediaPlayBar()
        {
            
            super();
            
            _overlay = new Sprite();
            _progress = new ActivityIndicator();
            
            _mpService = new MediaServiceConnection();
            _mpService.addEventListener(MediaServiceConnectionEvent.CONNECT, mediaServiceConnected);
            _mpService.connect();
            
            _metaData = new Object();
            _metaData[MediaPlayerMetadata.DURATION] = 0;
            
            _mp = new MediaPlayer();
            _mp.addEventListener(MediaPlayerEvent.INFO_CHANGE, infoChange);
            _mp.addEventListener(MediaPlayerEvent.PREPARE_COMPLETE, startPlayback);
            _mp.addEventListener(ErrorEvent.ERROR, resetMediaPlayer);
            
            controls.setOptionEnabled(MediaControlOption.NEXT, false);
            controls.setOptionEnabled(MediaControlOption.PREVIOUS, false);
            
            volume.addEventListener(SliderEvent.MOVE, volumeSet);
            
            AudioManager.audioManager.addEventListener(AudioManagerEvent.OUTPUT_LEVEL_CHANGED, handleOutputLevelChange);
            AudioManager.audioManager.addEventListener(AudioManagerEvent.OUTPUT_MUTE_CHANGED, handleOutputLevelChange);
            
            centerBar.album.text = "";
            centerBar.shuffleOff.visible = false;
            centerBar.repeatOff.visible = false;
            centerBar.repeatTrack.visible = false;
            centerBar.repeatAll.visible = false;
            centerBar.nowPlaying.visible = false;
            
            handleOutputLevelChange(null);
        }
        
        
        
        /** @copy #_displayed */
        public function get isDisplayed():Boolean 
        {
            return _displayed;
        }
        
        
        /**
         * Removes the playbar from view.
         */
        public function hide():void 
        {
            _displayed = false;
            hideLoadingOverlay();
            
            Tweener.addTween(this, {y:y + size + SHADOW_HEIGHT, time:0.5});
        }
        
        
        /**
         * Hides the loading progress animation overlay from view.
         */
        public function hideLoadingOverlay():void 
        {
            _overlay.graphics.clear();
            _progress.animate(false);
            if (contains(_overlay)) {
                removeChild(_overlay);
                removeChild(_progress);
            }
        }
        
        
        /**
         * Tweens in the playbar into view.
         */
        public function show():void 
        {
            _displayed = true;
            
            Tweener.addTween(this, {y:y - size, time:0.5});
        }
        
        
        /**
         * Displays the loading progress animation overlay.
         */
        public function showLoadingOverlay():void 
        {
            _overlay.graphics.clear();
            _overlay.graphics.beginFill(0x0, .6);
            _overlay.graphics.drawRect(0, 0, width, height);
            _overlay.graphics.endFill();
            
            _progress.animate(true);
            _progress.setPosition((width - _progress.width)/ 2, (size - _progress.height) / 2); 
            
            if (!contains(_overlay)) {
                addChild(_overlay);
                addChild(_progress );
            }
        }
        
        /**
         * Sets up the event listeners as the media service connection has been established..
         * @param event The event that we are handling. This must be MediaServiceConnectionEvent.CONNECT.
         */
        private function mediaServiceConnected(event:MediaServiceConnectionEvent):void
        {
            _mpService.addEventListener(MediaServiceConnectionEvent.ACCESS_CHANGE, accessChange, false, 0 , true);
            _mpService.addEventListener(MediaServiceRequestEvent.TRACK_PLAY, playPause, false, 0 , true);
            _mpService.addEventListener(MediaServiceRequestEvent.TRACK_PAUSE, playPause, false, 0 , true);
        }
        
        private function accessChange(event:MediaServiceConnectionEvent):void
        {
            if (_mpService.hasAudioService())
            {
                if (_mp.isPaused) { // only resume if we were playing a track but we were interrupted
                    _mp.play();
                    _mpService.sendMetadata(_metaData);
                    controls.setState(MediaControlState.PLAY);
                    _mpService.setPlayState(MediaPlayerState.PLAYING);
                }
            }
            else if (_mp.isPlaying) { // means we are playing a track but lost audio control
                _mp.pause();
                controls.setState(MediaControlState.PAUSE);
                _mpService.setPlayState(MediaPlayerState.PAUSED);
            }
        }
        
        private function playPause(event:MediaServiceRequestEvent):void
        {
            if (_mpService.hasAudioService())
            {
                if (_mp.isPaused) {
                    _mp.play();
                    _mpService.sendMetadata(_metaData);
                    
                } else if (_mp.isPlaying) {
                    _mp.pause();
                    controls.setState(MediaControlState.PAUSE);
                }
                
            } else {
                _mpService.requestAudioService();
            }
        }
        
        protected override function draw():void 
        {
            super.draw();
            _progress.setPosition((width - _progress.width)/ 2, (size - _progress.height) / 2); 
        }
        
        protected override function requestSeek(position:uint):void 
        {
            _mp.seek(position);
        }
        
        private function volumeSet(event:SliderEvent):void 
        {
            AudioManager.audioManager.setOutputLevel(event.target.value);
        }
        
        private function handleOutputLevelChange(event:AudioManagerEvent):void
        {
            volume.value = AudioManager.audioManager.getOutputLevel();
        }
        
        private function infoChange(event:MediaPlayerEvent):void 
        {
            var what:Object = event.what;
            
            if (what)
            {
                if (what.position && _mp.metadata.duration && _mp.isPlaying) {
                    _metaData["position"] = _mp.position;
                    _mpService.sendMetadata(_metaData);
                    hideLoadingOverlay();
                    handlePositionUpdate(_mp.position);
                    
                } else if (what.state && !_mp.isPlaying && !_initializing) {
                    stopPlayback();
                    controls.setState(MediaControlState.STOP);
                    
                } else if (what.speed) {
                    if (_mp.speed == 0) {
                        _mpService.setPlayState(MediaPlayerState.PAUSED);
                        controls.setState(MediaControlState.PAUSE);
                        dispatchEvent(new PlayBarEvent(PlayBarEvent.PAUSE));
                    } else {
                        _mpService.setPlayState(MediaPlayerState.PLAYING);
                        controls.setState(MediaControlState.PLAY);
                    }
                } else if (what.duration) {
                    trackDuration = _mp.metadata.duration;
                    _metaData[MediaPlayerMetadata.DURATION] = _mp.duration;
                    _mpService.sendMetadata(_metaData);
                    _mpService.setPlayState(MediaPlayerState.PLAYING);
                }
            }
        }
        
        private function startPlayback(event:MediaPlayerEvent):void 
        {
            _initializing = false;
            _mp.speed = 1000;
            _mp.play();
        }
        
        public override function stop():void 
        {
            _initializing = false;
            if (_mp.isPlaying)
                _mp.stop();
        }
        
        private function stopPlayback():void 
        {
            dispatchEvent(new PlayBarEvent(PlayBarEvent.STOPPED));
            
            _mpService.setPlayState(MediaPlayerState.STOPPED);
            handlePlayerStopped();
            
            if (centerBar.albumArt.numChildren > 0)
                centerBar.albumArt.removeChildAt(0);
            
            centerBar.album.text = "";
            centerBar.trackName.text = "";
        }
        
        protected override function handleButtonClicked(e:MediaControlEvent):void
        {
            // Resume
            if (e.property == MediaControlState.PLAY) {
                if (_mpService.hasAudioService()) {
                    _mp.play();
                    
                } else {
                    _mpService.requestAudioService();
                }
            }
                // Pause
            else if (e.property == MediaControlState.PAUSE) {
                _mp.pause();
            }
                // Stop
            else if (e.property == MediaControlState.STOP) {
                _mp.stop();
            }
        }
        
        public function initPlayer(event:PlayBarEvent):void 
        {
            stop();
            _mp.reset();
            _initializing = true;
            
            showLoadingOverlay();
            
            // Reset progress bar
            trackDuration = 0;
            handlePlayerStopped();
            
            setMetaData(event.track ? event.track : "", event.album ? event.album : "");
            updateMetaData(event.track, event.album, event.artist, event.thumbnailURL);
            
            controls.setState(MediaControlState.PLAY);
            
            if (event.thumbnail) {
                var bitmap:Bitmap = new Bitmap(event.thumbnail.clone());
                bitmap.width = centerBar.defaultArt.width;
                bitmap.height = centerBar.defaultArt.height;
                
                centerBar.albumArt.addChild(bitmap);
            }
            
            if (!_mpService.hasAudioService())
                _mpService.requestAudioService();
        }
        
        public function playTrack(event:PlayBarEvent):void 
        {
            _mp.url = event.url;
            if (!_mp.isIdle)
                _mp.stop();
            _mp.prepare();
        }
        
        private function updateMetaData(track:String, album:String, artist:String, thumbnailURL:String):void
        {
            _metaData[MediaPlayerMetadata.TRACK] = track;
            _metaData[MediaPlayerMetadata.ALBUM] = album;
            _metaData[MediaPlayerMetadata.ARTIST] = artist;
            if (thumbnailURL)
                _metaData["albumArtwork"] = thumbnailURL;
            
            _mpService.sendMetadata(_metaData);
        }
        
        private function resetMediaPlayer(event:ErrorEvent):void 
        {
            
            var media:String =  _mp.url;
            // Attempt recovering the core media player when an internal error occurs
            stopPlayback();
            _mp.stop();
            _mp.removeEventListener(MediaPlayerEvent.INFO_CHANGE, infoChange);
            _mp.removeEventListener(MediaPlayerEvent.PREPARE_COMPLETE, startPlayback);
            _mp.removeEventListener(ErrorEvent.ERROR, resetMediaPlayer);
            _mp.dispose();
            
            _mp = new MediaPlayer();
            _mp.addEventListener(MediaPlayerEvent.INFO_CHANGE, infoChange);
            _mp.addEventListener(MediaPlayerEvent.PREPARE_COMPLETE, startPlayback);
            _mp.addEventListener(ErrorEvent.ERROR, resetMediaPlayer);
            
            
            //prompt user that track is not available at this time
            var alert:AlertDialog = new AlertDialog();
            alert.title = "Warn";
            alert.addButton("Ok");
            alert.message = "Unable to play media: " +  media;
            alert.show(IowWindow.getAirWindow().group);
            
        }
        
        
    }
    
    
}