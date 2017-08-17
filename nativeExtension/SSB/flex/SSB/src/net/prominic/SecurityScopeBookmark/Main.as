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
package net.prominic.SecurityScopeBookmark
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.external.ExtensionContext;
	
	import actionScripts.interfaces.IScopeBookmarkInterface;
	
	public class Main extends EventDispatcher implements IScopeBookmarkInterface
	{
		private var context: ExtensionContext = null;
		
		public function Main(target: IEventDispatcher = null)
		{
			super(target);
			context = ExtensionContext.createExtensionContext("karar.santanu.SecurityScopeBookmark", null);
		}
		
		public function dispose():void
		{
			context.dispose();
		}
		
		public function isSupported():Boolean
		{
			return context.call("isSupported");
		}
		
		public function getHomeDirectory():String
		{
			return String(context.call("getHomeDirectory"));
		}
		
		public function confirmHandshaking():String
		{
			return String(context.call("confirmHandshaking"));
		}
		
		public function addNewPath(relativeTo:String="", isDirectory:Boolean=false, strictToFileTypes:String=""):String
		{
			return String(context.call("addNewPath", relativeTo, isDirectory.toString(), strictToFileTypes));
		}
		
		public function restoreAccessedPaths():String
		{
			return String(context.call("restoreAccessedPaths"));
		}
		
		public function closeAccessedPath(value:String):String
		{
			return String(context.call("closeAccessedPath", value));
		}
		
		public function closeAllPaths():String
		{
			return String(context.call("closeAllPaths"));
		}
		
		public function disposeKeys():String
		{
			return String(context.call("disposeKeys"));
		}
	}
}