package actionScripts.impls
{
	import actionScripts.interfaces.ILanguageServerBridge;
	import flash.errors.IllegalOperationError;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.languageServer.ILanguageServerManager;
	import actionScripts.events.ProjectEvent;
	import flash.events.Event;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.languageServer.ActionScriptLanguageServerManager;
	import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
	import actionScripts.languageServer.JavaLanguageServerManager;
	import actionScripts.ui.editor.BasicTextEditor;
	import actionScripts.plugin.groovy.grailsproject.vo.GrailsProjectVO;
	import actionScripts.languageServer.GroovyLanguageServerManager;
	import actionScripts.plugin.haxe.hxproject.vo.HaxeProjectVO;
	import actionScripts.languageServer.HaxeLanguageServerManager;

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

		public function get connectedProjectCount():int
		{
			return connectedManagers.length;
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
			var manager:ILanguageServerManager = null;
			if(project is AS3ProjectVO)
			{
				var as3Project:AS3ProjectVO = AS3ProjectVO(project);
				if(as3Project.isVisualEditorProject)
				{
					//visual editor projects don't have a language server
					return;
				}
				var as3Manager:ActionScriptLanguageServerManager = new ActionScriptLanguageServerManager(as3Project);
				manager = as3Manager;
			}
			if(project is JavaProjectVO)
			{
				var javaProject:JavaProjectVO = JavaProjectVO(project);
				var javaManager:JavaLanguageServerManager = new JavaLanguageServerManager(javaProject);
				manager = javaManager;
			}
			if(project is GrailsProjectVO)
			{
				var grailsProject:GrailsProjectVO = GrailsProjectVO(project);
				var groovyManager:GroovyLanguageServerManager = new GroovyLanguageServerManager(grailsProject);
				manager = groovyManager;
			}
			if(project is HaxeProjectVO)
			{
				var haxeProject:HaxeProjectVO = HaxeProjectVO(project);
				var haxeManager:HaxeLanguageServerManager = new HaxeLanguageServerManager(haxeProject);
				manager = haxeManager;
			}
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