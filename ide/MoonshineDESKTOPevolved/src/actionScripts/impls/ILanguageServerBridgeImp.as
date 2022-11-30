////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2016-present Prominic.NET, Inc.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.impls
{
	import flash.events.Event;

	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.ProjectEvent;
	import actionScripts.interfaces.ILanguageServerBridge;
	import actionScripts.interfaces.IVisualEditorProjectVO;
	import actionScripts.languageServer.ILanguageServerManager;
	import actionScripts.plugin.ILanguageServerPlugin;
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
		private var _languageServerPlugins:Vector.<ILanguageServerPlugin> = new <ILanguageServerPlugin>[];

		public function get connectedProjectCount():int
		{
			return connectedManagers.length;
		}

		public function registerLanguageServerPlugin(plugin:ILanguageServerPlugin):void
		{
			var index:int = _languageServerPlugins.indexOf(plugin);
			if (index != -1)
			{
				return;
			}
			_languageServerPlugins.push(plugin);
		}

		public function unregisterLanguageServerPlugin(plugin:ILanguageServerPlugin):void
		{
			var index:int = _languageServerPlugins.indexOf(plugin);
			if (index == -1)
			{
				return;
			}
			_languageServerPlugins.removeAt(index);
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

		private function findPluginForProjectClass(projectClass:Class):ILanguageServerPlugin
		{
			for(var i:int = 0; i < _languageServerPlugins.length; i++)
			{
				var plugin:ILanguageServerPlugin = _languageServerPlugins[i];
				if (plugin.languageServerProjectType == projectClass)
				{
					return plugin;
				}
			}
			return null;
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
			var plugin:ILanguageServerPlugin = findPluginForProjectClass(projectClass);
			if (!plugin)
			{
				return;
			}
			var manager:ILanguageServerManager = null;
			manager = plugin.createLanguageServerManager(project);
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