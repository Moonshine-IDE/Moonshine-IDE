////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

package org.apache.flex.packageflexsdk.view.events
{
	import flash.events.Event;
	
	public class GenericEvent extends Event
	{
		public static var INSTALL_PROGRESS:String = "INSTALL_PROGRESS";
		public static var INSTALL_FINISH:String = "INSTALL_FINISH";
		public static var INSTALL_ABORTED:String = "INSTALL_ABORTED";
		public static var INSTALL_CANCEL:String = "INSTALL_CANCEL";
		public static var BROWSE_FOR_SDK_DIR:String = "BROWSE_FOR_SDK_DIR";
		public static var INSTALLER_READY:String = "INSTALLER_READY";
		
		public var value:Object;
		
		public function GenericEvent(type:String, value:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.value = value;
			super(type, bubbles, cancelable);
		}
	}
}