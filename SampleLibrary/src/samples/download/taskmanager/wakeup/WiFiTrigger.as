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
    import flash.desktop.NativeApplication;
    import flash.events.Event;
    
    import samples.download.taskmanager.GlobalConstants;
    
    //import qnx.wifi.WifiStatus;
    //import qnx.wifi.events.WifiStatusEvent;
    
    public class WiFiTrigger extends WakeupTriggerBase
    {
        public function WiFiTrigger(policy:WakeupPolicy)
        {
            super(policy);
        }
        
        public override function activate():void
        {
            /*WifiStatus.getInstance().addEventListener(WifiStatusEvent.CONNECTED, trigger);
            WifiStatus.getInstance().addEventListener(WifiStatusEvent.DISCONNECTED, trigger);*/
            
            NativeApplication.nativeApplication.addEventListener(Event.NETWORK_CHANGE, trigger, false, 0, true);
        }
        
        public override function deactivate():void
        {
            /*WifiStatus.getInstance().removeEventListener(WifiStatusEvent.CONNECTED, trigger);
            WifiStatus.getInstance().removeEventListener(WifiStatusEvent.DISCONNECTED, trigger);*/
            
            NativeApplication.nativeApplication.removeEventListener(Event.NETWORK_CHANGE, trigger);
        }
    }
}