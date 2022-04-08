package actionScripts.impls
{
	import actionScripts.plugin.project.ProjectStarter;
	import actionScripts.plugin.project.interfaces.IProjectStarter;
	import actionScripts.plugin.project.interfaces.IProjectStarterDelegate;
	import actionScripts.plugin.project.vo.ProjectStarterSubscribing;

	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.ProjectEvent;
	import actionScripts.interfaces.ILanguageServerBridge;
	import actionScripts.languageServer.ActionScriptLanguageServerManager;
	import actionScripts.languageServer.GroovyLanguageServerManager;
	import actionScripts.languageServer.HaxeLanguageServerManager;
	import actionScripts.languageServer.ILanguageServerManager;
	import actionScripts.languageServer.JavaLanguageServerManager;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.groovy.grailsproject.vo.GrailsProjectVO;
	import actionScripts.plugin.haxe.hxproject.vo.HaxeProjectVO;
	import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
	import actionScripts.plugin.ondiskproj.vo.OnDiskProjectVO;
	import actionScripts.ui.editor.BasicTextEditor;
	import actionScripts.valueObjects.ProjectVO;

	import flash.events.EventDispatcher;

	public class ILanguageServerBridgeImp extends EventDispatcher implements ILanguageServerBridge, IProjectStarter
	{
		private static const URI_SCHEME_FILE:String = "file";

		public function ILanguageServerBridgeImp()
		{
			//dispatcher.addEventListener(ProjectEvent.ADD_PROJECT, addProjectHandler);
			dispatcher.addEventListener(ProjectEvent.REMOVE_PROJECT, removeProjectHandler);
			projectStarter.subscribe(
					new ProjectStarterSubscribing(
							this,
							new <String>["onProjectAdded"]
					)
			);
		}

		private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var managers:Vector.<ILanguageServerManager> = new <ILanguageServerManager>[];
		private var connectedManagers:Vector.<ILanguageServerManager> = new <ILanguageServerManager>[];
		private var projectStarter:ProjectStarter = ProjectStarter.getInstance();

		public function get connectedProjectCount():int
		{
			return connectedManagers.length;
		}

		private var _projectStarterDelegate:IProjectStarterDelegate;
		public function get projectStarterDelegate():IProjectStarterDelegate
		{
			return _projectStarterDelegate;
		}
		public function set projectStarterDelegate(value:IProjectStarterDelegate):void
		{
			_projectStarterDelegate = value;
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
		
		public function onProjectAdded(event:ProjectEvent):void
		{
			var project:ProjectVO = event.project;
			if(!project || project.projectFolder.projectReference.isTemplate)
			{
				projectStarter.continueDelegation();
				return;
			}
			if(hasLanguageServerForProject(project))
			{
				//Moonshine sometimes dispatches ProjectEvent.ADD_PROJECT for
				//projects that have already been added
				projectStarter.continueDelegation();
				return;
			}
			var manager:ILanguageServerManager = null;
			if(project is AS3ProjectVO)
			{
				var as3Project:AS3ProjectVO = AS3ProjectVO(project);
				if(as3Project.isVisualEditorProject)
				{
					//visual editor projects don't have a language server
					projectStarter.continueDelegation();
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
			if (project is OnDiskProjectVO)
			{
				projectStarter.continueDelegation();
				return;
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
			projectStarter.continueDelegation();
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