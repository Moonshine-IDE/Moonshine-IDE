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
package actionScripts.valueObjects
{
	[Bindable] public class URLDescriptorVO
	{
		public static var BASE_URL: String = "";
		public static var BASE_URL_MIRROR: String = "";
		public static var BASE_URL_PROTOCOL: String = "";
		
		public static var FILE_OPEN: String;
		public static var FILE_MODIFY: String;
		public static var FILE_REMOVE: String;
		public static var FILE_NEW: String;
		public static var FILE_RENAME: String;
		public static var PROJECT_DIR: String;
		public static var PROJECT_REMOVE: String;
		public static var PROJECT_COMPILE: String;
		public static var LOGIN_TEST: String;
		public static var LOGIN_USER: String;
		public static var CREATE_NEW_PROJECT: String;
		public static var CONFIG: String;
		public static var LOGIN_USER_FIELD_2SEND2_SERVER: String = "username";
		public static var LOGIN_PASSWORD_FIELD_2SEND2_SERVER: String = "password";
		
		public static function updateURLs():void
		{
			FILE_OPEN = BASE_URL +"MoonShineServer/doFileGet";
			FILE_MODIFY = BASE_URL +"MoonShineServer/doFilePut";
			FILE_REMOVE = BASE_URL +"MoonShineServer/doFileDelete";
			FILE_NEW = BASE_URL +"MoonShineServer/doFilePost";
			FILE_RENAME = BASE_URL +"MoonShineServer/doFileReName";
			PROJECT_DIR = BASE_URL +"MoonShineServer/listAllFile?path=/";
			PROJECT_REMOVE = BASE_URL + "MoonShineServer/deleteProject";
			PROJECT_COMPILE = BASE_URL +"MoonShineServer/executeFlex";
			CONFIG = BASE_URL +"MoonShineServer/config";
			LOGIN_TEST = BASE_URL +"admin/status" //"Grails4NotesBroker/login/status"  
			LOGIN_USER = BASE_URL +"admin/auth";
			CREATE_NEW_PROJECT = BASE_URL +"MoonShineServer/doProjectCreate";
		}
	}
}