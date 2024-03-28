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
	import view.suportClasses.events.DominoLotusScriptCompileConnectedEvent;
	import view.suportClasses.events.DominoLotusScriptCompileReturnEvent;
	import com.adobe.utils.StringUtil;
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

		private var compile:DominoObjectsViewLotusScriptCompile=null;
		private var compileConnected:Boolean=false;

		private var needVaildLotusScirpt:String=null;
		private var needCompileLotusScirpt:String=null;
		private var needConvertJavascript:String=null;
		private var testCount:int=1;

		 
		
		

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
			dispatcher.addEventListener(DominoLotusScriptCompileReturnEvent.DOMINO_LOTUSSCRIPT_COMPILE,handleLotusScriptCompile);

			dispatcher.addEventListener(DominoLotusScriptCompileConnectedEvent.DOMINO_LOTUSSCRIPT_COMPILE_CONNECTED, handleLotusScriptCompileConnected);

			//initializeSocket();
			
		}

		private function initializeSocket():void 
		{
			if(compile==null){
				//inital lotus script compile :
				compile=DominoObjectsViewLotusScriptCompile.getInstance();
			}

			
		}

		override public function deactivate():void
		{
			super.deactivate();
			dispatcher.removeEventListener(EVENT_DOMINO_OBJECTS, handleDominoObjectsClose);
			dispatcher.removeEventListener(EVENT_DOMINO_OBJECTS_UI_CLOSE, handleDominoObjectsClose);
			dispatcher.removeEventListener(EVENT_DOMINO_OBJECTS_SAVE, handleDominoObjectsSave);
			dispatcher.removeEventListener(DiagnosticsEvent.EVENT_SHOW_DIAGNOSTICS, handleShowDiagnostics);
			dispatcher.removeEventListener(ProjectEvent.REMOVE_PROJECT, handleRemoveProject);
			dispatcher.removeEventListener(DominoLotusScriptCompileReturnEvent.DOMINO_LOTUSSCRIPT_COMPILE,handleLotusScriptCompile);
			dispatcher.removeEventListener(DominoLotusScriptCompileConnectedEvent.DOMINO_LOTUSSCRIPT_COMPILE_CONNECTED, handleLotusScriptCompileConnected);
		}
		
		private function handleLotusScriptCompileConnected(even:DominoLotusScriptCompileConnectedEvent):void
		{
			compileConnected=even.connectedSuccess;
			
			
			
			if(compileConnected==true){
				var clientLanguage:String=dominoObjectView.getLanguageType();
				if(clientLanguage=="LotusScript"){
					if(needCompileLotusScirpt){
						needCompileLotusScirpt=StringHelper.base64Encode(needCompileLotusScirpt);
						needCompileLotusScirpt="compileLotusScript#"+needCompileLotusScirpt;
						needCompileLotusScirpt=needCompileLotusScirpt+"\r\n"
						compile.sendString(needCompileLotusScirpt);
						needCompileLotusScirpt=null;
					}
				}else if(clientLanguage=="JavaScript" || clientLanguage=="Common JavaScript"){
					if(needConvertJavascript){
						needConvertJavascript=StringHelper.base64Encode(needConvertJavascript);
						needConvertJavascript="convertJavaScriptToDxlRaw#"+needConvertJavascript;
						needConvertJavascript=needConvertJavascript+"\r\n"
						compile.sendString(needConvertJavascript);
						needConvertJavascript=null;
					}
				}else if(clientLanguage=="Formula"){
					var editorText:String=dominoObjectView.getLanguageEditorText();
					if(editorText!=null&&editorText.length>0){
						editorText=StringHelper.base64Encode(editorText);
						editorText="compileFormula#"+editorText;
						editorText=editorText+"\r\n"
						compile.sendString(editorText);
					}

				}
				
				
			
				
			}
			
			
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
				
				var compileDxl:XML =new XML(String(editor.currentFile.fileBridge.read()));
				for each(var gobalOptions:XML in compileDxl..item) //no matter of depth Note here
				{
					if(gobalOptions.@name.toString()=="$Script"){
						delete gobalOptions.parent().children()[gobalOptions.childIndex()];
					}
				}	
				
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
				if(dominoObjectView.selectedNode==null){
					dominoObjectView.initializeSelectNode();
				}
				var globalCompiledxl:XML=dominoGlobalsObject.toCompileCode(dominoObjectView.selectedNode.@key);
				dxl.appendChild(globaldxl);
				var editorText:String=dominoObjectView.getLanguageEditorText();
				compileDxl.appendChild(globalCompiledxl);
				
				var formdxl:XML=dominoFormObject.toCode(optionsMap);
				dxl.appendChild(formdxl);

				//save formula to dxl
				dxl=dominoFormObject.toFormulaXML(optionsMap,dxl);
				var finaldxl:String=fixSpaceAndNewLineForDxl(dxl.toXMLString());
				needVaildLotusScirpt=finaldxl;
				
				needCompileLotusScirpt=finaldxl;
				needConvertJavascript=dominoFormObject.toJavascriptDxl(optionsMap);
				if(compileConnected==true){
				}else{
					editor.currentFile.fileBridge.save(finaldxl);
				}
				//
				initializeSocket();
				if(compile!=null ){
					compile.closeSocket();
					compile.doConnectAction();
				}
				

				
				
				// if(compile!=null && compileConnected==true ){
				// 	compile.sendString(finaldxl);
				// 	
				// }
				
			}

		}

