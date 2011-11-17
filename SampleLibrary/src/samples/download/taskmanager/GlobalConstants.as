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
package samples.download.taskmanager
{
    public class GlobalConstants
    {
        //General
        public static const OK:int = 0;
        public static const USER_SUSPENDED:int = 2;
        public static const INTERNAL_ERROR:int = 3;
        public static const FILE_IO_ERROR:int = 4;
        
        
        // wakeup policy    
        public static const NO_CONDITION:int = 10;
        public static const WAKEUP_POLICY_DISABLED:int = 11;
        
        // default wakeup policy
        public static const WIFI_DISCONNECTED:int = 100;
        public static const NO_SDCARD:int = 110;
        public static const MEMORY_FULL:int = 111;
        public static const MEMORY_ERROR:int = 112;
        public static const LOW_BATTERY:int = 120;
        public static const NOT_CHARGING:int = 121;
        public static const OUT_OF_COVERAGE:int = 140;
        
        // http FileDownload
        public static const DEFAULT_CAUSE:int = -1;
        public static const INSUFFICIENT_DISKSPACE:int = 200;
        
        
        // HTTP HEADERS
        public static const HTTP_OK:int = 200;
        public static const HTTP_PARTIAL:int = 206;
        public static const HTTP_FILE_NOT_FOUND:int = 404;
        public static const HTTP_OUT_OF_RANGE:int = 416
        
        // THRESHOLDS
        public static const LOW_BATTERY_THRESHOLD:int = 10;
    }
}