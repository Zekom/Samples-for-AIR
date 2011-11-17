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
    
    public class DefaultWakeupPolicy extends WakeupPolicy
    {
        private var wifiTrigger:WiFiTrigger;
        private var wifiCondition:WiFiCondition;
        private var powerTrigger:BatteryTrigger;
        private var powerLevel:PowerLevelCondition;
        private var powerCharging:PowerChargingCondition;
        private var massStorage:DiskSpaceWakeupCondition;
        private var massStorageTrigger:DiskSpaceWakeupTrigger;
        
        public function DefaultWakeupPolicy()
        {	
            wifiTrigger = new WiFiTrigger(this);
            powerTrigger = new BatteryTrigger(this);
            massStorageTrigger = new DiskSpaceWakeupTrigger(this);
            
            powerLevel = new PowerLevelCondition();
            massStorage = new DiskSpaceWakeupCondition();
            wifiCondition = new WiFiCondition();
            
            this.addWakeupCondition(wifiCondition, false);
            //this.addWakeupCondition(powerLevel, false);
            this.addWakeupCondition(massStorage, false);
            
            this.addWakeupTrigger(wifiTrigger, false);
            //this.addWakeupTrigger(powerTrigger, false);
            //this.addWakeupTrigger(massStorageTrigger, false);
        }
    }
}