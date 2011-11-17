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

package samples.download.taskmanager.utils
{
    import flash.utils.getTimer;
    
    public class ProgressHandle
    {
        public static const DEFAULT_MINIMUM_CALLBACK_INTERVAL:int = 200;
        
        public static const HALF_SECOND:int = 500;//half second
        public static const ONE_SECOND:int = 1000;//1 second
        
        private const ONE_MB:Number = 1024*1024; //1MB
        
        private var callback:ProgressCallback;
        private var length:Number = 0;
        private var position:Number = 0;   
        
        private var timeStarted:int = -1;
        private var timeEnded:int = -1;
        
        private var progressSpeedSampleTimeStarted:int = -1;
        private var progressSpeedSampleStartPosition:int = 0;
        
        private var lastCallbackTime:int = 0;
        private var minimumCallbackInterval:int = DEFAULT_MINIMUM_CALLBACK_INTERVAL;
        
        public function ProgressHandle()
        {
        }
        
        public function reset():void
        {
            length = 0;
            position = 0;
            timeStarted = -1; 
            timeEnded = -1;
            resetProgressSpeedSampling();	
        }
        
        public function resetProgressSpeedSampling():void
        {
            progressSpeedSampleTimeStarted = -1;
            progressSpeedSampleStartPosition = 0;
        }
        
        public function initializeProgressSpeedSampling():void
        {
            progressSpeedSampleTimeStarted = flash.utils.getTimer();
            progressSpeedSampleStartPosition = position;
        }
        
        public function getLength():Number
        {
            return length;
        }
        
        public function setLength(length:Number):void
        {
            setLengthAndFireEvent(length, true);
        }
        
        public function setLengthAndFireEvent(length:Number, fireEvent:Boolean):void
        {
            if (this.length != length)
            {
                this.length = length;
                if (fireEvent) 
                {
                    notifyListener();
                }
            }       
        }
        
        public function getPosition():Number
        {
            return position;
        }
        
        public function advancePosition(amount:Number):void
        {
            advancePositionAndFireEvent(amount, true);
        }
        
        public function advancePositionAndFireEvent(amount:Number, fireEvent:Boolean):void
        {
            if (timeStarted == -1) 
            {
                timeStarted = flash.utils.getTimer();
            }
            
            if (progressSpeedSampleTimeStarted == -1 || progressSpeedSampleStartPosition > position)
            {
                initializeProgressSpeedSampling();
            }        
            
            if (amount > 0)
            {
                if (callback != null)
                {
                    var oldValue:int = getProgress();
                    position += amount;
                    var newValue:int = getProgress();
                    if (needToFireProgressEvent(oldValue != newValue))
                    {
                        //small files <= 1GB will update progress by percent.
                        //large files bigger than 1GB need more frequent progress update (every 200 ms)
                        if (fireEvent) notifyListener();
                    }
                }
                else
                {
                    position += amount;
                }           
            }
            
            if (isComplete())
            {
                timeEnded = flash.utils.getTimer();
            }
        }
        
        protected function needToFireProgressEvent(changedByPercents:Boolean):Boolean
        {
            var needToFire:Boolean = false;
            
            if(length <= 10*ONE_MB) //For small file < 10MB
            {
                //we fire the event by 200ms (@see notifyListener()) and percents.
                if(changedByPercents) 
                {
                    needToFire = true;					
                }
            } 
            else //For big file of size > 10MB
            {				
                if(position <= ONE_MB) 
                {
                    //we will give more update frequently( fire event every 200ms)at first 1MB download
                    needToFire = true;
                }
                else if (position > ONE_MB && position <= 10* ONE_MB) 
                {
                    //For download reaching from 1MB to 10MB, we fire the event by 200ms (@see notifyListener()) and percents.
                    if(HALF_SECOND <= (flash.utils.getTimer() - lastCallbackTime)) 
                    {
                        needToFire = true;					
                    }
                }
                else 
                {
                    //For download reaching 10MB and above, we fire the event by 1 second (@see notifyListener()) and percents.
                    if(ONE_SECOND <= (flash.utils.getTimer() - lastCallbackTime)) 
                    {
                        needToFire = true;					
                    }
                }
            }
            
            return needToFire;
        }
        
        public function setPosition(position:Number):void
        {
            setPositionAndFireEvent(position, true);
        }
        
        public function setPositionAndFireEvent(position:Number, fireEvent:Boolean):void
        {
            if (timeStarted == -1) 
            {
                timeStarted = flash.utils.getTimer();
            }
            
            if (progressSpeedSampleTimeStarted == -1 || progressSpeedSampleStartPosition > position)
            {
                initializeProgressSpeedSampling();
            }        
            
            if (this.position != position)
            {
                this.position = position;
                if (fireEvent) notifyListener();
            }
            
            if (isComplete())
            {
                timeEnded = flash.utils.getTimer();
            }
        }
        
        protected function notifyListener():void
        {
            if (callback != null)
            {            
                if (isComplete() || lastCallbackTime == 0
                    || minimumCallbackInterval <= (flash.utils.getTimer() - lastCallbackTime))
                {
                    callback.progressChanged(this);
                    lastCallbackTime = flash.utils.getTimer();
                }
            }        
        }
        
        public function getProgress():int
        {
            if (length <= 0 || position <= 0) return 0;
            return (int) (( Number(position) / Number(length) ) * 100.0);
        }
        
        public function isComplete():Boolean
        {
            return (getProgress() == 100);
        }
        
        public function getTimeStarted():int
        {
            return timeStarted;
        }
        
        public function getTimeEnded():int
        {
            return timeEnded;
        }
        
        /**
         * @return elapsed time in millis.
         */
        public function getElapsedTime():int
        {
            if (timeStarted < 0)
            {
                return 0;
            }
            else if (timeEnded < 0)
            {
                return flash.utils.getTimer() - timeStarted;
            }
            else
            {
                return timeEnded - timeStarted;
            }
        }
        
        /**
         * @return estimated time remaining in millis. -1 for unknown
         */
        public function getEstimatedTimeRemaining():int
        {
            if (length <= 0 || position <= 0) return -1;
            if (timeStarted <= 0) return -1;
            if (position == length) return 0;
            if (timeEnded > 0) return 0;
            
            if (progressSpeedSampleTimeStarted == -1 || progressSpeedSampleStartPosition > position)
            {
                initializeProgressSpeedSampling();
                return -1;
            }        
            
            var sampleTime:int = flash.utils.getTimer() - progressSpeedSampleTimeStarted;
            if (sampleTime < 0)
            {
                initializeProgressSpeedSampling();
                return -1;
            }
            
            var remaining:Number = (length - position);        
            return int(( Number(remaining) / Number(position - progressSpeedSampleStartPosition)) * sampleTime);        
        }
        
        public function getMinimumCallbackInterval():int
        {
            return minimumCallbackInterval;
        }
        
        public function setMinimumCallbackInterval(minimumCallbackInterval:int):void
        {
            this.minimumCallbackInterval = minimumCallbackInterval;
        }
        
        public function getCallback():ProgressCallback
        {
            return callback;
        }
        
        public function setCallback(callback:ProgressCallback):void
        {
            this.callback = callback;
        } 		
    }
}