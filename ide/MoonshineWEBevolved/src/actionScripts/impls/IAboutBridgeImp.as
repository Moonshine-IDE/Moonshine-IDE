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
package actionScripts.impls
{
	import actionScripts.interfaces.IAboutBridge;
	import actionScripts.plugin.help.view.About;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.core.FlexGlobals;
	import mx.core.IFlexDisplayObject;
	import mx.managers.PopUpManager;
	
	public class IAboutBridgeImp implements IAboutBridge
	{
		public function getNewAbout(closeListener:Function):IFlexDisplayObject
		{
			var about:IFlexDisplayObject = new About();
			return about;
		}
		
		public function open(about:IFlexDisplayObject):void
		{
			return PopUpManager.centerPopUp(about);
		}
		
		public function orderToFront(about:IFlexDisplayObject):void
		{
		}
		
		public function setFocus(about:IFlexDisplayObject):void
		{
		}
	}
}