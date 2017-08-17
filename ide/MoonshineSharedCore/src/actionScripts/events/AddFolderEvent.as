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
	import flash.events.Event;
	
	import actionScripts.valueObjects.FileWrapper;
	
	public class AddFolderEvent extends Event
	{
		public static const ADD_NEW_FOLDER:String = "ADD_NEW_FOLDER";
		public static const RENAME_FILE_FOLDER:String = "RENAME_FILE_FOLDER";
		
		public var newFileWrapper:FileWrapper;
		public var inFileWrapper:FileWrapper;
		
		public function AddFolderEvent(type:String, newFw:FileWrapper, inFw:FileWrapper)
		{
			newFileWrapper = newFw;
			inFileWrapper = inFw;
			
			super(type, true, false);
		}
	}
}