/*
* Copyright (c) 2012 Research In Motion Limited.
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

package net.rim.blackberry.pushreceiver.dao
{
	import net.rim.blackberry.pushreceiver.vo.User;
		
	/**
	 * DAO related to the handling / processing of users that will either register 
	 * to receive pushes or unregister from receiving pushes.
	 */	
	public interface UserDAO
	{
		function createUserTable():void;
		
		function addOrUpdateUser(user:User):void;
		
		function addUser(user:User):void;
		
		function updateUser(user:User):void;
		
		function removeUser():void;
		
		function getUser():User;
		
		function hasExistingUser():Boolean;
	}
}