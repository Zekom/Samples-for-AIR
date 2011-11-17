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
    
    import flash.errors.IllegalOperationError;
    import flash.events.Event;
    
    public class WakeupTriggerBase implements WakeupTrigger
    {
        
        private var policy:WakeupPolicy;
        
        public function WakeupTriggerBase(policy:WakeupPolicy)
        {
            this.policy = policy;
        }
        
        public function trigger(event:Event):void
        {
            if (policy != null)
            {
                policy.checkConditions();
            }
        }
        
        public function getPolicy():WakeupPolicy 
        {
            return policy;
        }
        
        public function setPolicy(policy:WakeupPolicy):void
        {
            this.policy = policy;
        }
        
        public function activate():void
        {
            throw new IllegalOperationError("Abstract method: must be overridden in a subclass");
        }
        
        public function deactivate():void
        {
            throw new IllegalOperationError("Abstract method: must be overridden in a subclass");
        }
    }
}