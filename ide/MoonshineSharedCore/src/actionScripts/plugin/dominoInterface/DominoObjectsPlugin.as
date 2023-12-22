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
package actionScripts.plugin.dominoInterface
{
	import flash.events.Event;
	import flash.utils.Dictionary;
	import utils.StringHelper;

	import actionScripts.events.DiagnosticsEvent;
	import actionScripts.events.OpenFileEvent;
	import actionScripts.events.ProjectEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.projectPanel.events.ProjectPanelPluginEvent;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.ProjectVO;

	import moonshine.lsp.Diagnostic;
	import moonshine.plugin.problems.data.DiagnosticHierarchicalCollection;
	import moonshine.plugin.problems.events.ProblemsViewEvent;
	import moonshine.plugin.problems.view.ProblemsView;
	import moonshine.plugin.problems.vo.MoonshineDiagnostic;
	import actionScripts.plugin.console.view.DominoObjectsView;
	import mx.controls.Alert;
	import flash.utils.Dictionary;
	import actionScripts.locator.IDEModel;

	import actionScripts.plugins.ui.editor.VisualEditorViewer;
	import view.domino.surfaceComponents.components.DominoGlobalsObjects;
	import view.domino.surfaceComponents.components.DominoFormObjects;
	import actionScripts.plugins.build.ConsoleBuildPluginBase;
	import actionScripts.plugin.projectPanel.events.ProjectPanelPluginEvent;
	public class DominoObjectsPlugin extends ConsoleBuildPluginBase
	{
		public static const EVENT_DOMINO_OBJECTS:String = "EVENT_DOMINO_OBJECTS";
		public static const EVENT_DOMINO_OBJECTS_SAVE:String = "EVENT_DOMINO_OBJECTS_SAVE";
		public static const EVENT_DOMINO_OBJECTS_UI_CLOSE:String = "EVENT_DOMINO_OBJECTS_UI_CLOSE";

		public function DominoObjectsPlugin()
		{
			dominoObjectView = new DominoObjectsView();
			dominoObjectView.percentWidth = 100;
			dominoObjectView.percentHeight = 100;
			dominoObjectView.minWidth = 0;
			dominoObjectView.minHeight = 0;
		}

		override public function get name():String { return "Problems Plugin"; }
		override public function get author():String { return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String { return "Displays problems in source files."; }

		private var dominoObjectView:DominoObjectsView = new DominoObjectsView();
		private var isStartupCall:Boolean = true;
		private var isDominoObjectsViewVisible:Boolean = false;
		private var diagnosticsByProject:Dictionary = new Dictionary();
		
		private var optionsMap:Dictionary

		
		private var editor:VisualEditorViewer=null;

		private var dominoGlobalsObject:DominoGlobalsObjects=null;
		private var dominoFormObject:DominoFormObjects=null;

		 
		
		

		override public function activate():void
		{
			super.activate();
			if(dominoObjectView){
				dispatcher.dispatchEvent(new ProjectPanelPluginEvent(ProjectPanelPluginEvent.SELECT_VIEW_IN_PROJECT_PANEL, dominoObjectView));
			}
			
			dispatcher.addEventListener(EVENT_DOMINO_OBJECTS, handleDominoObjectsShow);
			dispatcher.addEventListener(EVENT_DOMINO_OBJECTS_UI_CLOSE, handleDominoObjectsClose);
			dispatcher.addEventListener(EVENT_DOMINO_OBJECTS_SAVE, handleDominoObjectsSave);
			dispatcher.addEventListener(DiagnosticsEvent.EVENT_SHOW_DIAGNOSTICS, handleShowDiagnostics);
			dispatcher.addEventListener(ProjectEvent.REMOVE_PROJECT, handleRemoveProject);
		}

		override public function deactivate():void
		{
			super.deactivate();
			dispatcher.removeEventListener(EVENT_DOMINO_OBJECTS, handleDominoObjectsClose);
			dispatcher.removeEventListener(EVENT_DOMINO_OBJECTS_UI_CLOSE, handleDominoObjectsClose);
			dispatcher.removeEventListener(EVENT_DOMINO_OBJECTS_SAVE, handleDominoObjectsSave);
			dispatcher.removeEventListener(DiagnosticsEvent.EVENT_SHOW_DIAGNOSTICS, handleShowDiagnostics);
			dispatcher.removeEventListener(ProjectEvent.REMOVE_PROJECT, handleRemoveProject);
		}
		

		private function handleDominoObjectsSave(event:Event):void
		{
			
			optionsMap=dominoObjectView.getOptionsMap();
			dominoObjectView.updateIconAfterSave();
			// var editor:VisualEditorViewer= 
			model = IDEModel.getInstance();
			editor=model.activeEditor as VisualEditorViewer;
			if(editor){
				var path:String = editor.getVisualEditorFilePath();
				
				
				var xmlFileLocation:FileLocation = new FileLocation(path);

				var xml:XML = new XML(String(xmlFileLocation.fileBridge.read()));
				var dxl:XML =new XML(String(editor.currentFile.fileBridge.read()));
				
				for each(var gobalOptions:XML in xml..dominoGlobalsObject) //no matter of depth Note here
				{
					delete gobalOptions.parent().children()[gobalOptions.childIndex()];
				}
				for each(var gobalOptions:XML in dxl..item) //no matter of depth Note here
				{
					if(gobalOptions.@name.toString()=="$Script"){
						delete gobalOptions.parent().children()[gobalOptions.childIndex()];
					}
					if(gobalOptions.@name.toString()=="$$FormScript"){
						delete gobalOptions.parent().children()[gobalOptions.childIndex()];
					}
					
				}

				for each(var formOptions:XML in xml..dominoFormObject) //no matter of depth Note here
				{
					delete formOptions.parent().children()[formOptions.childIndex()];
				}
				for each(var customformOptions:XML in xml..dominoCustomObject) //no matter of depth Note here
				{
					delete customformOptions.parent().children()[customformOptions.childIndex()];
				}

				dominoGlobalsObject = new DominoGlobalsObjects();
				dominoFormObject=new DominoFormObjects();
				if(optionsMap["globalsInitialize"]!=undefined && optionsMap["globalsInitialize"].toString().length>0)
				{
					dominoGlobalsObject.initialize=optionsMap["globalsInitialize"];
				} 
				if(optionsMap["globalsOptions"]!=undefined && optionsMap["globalsOptions"].toString().length>0)
				{
					dominoGlobalsObject.options=optionsMap["globalsOptions"];
				}
				if(optionsMap["globalsDeclarations"]!=undefined && optionsMap["globalsDeclarations"].toString().length>0)
				{
					dominoGlobalsObject.declarations=optionsMap["globalsDeclarations"];
				}
				if(optionsMap["globalsTeminate"]!=undefined && optionsMap["globalsTeminate"].toString().length>0)
				{
					dominoGlobalsObject.terminate=optionsMap["globalsTeminate"];
				}
				var optionsXML:XML=dominoGlobalsObject.toXML();
				
				
				var formOptionsXML:XML=DominoFormObjects.toXML(optionsMap);
				var customFormOptionsXML:XML=DominoFormObjects.toCustomXML(optionsMap);
				
				
				//optionsXML.@
				xml.appendChild(optionsXML);
				xml.appendChild(formOptionsXML);
				xml.appendChild(customFormOptionsXML);
				
				xmlFileLocation.fileBridge.save(xml.toXMLString());

				var globaldxl:XML=dominoGlobalsObject.toCode();
				dxl.appendChild(globaldxl);
				var formdxl:XML=dominoFormObject.toCode(optionsMap);
				dxl.appendChild(formdxl);
				editor.currentFile.fileBridge.save(dxl.toXMLString());
			}


		}


		

		private function handleDominoObjectsClose(event:Event):void
		{
			dispatcher.dispatchEvent(new ProjectPanelPluginEvent(ProjectPanelPluginEvent.REMOVE_VIEW_TO_PROJECT_PANEL, dominoObjectView));
		}

		private function handleDominoObjectsShow(event:Event):void
		{
			
			model = IDEModel.getInstance();
			editor=model.activeEditor as VisualEditorViewer;
			
			if(editor){
				if(dominoObjectView){
					dominoObjectView.clearEditor()
				}
				var path:String = editor.getVisualEditorFilePath();
				var xmlFileLocation:FileLocation = new FileLocation(path);
				
				var xml:XML = new XML(String(xmlFileLocation.fileBridge.read()));
				var formTitle:String="Domino Form";
				if(xml && xmlFileLocation.fileBridge.exists){
					
					var formTitleList:XMLList = xml..MainApplication;
					formTitle=formTitleList[0].@title;
					if(formTitle==null||formTitle.length==0){
						formTitle=StringHelper.base64Decode(formTitleList[0].@windowsTitle);
					}
					if(formTitle){
						formTitle = formTitle.replace(/\"/g, "");
					}
					var domainObjectList:XMLList=xml..dominoGlobalsObject;
					var domainFormObjectList:XMLList=xml..dominoFormObject;
					var domainCustomFormObjectList:XMLList=xml..dominoCustomObject;
					var dominoForm:XMLList=null
					var dominoCustomForm:XMLList=null
					if(domainFormObjectList&&domainFormObjectList[0]){
						dominoForm=domainFormObjectList[0].children();
					}
					if(domainCustomFormObjectList&&domainCustomFormObjectList[0]){
						dominoCustomForm=domainCustomFormObjectList[0].children();
						
					}
					optionsMap=new Dictionary();
					
					dominoObjectView.initalTreeToDefault();

					
					dominoGlobalsObject= new DominoGlobalsObjects();
					//Alert.show("length:"+domainObjectList.length());
					if(domainObjectList.length()>0 ){
						dominoGlobalsObject.fromXMLDominoObject(domainObjectList[0]);
						
						if(dominoGlobalsObject.initialize){
							optionsMap["globalsInitialize"]=dominoGlobalsObject.initialize;
						}else{
							optionsMap["globalsInitialize"]="Sub Initialize\n"+"End Sub";
						}
						//Alert.show("initialize:"+optionsMap["globalsInitialize"]);
					
						if(dominoGlobalsObject.options){
							optionsMap["globalsOptions"]=dominoGlobalsObject.options;
						}else{
							optionsMap["globalsOptions"]="Option Public";
						}
						if(dominoGlobalsObject.declarations){
							optionsMap["globalsDeclarations"]=dominoGlobalsObject.declarations;
						}else{
							optionsMap["globalsDeclarations"]="Declarations Public";
						}
						if(dominoGlobalsObject.initialize){
							optionsMap["globalsTeminate"]=dominoGlobalsObject.terminate;
						}else{
							optionsMap["globalsTeminate"]="Sub Teminate\n"+"End Sub";
						}
					}else{
						optionsMap=dominoObjectView.setObjectOptionsToDefault()
					}
					if(dominoCustomForm){
						optionsMap=dominoObjectView.initailCustomFormOptions(optionsMap,dominoCustomForm)
					}
					if(dominoForm){
						optionsMap=dominoObjectView.initailFormOptions(optionsMap,dominoForm);
					}else{
						optionsMap=dominoObjectView.initailFormOptions(optionsMap,null);
					}
					
					dominoObjectView.setOptionsMap(optionsMap);
					dominoObjectView.setLanguageEditor();
					

				}

				dispatcher.dispatchEvent(new ProjectPanelPluginEvent(ProjectPanelPluginEvent.ADD_VIEW_TO_PROJECT_PANEL, dominoObjectView));
				dominoObjectView.expandNodesWithChildrenByPublic(formTitle)
				
					
			}
			
		}
		
		private function initializeProblemsViewEventHandlers(event:Event):void
		{
			dominoObjectView.addEventListener(ProblemsViewEvent.OPEN_PROBLEM, problemsPanel_openProblemHandler);
			dominoObjectView.addEventListener(Event.REMOVED_FROM_STAGE, problemsPanel_removedFromStageHandler);
		}

		private function cleanupProblemsViewEventHandlers():void
		{
			dominoObjectView.removeEventListener(ProblemsViewEvent.OPEN_PROBLEM, problemsPanel_openProblemHandler);
			dominoObjectView.removeEventListener(Event.REMOVED_FROM_STAGE, problemsPanel_removedFromStageHandler);
		}

		private function clearProblemsForProject(project:ProjectVO):void
		{
			if(!project)
			{
				return;
			}
			var diagnosticsByUri:Object = diagnosticsByProject[project];
			delete diagnosticsByProject[project];
			if(!diagnosticsByUri)
			{
				return;
			}
		
		}

		private function problemsPanel_removedFromStageHandler(event:Event):void
		{
            isDominoObjectsViewVisible = false;
		}

		private function handleLanguageServerClosed(event:ProjectEvent):void
		{
			this.clearProblemsForProject(event.project);
		}

		private function handleRemoveProject(event:ProjectEvent):void
		{
			this.clearProblemsForProject(event.project);
		}

		private function handleShowDiagnostics(event:DiagnosticsEvent):void
		{
			
		}

		private function problemsPanel_openProblemHandler(event:ProblemsViewEvent):void
		{
			var diagnostic:MoonshineDiagnostic = event.problem;
			var openEvent:OpenFileEvent = new OpenFileEvent(OpenFileEvent.OPEN_FILE,
				[diagnostic.fileLocation], diagnostic.range.start.line);
			openEvent.atChar = diagnostic.range.start.character;
			dispatcher.dispatchEvent(openEvent);
		}

	}
}


import actionScripts.interfaces.IViewWithTitle;
import actionScripts.ui.FeathersUIWrapper;

import moonshine.plugin.problems.view.ProblemsView;

class ProblemsViewWrapper extends FeathersUIWrapper implements IViewWithTitle {
	public function ProblemsViewWrapper(feathersUIControl:ProblemsView)
	{
		super(feathersUIControl);
	}

	public function get title():String {
		return ProblemsView(feathersUIControl).title;
	}

	override public function get className():String
	{
		//className may be used by LayoutModifier
		return "ProblemsView";
	}

	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
	{
		super.updateDisplayList(unscaledWidth, unscaledHeight);
	}
}