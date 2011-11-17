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
    import flash.text.TextField;
    import flash.text.TextLineMetrics;
    import flashx.textLayout.factory.TruncationOptions;
    
    
    /**
     * Utility class to provide ellipsis functionality.
     *
     */
    public class EllipsisUtil
    {
        /**
         * Truncates the specified text-fields to their maximum widths and adds ellipsis if necessary.
         * @param fields TextField object instances that we wish to truncate to the maximum width available.
         */
        public static function truncate(...fields):void
        {
            for each (var textField:TextField in fields) 
            {
                if (textField.numLines > 0)
                {
                    if (textField.textWidth > textField.width) 
                    {
                        var charLen:int = Math.ceil(textField.textWidth / textField.text.length); // this is an estimate of the character length, true type fonts generally don't have identical letter widths
                        var maxChars:int = textField.width / charLen;
                        
                        var original:String = textField.text;
                        textField.replaceText(maxChars - 2 /*for ellipsis*/, textField.length, TruncationOptions.HORIZONTAL_ELLIPSIS);
                        
                        var difference:int = Math.floor(textField.width-textField.textWidth);
                        
                        if ( (difference/charLen - 1) >= 0) // at least two more characters can fit in
                        {
                            textField.text = original;
                            maxChars += difference/charLen - 1;
                            textField.replaceText(maxChars - 2 /*for ellipsis*/, textField.length, TruncationOptions.HORIZONTAL_ELLIPSIS);
                        }
                    }
                }
            } 
        }
    }
}