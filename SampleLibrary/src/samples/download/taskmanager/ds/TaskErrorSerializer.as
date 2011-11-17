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

package samples.download.taskmanager.ds
{
    import samples.download.taskmanager.IErrorSerializer;
    import samples.download.taskmanager.TaskError;
    
    import flash.utils.ByteArray;
    
    public class TaskErrorSerializer implements IErrorSerializer
    {
        
        private static const SEPARATOR:String = ";";
        
        // Types
        public static const TYPE_TASK_ERROR:int = 100;
        public static const UNKNOWN_ERROR:int = 900;
        
        // Causes
        public static const UNKOWN_CAUSE:int = 99;
        
        public function serialize(error:Error):String
        {
            var errorString:String;
            
            if (error is TaskError)
            {
                errorString = TYPE_TASK_ERROR + SEPARATOR;
                if (TaskError(error).getCause() != -1)
                    errorString += TaskError(error).getCause();
                else
                    errorString += UNKOWN_CAUSE;
            }
            else
            {
                errorString = TYPE_TASK_ERROR + SEPARATOR + UNKOWN_CAUSE; 
            }
            
            return errorString;
        }
    }
}