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

package samples.utils
{		
    public final class StringUtils
    {
        /**
         * Convert bytes to formatted string (ie. 33 MB) 
         * @param bytes - number bytes to convert.
         * @param attachDenominator - boolean to include denominator.
         * @param bytesString - localized "bytes" string.
         * @param kbString - localized "KB" string.
         * @param mbString - localized "MB" string.
         * @param gbString - localized "GB" string.
         * @param tbString - localized "TB" string.
         * @param pbString - localized "PB" string.
         */ 
        public static function formatBytes(bytes:Number, attachDenominator:Boolean = true, bytesString:String = "bytes", kbString:String = "KB", mbString:String = "MB", gbString:String = "GB", tbString:String = "TB", pbString:String = "PB"):String {
            var typeIndex:Number = Math.floor(Math.log(bytes) / Math.log(1024));
            
            var string:String = (bytes / Math.pow(1024, Math.floor(typeIndex))).toFixed(0);
            
            if (attachDenominator) {
                var types:Array = new Array(bytesString, kbString, mbString, gbString, tbString, pbString);
                string += " " + types[typeIndex];
            }
            
            if (string == "NaN undefined")
                return "0 " + mbString;
            else
                return string;  
        }
        
   }
}