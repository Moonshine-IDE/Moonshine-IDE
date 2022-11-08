////////////////////////////////////////////////////////////////////////////////
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
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
// 
////////////////////////////////////////////////////////////////////////////////

package actionScripts.impls
{
	import flash.events.Event;
	import flash.utils.Dictionary;

	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.ProjectEvent;
	import actionScripts.interfaces.ILanguageServerBridge;
	import actionScripts.interfaces.IVisualEditorProjectVO;
	import actionScripts.languageServer.ILanguageServerManager;
	import actionScripts.plugin.genericproj.vo.GenericProjectVO;
	import actionScripts.plugin.ondiskproj.vo.OnDiskProjectVO;
	import actionScripts.ui.editor.BasicTextEditor;
	import actionScripts.valueObjects.ProjectVO;

	public class ILanguageServerBridgeImp implements ILanguageServerBridge
	{
		private static const URI_SCHEME_FILE:String = "file";

		public function ILanguageServerBridgeImp()
		{
			dispatcher.addEventListener(ProjectEvent.ADD_PROJECT, addProjectHandler);
			dispatcher.addEventListener(ProjectEvent.REMOVE_PROJECT, removeProjectHandler);
		}

		private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var managers:Vector.<ILanguageServerManager> = new <ILanguageServerManager>[];
		private var connectedManagers:Vector.<ILanguageServerManager> = new <ILanguageServerManager>[];
		private var managerProviders:Dictionary = new Dictionary(true);

		public function get connectedProjectCount():int
		{
			return connectedManagers.length;
		}

		public function registerLanguageServerProvider(projectType:Class /* extends ProjectVO */, callback:Function /* (ProjectVO) -> ILanguageServerManager */):void
		{
			managerProviders[projectType] = callback;
		}

		public function unregisterLanguageServerProvider(projectType:Class /* extends ProjectVO */):void
		{
			delete managerProviders[projectType];
		}
		
		public function hasLanguageServerForProject(project:ProjectVO):Boolean
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

		public function hasCustomTextEditorForUri(uri:String, project:ProjectVO):Boolean
		{
			var colonIndex:int = uri.indexOf(":");
			if(colonIndex == -1)
			{
				throw new URIError("Invalid URI: " + uri);
			}
			var scheme:String = uri.substr(0, colonIndex);
			var uriWithoutParams:String = uri;
			var paramsIndex:int = uriWithoutParams.lastIndexOf("?");
			if(paramsIndex != -1)
			{
				uriWithoutParams = uri.substr(0, paramsIndex);
			}
			var extension:String = "";
			var dotIndex:int = uriWithoutParams.lastIndexOf(".");
			if(dotIndex != -1)
			{
				extension = uriWithoutParams.substr(dotIndex + 1);
			}

			var managerCount:int = managers.length;
			for(var i:int = 0; i < managerCount; i++)
			{
				var manager:ILanguageServerManager = managers[i];
				if(manager.project != project)
				{
					continue;
				}
				if(scheme == URI_SCHEME_FILE)
				{
					var extensionIndex:int = manager.fileExtensions.indexOf(extension);
					if(extensionIndex != -1)
					{
						return true;
					}
				}
				else
				{
					var schemeIndex:int = manager.uriSchemes.indexOf(scheme);
					if(schemeIndex != -1)
					{
						return true;
					}
				}
			}
			return false;
		}

		public function getCustomTextEditorForUri(uri:String, project:ProjectVO, readOnly:Boolean = false):BasicTextEditor
		{
			var colonIndex:int = uri.indexOf(":");
			if(colonIndex == -1)
			{
				throw new URIError("Invalid URI: " + uri);
			}
			var scheme:String = uri.substr(0, colonIndex);
			var uriWithoutParams:String = uri;
			var paramsIndex:int = uriWithoutParams.lastIndexOf("?");
			if(paramsIndex != -1)
			{
				uriWithoutParams = uri.substr(0, paramsIndex);
			}
			var extension:String = "";
			var dotIndex:int = uriWithoutParams.lastIndexOf(".");
			if(dotIndex != -1)
			{
				extension = uriWithoutParams.substr(dotIndex + 1);
			}

			var managerCount:int = managers.length;
			for(var i:int = 0; i < managerCount; i++)
			{
				var manager:ILanguageServerManager = managers[i];
				if(manager.project != project)
				{
					continue;
				}
				if(scheme == URI_SCHEME_FILE)
				{
					var extensionIndex:int = manager.fileExtensions.indexOf(extension);
					if(extensionIndex != -1)
					{
						return manager.createTextEditorForUri(uri, readOnly);
					}
				}
				else
				{
					var schemeIndex:int = manager.uriSchemes.indexOf(scheme);
					if(schemeIndex != -1)
					{
						return manager.createTextEditorForUri(uri, readOnly);
					}
				}
			}
			return null;
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
					//don't remove from connectedManagers until
					managers.splice(i, 1);
					cleanupManager(manager);
					break;
				}
			}
		}
		
		private function addProjectHandler(event:ProjectEvent):void
		{
			var project:ProjectVO = event.project;
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
			if ((project is IVisualEditorProjectVO && IVisualEditorProjectVO(project).isVisualEditorProject)
				|| project is OnDiskProjectVO
				|| project is GenericProjectVO)
			{
				//these types of projects don't have a language server
				return;
			}
			var projectClass:Class = Object(project).constructor as Class;
			if (!(projectClass in managerProviders))
			{
				return;
			}
			var manager:ILanguageServerManager = null;
			var callback:Function = managerProviders[projectClass] as Function;
			manager = ILanguageServerManager(callback(project));
			managers.push(manager);
			manager.addEventListener(Event.INIT, manager_initHandler);
			manager.addEventListener(Event.CLOSE, manager_closeHandler);
		}

		private function cleanupManager(manager:ILanguageServerManager):void
		{
			var index:int = managers.indexOf(manager);
			if(index != -1)
			{
				return;
			}
			var connectedIndex:int = connectedManagers.indexOf(manager);
			if(connectedIndex != -1)
			{
				return;
			}
			manager.removeEventListener(Event.INIT, manager_initHandler);
			manager.removeEventListener(Event.CLOSE, manager_closeHandler);
		}

		private function manager_initHandler(event:Event):void
		{
			var manager:ILanguageServerManager = ILanguageServerManager(event.currentTarget);
			connectedManagers.push(manager);
			dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.LANGUAGE_SERVER_OPENED, manager.project));
		}

		private function manager_closeHandler(event:Event):void
		{
			var manager:ILanguageServerManager = ILanguageServerManager(event.currentTarget);
			var index:int = connectedManagers.indexOf(manager);
			if(index != -1)
			{
				connectedManagers.splice(index, 1);
			}
			cleanupManager(manager);
			dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.LANGUAGE_SERVER_CLOSED, manager.project));
		}
	}
}