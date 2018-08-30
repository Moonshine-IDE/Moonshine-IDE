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

	public class ILanguageServerBridgeImp implements ILanguageServerBridge
	{
		public function ILanguageServerBridgeImp()
		{
			
		}

		private var _started:Boolean = false;
		private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var managers:Vector.<ILanguageServerManager> = new <ILanguageServerManager>[];
		private var managersWaitingForClose:Vector.<ILanguageServerManager> = new <ILanguageServerManager>[];

		public function get connectedProjectCount():int
		{
			if(!this._started)
			{
				return 0;
			}
			return managers.length + managersWaitingForClose.length;
		}
		
		public function start():void
		{
			if(this._started)
			{
				return;
			}
			this._started = true;
			dispatcher.addEventListener(ProjectEvent.ADD_PROJECT, addProjectHandler);
			dispatcher.addEventListener(ProjectEvent.REMOVE_PROJECT, removeProjectHandler);
			dispatcher.addEventListener(ProjectEvent.REMOVE_PROJECT, removeProjectHandler);
		}
		
		public function hasLanguageServerForProject(project:ProjectVO):Boolean
		{
			if(!this._started)
			{
				return false;
			}
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
		
		public function hasCustomTextEditorForFileExtension(extension:String, project:ProjectVO):Boolean
		{
			var managerCount:int = managers.length;
			for(var i:int = 0; i < managerCount; i++)
			{
				var manager:ILanguageServerManager = managers[i];
				if(manager.project != project)
				{
					continue;
				}
				var index:int = manager.fileExtensions.indexOf(extension);
				if(index != -1)
				{
					return true;
				}
			}
			return false;
		}

		public function getCustomTextEditorForFileExtension(extension:String, project:ProjectVO, readOnly:Boolean = false):BasicTextEditor
		{
			var managerCount:int = managers.length;
			for(var i:int = 0; i < managerCount; i++)
			{
				var manager:ILanguageServerManager = managers[i];
				if(manager.project != project)
				{
					continue;
				}
				var index:int = manager.fileExtensions.indexOf(extension);
				if(index != -1)
				{
					return manager.createTextEditor(readOnly);
				}
			}
			return null;
		}

		public function hasCustomTextEditorForUriScheme(scheme:String, project:ProjectVO):Boolean
		{
			var managerCount:int = managers.length;
			for(var i:int = 0; i < managerCount; i++)
			{
				var manager:ILanguageServerManager = managers[i];
				if(manager.project != project)
				{
					continue;
				}
				var index:int = manager.uriSchemes.indexOf(scheme);
				if(index != -1)
				{
					return true;
				}
			}
			return false;
		}

		public function getCustomTextEditorForUriScheme(scheme:String, project:ProjectVO, readOnly:Boolean = false):BasicTextEditor
		{
			var managerCount:int = managers.length;
			for(var i:int = 0; i < managerCount; i++)
			{
				var manager:ILanguageServerManager = managers[i];
				if(manager.project != project)
				{
					continue;
				}
				var index:int = manager.uriSchemes.indexOf(scheme);
				if(index != -1)
				{
					return manager.createTextEditor(readOnly);
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
					managers.splice(i, 1);
					managersWaitingForClose.push(manager);
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
			manager.addEventListener(Event.CLOSE, manager_closeHandler);
			managers.push(manager);
		}

		private function manager_closeHandler(event:Event):void
		{
			var manager:ILanguageServerManager = ILanguageServerManager(event.currentTarget);
			var index:int = managers.indexOf(manager);
			if(index != -1)
			{
				managers.splice(index, 1);
			}
			else
			{
				index = managersWaitingForClose.indexOf(manager);
				managersWaitingForClose.splice(index, 1);
			}
			dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.LANGUAGE_SERVER_CLOSED, manager.project));
		}
	}
}