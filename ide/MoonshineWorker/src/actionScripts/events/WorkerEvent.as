////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0 
// 
// Unless required by applicable law or agreed to in writing, software 
// distributed under the License is distributed on an "AS IS" BASIS, 
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and 
// limitations under the License
//
// Author: Prominic.NET, Inc. 
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
////////////////////////////////////////////////////////////////////////////////
package actionScripts.events
{
	public class WorkerEvent
	{
		public static const SEARCH_IN_PROJECTS:String = "SEARCH_IN_PROJECTS";
		public static const TOTAL_FILE_COUNT:String = "TOTAL_FILE_COUNT";
		public static const TOTAL_FOUND_COUNT:String = "TOTAL_FOUND_COUNT";
		public static const FILE_PROCESSED_COUNT:String = "FILE_PROCESSED_COUNT";
		public static const FILTERED_FILE_COLLECTION:String = "FILTERED_FILE_COLLECTION";
		public static const PROCESS_ENDS:String = "PROCESS_ENDS";
		public static const REPLACE_FILE_WITH_VALUE:String = "REPLACE_FILE_WITH_VALUE";
		public static const GET_FILE_LIST:String = "GET_FILE_LIST";
		public static const SET_FILE_LIST:String = "SET_FILE_LIST";
		public static const SET_IS_MACOS:String = "SET_IS_MACOS"; // running standard code to determine macOS platform always returning true even in Windows
		public static const RUN_LIST_OF_NATIVEPROCESS:String = "RUN_LIST_OF_NATIVEPROCESS";
		public static const RUN_LIST_OF_NATIVEPROCESS_ENDED:String = "RUN_LIST_OF_NATIVEPROCESS_ENDED";
		public static const RUN_LIST_OF_NATIVEPROCESS_PROCESS_TICK:String = "RUN_LIST_OF_NATIVEPROCESS_PROCESS_TICK";
		public static const RUN_NATIVEPROCESS_OUTPUT:String = "RUN_NATIVEPROCESS_OUTPUT";
		public static const CONSOLE_MESSAGE_NATIVEPROCESS_OUTPUT:String = "CONSOLE_MESSAGE_NATIVEPROCESS_OUTPUT";
		public static const SEARCH_PROJECTS_IN_DIRECTORIES:String = "SEARCH_PROJECTS_IN_DIRECTORIES";
		public static const FOUND_PROJECTS_IN_DIRECTORIES:String = "FOUND_PROJECTS_IN_DIRECTORIES";
	}
}