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

package org.apache.flex.packageflexsdk.model
{
	import flash.system.Capabilities;
	
	import org.apache.flex.packageflexsdk.resource.ViewResourceConstants;
	
	public class OS
	{
		public const WINDOWS:String = "windows";
		public const MAC:String = "mac";
		public const LINUX:String = "linux";
		
		public var os:String = null;
		
		public function OS()
		{
			setOS();
		}
		
		public function isWindows():Boolean {
			return os == WINDOWS;
		}
		
		public function isMac():Boolean {
			return os == MAC;
		}
		
		public function isLinux():Boolean {
			return os == LINUX;
		}
		
		public function isOther():Boolean {
			return !(isWindows() || isMac() || isLinux());
		}
		
		private function setOS():void {
			var operatingSystem:String = Capabilities.os;
			
			if (operatingSystem.search("Mac OS") != -1) {
				os = MAC;
			} else if (operatingSystem.search("Windows") != -1) {
				os = WINDOWS;
			} else if (operatingSystem.search("Linux") != -1) {
				os = LINUX;
			}
		}
	}
}
