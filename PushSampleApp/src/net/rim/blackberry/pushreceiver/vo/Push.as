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
	 * Value object relating to a push.
	 */
	public class Push
	{
		// The content types that Push Receiver can display (images, HTML/XML, and plain text)
		public static const CONTENT_TYPE_IMAGE:String = "image";
		public static const CONTENT_TYPE_XML:String = "xml";
		public static const CONTENT_TYPE_TEXT:String = "text";
		
		// The various file extensions that are supported 
		public static const FILE_EXTENSION_XML:String = ".xml";
		public static const FILE_EXTENSION_HTML:String = ".html";
		public static const FILE_EXTENSION_TEXT:String = ".txt";
		public static const FILE_EXTENSION_JPEG:String = ".jpg";
		public static const FILE_EXTENSION_GIF:String = ".gif";
		public static const FILE_EXTENSION_PNG:String = ".png";
		
		// The unique id of the push (to identify it in the database)
		public var seqNum:int;
		
		// The content/payload of the push as a base64-encoded string
		public var content:String;
		
		// The content type (i.e. one of "image", "xml", "text")
		public var contentType:String;
		
		// The file extension associated with the content
		// (i.e. one of ".xml", ".html", ".txt", ".jpg", ".gif", ".png")
		public var fileExtension:String;
		
		// The date of the push (e.g. Mon, Oct 31, 2011) 
		public var pushDate:String;
		
		// The time of the push using a 12-hour clock (e.g. 2:38p, e.g. 11:22a)
		public var pushTime:String;
		
		// Whether or not the push has been previously read/opened
		public var unread:Boolean = true;
		
		// The date heading object in the push list this push corresponds to
		public var dateHeading:Object;
		
		public function Push()
		{
		}
	}
}