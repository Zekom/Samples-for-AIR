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
    import flash.net.NetworkInfo;
    import flash.net.NetworkInterface;
    
    import samples.download.taskmanager.GlobalConstants;
    
    public class WiFiCondition extends WakeupConditionBase
    {	
        public override function validateCondition():int
        {
            var _hasNetworkConnection:Boolean = true;
            
            if(NetworkInfo.isSupported)
            {
                var nInfo:NetworkInfo = NetworkInfo.networkInfo;
                var nInterfaces:Vector.<NetworkInterface> = nInfo.findInterfaces();
                
                _hasNetworkConnection = false;
                
                for each(var nInterface:NetworkInterface in nInterfaces)
                {
                    if(nInterface.active && !isUSBConnection(nInterface))
                    {
                        _hasNetworkConnection = true;
                        break;
                    }
                }
            }
            
            return _hasNetworkConnection ? GlobalConstants.OK : GlobalConstants.WIFI_DISCONNECTED;
        }
        
        private function isUSBConnection(nInterface:NetworkInterface):Boolean
        {
            var isUSB:Boolean = false;
            switch (nInterface.displayName)
            {
                case "asix0":
                case "rndis0":
                case "ecm0":
                    isUSB = true;
                    //This is USB
                    break;
                case "ti0"://This is WiFi
                case "ppp0"://This is tethering
                default: //Unknown interface
                    isUSB = false;
                    break;
            }
            
            return isUSB;
        }
    }
}