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
    
    import flash.filesystem.File;
    
    public class DiskSpaceWakeupCondition extends WakeupConditionBase
    {
        
        private static const MIN_DISK_SPACE:int = 1024;
        
        public override function validateCondition():int
        {
            var availableSize:Number = File.applicationStorageDirectory.spaceAvailable;
            
            if (availableSize < MIN_DISK_SPACE)
                return GlobalConstants.MEMORY_FULL
            
            return  GlobalConstants.OK
        }
    }
}