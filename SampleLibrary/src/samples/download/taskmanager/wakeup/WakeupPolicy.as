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
package samples.download.taskmanager.wakeup
{
    
    import samples.download.taskmanager.GlobalConstants;
    import samples.download.taskmanager.TaskError;
    import samples.download.taskmanager.TaskQueue;
    
    public class WakeupPolicy extends GlobalConstants
    {
        
        private var queue:TaskQueue;
        private var wakeupConditions:Vector.<WakeupCondition>;
        private var wakeupTriggers:Vector.<WakeupTrigger>;
        
        private var wakeupPolicyEnabled:Boolean = false;
        
        private const instancecount:int = 0
        
        public function WakeupPolicy() 
        {
            wakeupConditions = new Vector.<WakeupCondition>();
            wakeupTriggers = new Vector.<WakeupTrigger>();
        }
        
        public function register(queue:TaskQueue):void
        {
            this.queue = queue;
        }
        
        public function unRegister():void
        {
            this.queue = null;
            
            var len:int = wakeupTriggers.length;
            for each (var trigger:WakeupTrigger in wakeupTriggers)
            {
                trigger.deactivate();
            }
        }
        
        public function isWakeupPolicyEnabled():Boolean
        {
            return wakeupPolicyEnabled;
        }
        
        public function setWakeupPolicyEnabled(enabled:Boolean):void
        {
            if (this.wakeupPolicyEnabled == enabled) return;
            this.wakeupPolicyEnabled = enabled;
            
            for each (var trigger:WakeupTrigger in wakeupTriggers)
            {
                if (enabled)
                    trigger.activate();
                else
                    trigger.deactivate();
                
            }
            
            this.checkConditions();
        }
        
        public function getQueue():TaskQueue
        {
            return queue;
        }
        
        public function checkConditions():void
        {
            var queue:TaskQueue = getQueue();
            if (queue == null) return;
            
            //if (!queue.isInRunnableState()) return;        
            
            doCheckCondition();
        }
        
        private function doCheckCondition():void
        {
            trace("Checking Wakeup Policy..");
            
            if (!wakeupPolicyEnabled)
            {
                queue.sleep(WAKEUP_POLICY_DISABLED);
            }
            else
            {                
                var code:int = validateWakeupConditions();
                if (code == OK || code == GlobalConstants.NO_CONDITION)
                {
                    queue.wakeup(true);
                }
                else
                {
                    queue.sleep(code);
                }
            }        
        }
        
        protected function validateWakeupConditions():int
        {
            if (!wakeupPolicyEnabled) return WAKEUP_POLICY_DISABLED;
            
            if (wakeupConditions.length < 1) return NO_CONDITION;
            
            var code:int = OK;
            
            for each (var condition:WakeupCondition in wakeupConditions)
            {
                if ((code = condition.validateCondition()) != OK)
                {
                    break;
                }
            }
            return code;
        }
        
        public function handleException(exception:Error):void
        {
            if (exception is TaskError && (TaskError(exception)).isFatal())
            {
                if (queue != null)
                {
                    queue.sleep((TaskError(exception)).getCause());
                }
            }
            else
            {
                checkConditions(); 
            }
        }   
        
        public function addWakeupCondition(condition:WakeupCondition, triggerValidation:Boolean):void
        {
            if (condition == null || wakeupConditions.indexOf(condition) != -1) return;
            wakeupConditions.push(condition);
            if (triggerValidation) checkConditions();
        }
        
        public function removeWakeupCondition(condition:WakeupCondition, triggerValidation:Boolean):void
        {
            if (condition == null) return;
            var index:int = wakeupConditions.indexOf(condition); 
            if (index == -1) return;
            wakeupConditions.splice(index, 1);
            if (triggerValidation) checkConditions();
        }
        
        public function addWakeupTrigger(trigger:WakeupTrigger, activate:Boolean):void
        {
            if (trigger == null || wakeupTriggers.indexOf(trigger) != -1) return;
            wakeupTriggers.push(trigger);
            if (activate) trigger.activate();
        }
        
        public function removeWakeupTrigger(trigger:WakeupTrigger, deactivate:Boolean):void
        {
            if (trigger == null) return;
            var index:int = wakeupTriggers.indexOf(trigger); 
            if (index == -1) return;
            wakeupTriggers.splice(index, 1);
            if (deactivate) trigger.deactivate();       
        }
    }	
}