// 		/'++LotusScript Development Environment:2:5:(Forward):0:1
// Declare Sub Initialize
// '++LotusScript Development Environment:2:2:Initialize:1:10
// Sub Initialize
//   'initial-1112
// End Sub

		private function getNeedCheckLotusScript(lotusScriptStr:String):XML 
		{
			var goobalsXml:XML = new XML("<item/>");
            goobalsXml.@name="$Script"
            goobalsXml.@summary="false"
            goobalsXml.@sign="true"

            
            var text:String="";
            if(lotusScriptStr.indexOf("Sub")!=-1){
                var list:Array=lotusScriptStr.split("\n");
                var functionName:String=list[0];
                functionName=functionName.replace("Sub","");
                functionName=StringUtil.trim(functionName);
				text="'++LotusScript Development Environment:2:5:(Forward):0:1"+"\n";
                text=text+"Declare Sub "+functionName+"\n";
                text=text+'++LotusScript Development Environment:2:2:'+functionName+"1:10"+"\n";
                text=text+lotusScriptStr;
            }else{
                text=lotusScriptStr
            }
 			text=StringUtil.trim(text);
           
            
            var breakXML:XML=new XML("<break/>");
			var textXml:XML = new XML("<text>"+text+"</text>");
            textXml.appendChild(breakXML);
            goobalsXml.appendChild(textXml);

			return goobalsXml;

		}

		protected function handleLotusScriptCompile(event:DominoLotusScriptCompileReturnEvent):void 
		{
			if(event.compileResult){
				
				if(event.compileResult.length>1){
				
					if(event.compileResult.indexOf("#")){
						var list:Array=event.compileResult.split("#");
						var type:String=StringUtil.trim(list[0]);
						var result:String=null;
						if(type=="compileLotusScript"){
							result=StringUtil.trim(list[1]);
							if(result=="success"){
								
								model = IDEModel.getInstance();
								editor=model.activeEditor as VisualEditorViewer;
								var dxl:String =(needVaildLotusScirpt);
								
								editor.currentFile.fileBridge.save(dxl);
								//Alert.show("Lotus script compile success and save success");
							}else{
								var errorLineNumber:int=getErrorLineNumber(result);
								//"+errorLineNumber.toString()+"
								var errorLine:String="LotusScript compile error on :\n";
								
								errorLine=errorLine+getCorrectDetailsLotusScritpCompileInfo(result);
								
								Alert.show(errorLine);
							}
						}else if(type=="convertJavaScriptToDxlRaw"){
							var flag:String=StringUtil.trim(list[1]);
							result=StringUtil.trim(list[2]);
							if(flag=="success"){
								//Alert.show("Convert JavaScript to DXL success:"+needVaildLotusScirpt);
								
								
								
								var childxl:XML =new XML(String(needVaildLotusScirpt));
								var titleXml:XML=null;
								var body:XMLList = childxl.children();
								for each (var item:XML in body)
								{
									var itemName:String = item.name();
									if (itemName=="http://www.lotus.com/dxl::item" && item.@name=="$TITLE")
									{
										titleXml = item;
									}
								}
							
								
								//$TITLE
								for each(var htmlcode:XML in childxl..item) //no matter of depth Note here
								{
			
									if(htmlcode.@name.toString()=="$HTMLCode"){
										delete htmlcode.parent().children()[htmlcode.childIndex()];
									}
								}
								var htmlNewCode:XML=new XML("<item name=\"$HTMLCode\" sign=\"true\"></item>");
								var rawdataCode:XML=new XML("<rawitemdata type='1'>"+result+"\n"+"</rawitemdata>");
								htmlNewCode.appendChild(rawdataCode);
								if(titleXml!=null){
									
									titleXml.parent().insertChildBefore(titleXml,htmlNewCode);
									model = IDEModel.getInstance();
									editor=model.activeEditor as VisualEditorViewer;
									editor.currentFile.fileBridge.save(childxl.toXMLString());
									
									
								}
								
								
							}else{
								Alert.show("Convert JavaScript to DXL error: "+result);
							}
						}else if(type=="compileFormula"){
							var flag:String=StringUtil.trim(list[1]);
							result=StringUtil.trim(list[2]);
							if(flag=="success"){
								//Alert.show("Compile Formula success:"+result);
								model = IDEModel.getInstance();
								editor=model.activeEditor as VisualEditorViewer;
								editor.currentFile.fileBridge.save(needVaildLotusScirpt);
							}else{
								Alert.show("Compile Formula error: "+result);
							}
						}
					}
					
					// lineInt=lineInt-1;
					//Alert.show("Lotus Script compile error: on line " + lineInt.toString() + "");
					
				}else{
					
				}
			}
		}

		private function getErrorLineNumber(errorMessage:String):int
		{
			var list:Array=errorMessage.split(",");
			var line:String=StringUtil.trim(list[1]);
			var list2:Array=line.split("=");
			line=list2[1];
			var lineInt:int = parseInt(line);
			return lineInt;
		}

		private function getCorrectDetailsLotusScritpCompileInfo(errorMessage:String):String
		{
			
			var lineInt:int = getErrorLineNumber(errorMessage);
			if(lineInt&&lineInt>0){
				lineInt=lineInt-1;
			}
			var selectKey:String=dominoObjectView.selectedNode.@key;
			var returnString:String="";
			if(selectKey){
				var convertXml:XML =new XML(needVaildLotusScirpt);
				var body:XMLList = convertXml.children();
				var gobalScript:String=""; 
				var formScript:String="";
				var fileData:String=null;
				for each (var item:XML in body)
				{
					var itemName:String = item.name();
					if (itemName=="http://www.lotus.com/dxl::item" && item.@name=="$Script")
					{
						for each (var childitem:XML in item.children())
						{
							var childitemName:String = childitem.name();
							if (childitemName=="http://www.lotus.com/dxl::text")
							{
								gobalScript = childitem.text().toString();
							}

						}
						
					
						
					}
					if (itemName=="http://www.lotus.com/dxl::item" && item.@name=="$$FormScript")
					{
						for each (var childitem:XML in item.children())
						{
							var childitemName:String = childitem.name();
							if (childitemName=="http://www.lotus.com/dxl::text")
							{
								formScript = childitem.text().toString();
							}

						}
						
					}
				}
				if(selectKey.indexOf("globals")!=-1){
					fileData=gobalScript;
				}else{
					fileData=formScript;
				}
				
				if(fileData){
					var lines:Array = fileData.split(/\r\n|\r|\n/);
    
					
					if (lineInt >= 0 && lineInt < lines.length) {
						// Access the line at the specified index
						returnString = lines[lineInt];
						
					} 
				}
			}

			return returnString;
			
		}


		private function fixSpaceAndNewLineForDxl(originalString:String):String
		{
			var cleanedString:String = originalString.replace(/<text>([\s\S]*?)<\/text>/g, function(match:String, p1:String, offset:int, input:String):String {
				return '<text>' + p1.replace(/^\s+|\s+$/g, "") + '</text>';
			});	
			return cleanedString;
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
							optionsMap["globalsDeclarations"]="";
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