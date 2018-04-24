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
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	
	public class TypeAheadProcess
	{
		private var javaPath:String;
		private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var languageServers:Vector.<LanguageServerForProject> = new <LanguageServerForProject>[];
		
		public function TypeAheadProcess(path:String)
		{
			javaPath = path;
			dispatcher.addEventListener(ProjectEvent.ADD_PROJECT, addProjectHandler);
			dispatcher.addEventListener(ProjectEvent.REMOVE_PROJECT, removeProjectHandler);
		}
		
		private function removeProjectHandler(event:ProjectEvent):void
		{
			var project:AS3ProjectVO = event.project as AS3ProjectVO;
			var languageServerCount:int = languageServers.length;
			for(var i:int = 0; i < languageServerCount; i++)
			{
				var languageServer:LanguageServerForProject = languageServers[i];
				if(languageServer.project === project)
				{
					languageServers.splice(i, 1);
					break;
				}
			}
		}
		
		private function addProjectHandler(event:ProjectEvent):void
		{
			var project:AS3ProjectVO = event.project as AS3ProjectVO;
			if(!project || project.projectFolder.projectReference.isTemplate)
			{
				return;
			}
			if(hasLanguageServerForProject(project))
			{
				//Moonshine sometimes dispatches ProjectEvent.ADD_PROJECT for
				//projects that have already been added
				return;
			}
			var languageServer:LanguageServerForProject = new LanguageServerForProject(project, javaPath);
			languageServers.push(languageServer);
		}
		
		private function hasLanguageServerForProject(project:AS3ProjectVO):Boolean
		{
			var serverCount:int = languageServers.length;
			for(var i:int = 0; i < serverCount; i++)
			{
				var languageServer:LanguageServerForProject = languageServers[i];
				if(languageServer.project == project)
				{
					return true;
				}
			}
			return false;
		}
	}
	
}