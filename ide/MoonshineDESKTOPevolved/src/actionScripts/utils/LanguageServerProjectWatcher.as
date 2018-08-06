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
package actionScripts.utils
{
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.ProjectEvent;
	import actionScripts.languageServer.ActionScriptLanguageServerManager;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
	import actionScripts.languageServer.ILanguageServerManager;
	import actionScripts.languageServer.JavaLanguageServerManager;
	
	public class LanguageServerProjectWatcher
	{
		private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var managers:Vector.<ILanguageServerManager> = new <ILanguageServerManager>[];
		
		public function LanguageServerProjectWatcher()
		{
			dispatcher.addEventListener(ProjectEvent.ADD_PROJECT, addProjectHandler);
			dispatcher.addEventListener(ProjectEvent.REMOVE_PROJECT, removeProjectHandler);
		}

		public function get connectedProjectCount():int
		{
			return managers.length;
		}
		
		private function removeProjectHandler(event:ProjectEvent):void
		{
			var project:ProjectVO = event.project as ProjectVO;
			var managerCount:int = managers.length;
			for(var i:int = 0; i < managerCount; i++)
			{
				var manager:ILanguageServerManager = managers[i];
				if(manager.project === project)
				{
					managers.splice(i, 1);
					break;
				}
			}
		}
		
		private function addProjectHandler(event:ProjectEvent):void
		{
			var project:ProjectVO = event.project;
			if(!project || project.projectFolder.projectReference.isTemplate || hasManagerForProject(project))
			{
				return;
			}
			if(project is AS3ProjectVO)
			{
				var as3Project:AS3ProjectVO = AS3ProjectVO(project);
				if(as3Project.isVisualEditorProject)
				{
					//Moonshine sometimes dispatches ProjectEvent.ADD_PROJECT for
					//projects that have already been added
					return;
				}
				var as3Manager:ActionScriptLanguageServerManager = new ActionScriptLanguageServerManager(as3Project);
				managers.push(as3Manager);
			}
			if(project is JavaProjectVO)
			{
				var javaProject:JavaProjectVO = JavaProjectVO(project);
				var javaManager:JavaLanguageServerManager = new JavaLanguageServerManager(javaProject);
				managers.push(javaManager);
			}
		}
		
		private function hasManagerForProject(project:ProjectVO):Boolean
		{
			var serverCount:int = managers.length;
			for(var i:int = 0; i < serverCount; i++)
			{
				var manager:ILanguageServerManager = managers[i];
				if(manager.project == project)
				{
					return true;
				}
			}
			return false;
		}
	}
	
}