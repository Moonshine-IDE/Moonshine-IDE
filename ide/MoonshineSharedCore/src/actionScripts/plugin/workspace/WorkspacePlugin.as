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
package actionScripts.plugin.workspace
{
	import flash.events.Event;
	
	import actionScripts.plugin.PluginBase;
	import actionScripts.valueObjects.ConstantsCoreVO;
	
	public class WorkspacePlugin extends PluginBase
	{
		public static const EVENT_SAVE_AS:String = "saveAsNewWorkspaceEvent";
		public static const EVENT_NEW:String = "newWorkspaceEvent";
		
		override public function get name():String 			{return "Workspace";}
		override public function get author():String 		{return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team";}
		override public function get description():String 	{return "Workspace manangement for the Moonshine projects.";}
		
		public function WorkspacePlugin()
		{
			super();
		}
		
		override public function activate():void
		{
			dispatcher.addEventListener(EVENT_SAVE_AS, onSaveAsNewWorkspaceEvent, false, 0, true);
			dispatcher.addEventListener(EVENT_NEW, onNewWorkspaceEvent, false, 0, true);
		}
		
		private function onSaveAsNewWorkspaceEvent(event:Event):void
		{
			
		}
		
		private function onNewWorkspaceEvent(event:Event):void
		{
			
		}
	}
}