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

package com.riaspace.nativeApplicationUpdater
{
	public class UpdaterErrorCodes
	{
		/**
		 * Not supported os type.
		 */
		public static const ERROR_9000:uint = 9000;
		
		/**
		 * Update package is not defined for current installerType.
		 */
		public static const ERROR_9001:uint = 9001;
		
		/**
		 * Error downloading update descriptor file.
		 */
		public static const ERROR_9002:uint = 9002;

		/**
		 * IO Error downloading update descriptor file.
		 */
		public static const ERROR_9003:uint = 9003;

		/**
		 * Error downloading update file.
		 */
		public static const ERROR_9004:uint = 9004;

		/**
		 * Error downloading update file.
		 */
		public static const ERROR_9005:uint = 9005;

		/**
		 * Contents/MacOS folder should contain only 1 install file.
		 */
		public static const ERROR_9006:uint = 9006;

		/**
		 * Mounted volume should contain only 1 install file.
		 */
		public static const ERROR_9007:uint = 9007;

		/**
		 * Error attaching dmg file.
		 */
		public static const ERROR_9008:uint = 9008;

	}
}