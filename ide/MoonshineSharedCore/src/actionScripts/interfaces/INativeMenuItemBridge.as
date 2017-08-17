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
package actionScripts.interfaces
{
	import actionScripts.valueObjects.KeyboardShortcut;

	public interface INativeMenuItemBridge
	{
		function createMenu(label:String="", isSeparator:Boolean=false, listener:Function=null):void;
		
		function get keyEquivalent():String;
		function set keyEquivalent(value:String):void;
		function get keyEquivalentModifiers():Array;
		function set keyEquivalentModifiers(value:Array):void;
		function get data():Object;
		function set data(value:Object):void;
		function set listener(value:Function):void;
		function set shortcut(value:KeyboardShortcut):void;
		function get getNativeMenuItem():Object;
	}
}