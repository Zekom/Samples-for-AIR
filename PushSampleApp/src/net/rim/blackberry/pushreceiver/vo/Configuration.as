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

package net.rim.blackberry.pushreceiver.vo
{
	/**
	 * Value object relating to configuration settings for the push application.
	 * Note: In our application, we expose the configuration settings to the user.
	 * However, in an actual push application, you would likely have these settings
	 * hard coded under the covers.  We expose them in our application for testing /
	 * debugging purposes.
	 */
	public class Configuration
	{		
		// Whether the application is using the public (BIS) PPG (i.e. the BlackBerry Push Service)
		// If this is set to false, the application is using an enterprise (BES) PPG
		public var usingPublicPushProxyGateway:Boolean;
	
		// If writing a consumer application, this corresponds to the unique ID you receive in your confirmation email after signing up
		// for the BlackBerry Push Service.
		// If writing an enterprise application and you are using the Push Service SDK to implement your Push Initiator on the server-side,
		// this corresponds to the arbitrary application ID that you decide on.
		// If writing an enterprise application and you are not using the Push Service SDK, this will be null.
		public var providerApplicationId:String;
		
		// This matches the URL used to register with / unregister from the BlackBerry Push Service (BIS) PPG.
		// For eval, this would be http://cp<cpid>.pushapi.eval.blackberry.com.
		// For production, this would be http://cp<cpid>.pushapi.na.blackberry.com
		// Replace <cpid> with your content provider ID (that you received when registering).
		// This applies to consumer applications only and will be null for enterprise applications.
		public var ppgUrl:String;
		
		// This matches the URL used to subscribe to / unsubscribe from the Push Initiator.
		// This URL will be null if not using the Push Service SDK to implement the server-side Push Initiator.
		public var pushInitiatorUrl:String;
		
		// Whether the application should launch (start up) if closed when a new push comes in
		// It will launch if the application has been registered to launch
		// The default behaviour is not to launch.  
		public var launchApplicationOnPush:Boolean;
		
		public function Configuration()
		{
		}
	}
}