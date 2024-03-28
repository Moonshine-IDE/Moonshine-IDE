////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
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
package actionScripts.plugins.ui.editor
{
	import flash.events.Event;
	import mx.events.FlexEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.valueObjects.ProjectVO;
	
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.events.SaveFileEvent;
	import actionScripts.valueObjects.URLDescriptorVO;

	import actionScripts.plugin.console.ConsoleOutputEvent;
	import actionScripts.controllers.DataAgent;
	import actionScripts.valueObjects.URLDescriptorVO;

	import actionScripts.utils.TextUtil;

	import actionScripts.ui.FeathersUIWrapper;

	import actionScripts.plugins.help.view.DominoAgentLotusScriptVisualEditor;
	import moonshine.editor.text.events.TextEditorChangeEvent;

	import moonshine.editor.text.TextEditor;
	import actionScripts.ui.editor.BasicTextEditor;
	import moonshine.editor.text.syntax.parser.PlainTextLineParser;
	import moonshine.editor.text.events.TextEditorLineEvent;
	import view.suportClasses.events.PropertyEditorChangeEvent;

	//import actionScripts.plugins.help.view.events.DominoActionPropertyChangeEvent;
	import mx.controls.Alert;
	import actionScripts.utils.DominoUtils;
	import mx.events.CollectionEvent;
	import actionScripts.locator.IDEModel;
	import mx.events.CollectionEventKind;
	import actionScripts.ui.tabview.TabEvent;
	
	import utils.StringHelperUtils;
	import utils.StringHelper;
	import com.adobe.utils.StringUtil;
	import actionScripts.plugin.dominoInterface.DominoObjectsViewLotusScriptCompile;
	import view.suportClasses.events.DominoLotusScriptCompileReturnEvent;
	import view.suportClasses.events.DominoLotusScriptCompileConnectedEvent;
	import actionScripts.plugins.ui.editor.VisualEditorViewer;
	
	import actionScripts.plugin.dominoInterface.DominoObjectsPlugin;
	import view.suportClasses.events.DominoLotusScriptCompileConnectedEvent;
	import actionScripts.events.GlobalEventDispatcher;
	import view.suportClasses.events.DominoLotusScriptAgentEditorTreeChangeEvent;
    import actionScripts.plugins.ui.editor.DominoAgentFormulaEditor;
	public class DominoAgentLotusScriptEditor extends BasicTextEditor  
	{

		private var dominoAgentLotusScriptEditor:DominoAgentLotusScriptVisualEditor;
    	private var visualEditorProject:ProjectVO;
		private var hasChangedProperties:Boolean;
		private var compileConnected:Boolean=false;
		private var needVaildLotusScirpt:String=null;

		private var selectLotusScriptAgentType:String="initialize";

		public static const EVENT_DOMINO_LOTUSSCRIPT_AGENT_COMPILE_CLOSE:String = "EVENT_DOMINO_LOTUSSCRIPT_AGENT_COMPILE_CLOSE";
		public static const EVENT_DOMINO_LOTUSSCRIPT_AGENT_COMPILE_OPEN:String = "EVENT_DOMINO_LOTUSSCRIPT_AGENT_COMPILE_OPEN";
		public static const EVENT_DOMINO_LOTUSSCRIPT_AGENT_TREE_CHANGE:String = "EVENT_DOMINO_LOTUSSCRIPT_AGENT_TREE_CHANGE";
		

		private var compile:DominoObjectsViewLotusScriptCompile=null;

        public function DominoAgentLotusScriptEditor(visualEditorProject:ProjectVO = null){
            this.visualEditorProject=visualEditorProject;
            super();
        }

        override protected function initializeChildrens():void
		{
			if(!editor)
			{
				editor = new TextEditor("", false);
			}
			if(!editor.parser)
			{
				editor.parser = new PlainTextLineParser();
			}
			editor.addEventListener(TextEditorChangeEvent.TEXT_CHANGE, handleTextChange);
			editor.addEventListener(TextEditorLineEvent.TOGGLE_BREAKPOINT, handleToggleBreakpoint);
			dispatcher.addEventListener(DominoLotusScriptAgentEditorTreeChangeEvent.DOMINO_LOTUSSCRIPT_AGENT_TREE_CHANGE, handleTreeSelectedEvent);
			editorWrapper = new FeathersUIWrapper(editor);
			editorWrapper.percentHeight = 100;
			editorWrapper.percentWidth = 100;
			text = "";
			
			dominoAgentLotusScriptEditor = new DominoAgentLotusScriptVisualEditor();
			dominoAgentLotusScriptEditor.addEventListener(FlexEvent.CREATION_COMPLETE, onDominoAgentLotusScriptEditorCreationComplete);
			dominoAgentLotusScriptEditor.percentWidth = 100;
			dominoAgentLotusScriptEditor.percentHeight = 100;
			//dominoAgentLotusScriptEditor.addEventListener(VisualEditorViewChangeEvent.CODE_CHANGE, onDominoAgentLotusScriptCodeChange);
			
			dominoAgentLotusScriptEditor.codeEditor = editorWrapper;
			model.editors.addEventListener(CollectionEvent.COLLECTION_CHANGE, handleEditorCollectionChange);
			
			
		}
		override protected function tabSelectHandler(event:TabEvent):void
		{	
			if (event.child == this)
			{
				// check for any externally update
				checkFileIfChanged();
				editorWrapper.enabled = true;
			}
			else
			{
				editorWrapper.enabled = false;
			}

			dispatcher.dispatchEvent(new Event(DominoAgentFormulaEditor.EVENT_DOMINO_FORMULA_AGENT_COMPILE_CLOSE));

			dispatcher.dispatchEvent(new Event(EVENT_DOMINO_LOTUSSCRIPT_AGENT_COMPILE_OPEN));
		}

        private function onDominoAgentLotusScriptEditorCreationComplete(event:FlexEvent):void
		{
			dominoAgentLotusScriptEditor.removeEventListener(FlexEvent.CREATION_COMPLETE, onDominoAgentLotusScriptEditorCreationComplete);
			//dominoAgentLotusScriptEditor.dominoViewVisualEditor.dominoViewPropertyEditor.addEventListener(PropertyEditorChangeEvent.PROPERTY_EDITOR_CHANGED, onPropertyEditorChanged);
			//dominoAgentLotusScriptEditor.dominoViewVisualEditor.dominoViewPropertyEditor.addEventListener(Event.CHANGE, onDominoAgentFormulaPropertyChange);
			
			
			dispatcher.addEventListener(EVENT_DOMINO_LOTUSSCRIPT_AGENT_COMPILE_OPEN, handleDominoLotusScriptAgentCompileOpen);
			dispatcher.addEventListener(EVENT_DOMINO_LOTUSSCRIPT_AGENT_COMPILE_CLOSE, handleDominoFormulaLotusSCriptCompileClose);
			dispatcher.dispatchEvent(new Event(EVENT_DOMINO_LOTUSSCRIPT_AGENT_COMPILE_OPEN));
			
			//dominoAgentLotusScriptEditor.dominoViewVisualEditor.addEventListener("saveCode", onDominoViewEditorSaveCode);

			//dominoAgentLotusScriptEditor.dominoViewVisualEditor.visualEditorFilePath = this.currentFile.fileBridge.nativePath;
			
		}

        // private function onDominoAgentLotusScriptCodeChange(event:VisualEditorViewChangeEvent):void
		// {
			
		// 	var xmlStr:String="<?xml version=\"1.0\" encoding=\"utf-8\"?>"+"\r\n";
		// 	var xmlView:XML=dominoAgentLotusScriptEditor.dominoViewVisualEditor.getSavedXMLFromMemoryObject();
		// 	editor.text=xmlView.toXMLString();
			

		// 	updateChangeStatus()
		// }

        private function onPropertyEditorChanged(event:PropertyEditorChangeEvent):void
		{
			hasChangedProperties = _isChanged = true;
			dispatchEvent(new Event('labelChanged'));
		}

         override protected function createChildren():void
		{
			
			if(file){
				dominoAgentLotusScriptEditor.agentName=file.fileBridge.name;
			}else{
				Alert.show("Agent file is null");
			}
			
			addElement(dominoAgentLotusScriptEditor);
			super.createChildren();
		}


		// override protected function openHandler(event:Event):void
		// {
		// 	super.openHandler(event);
		// 	var filePath:String = file.fileBridge.nativePath;
			
		// 	openLoadingFile(filePath);
			
		// }

        // public function openLoadingFile(filePath:String):void
		// {
		// 	//dominoAgentLotusScriptEditor.dominoViewVisualEditor.loadFile(filePath);
		// }

		public function getFilePath():String {
			return file.fileBridge.nativePath;
		}

		override public function open(newFile:FileLocation, fileData:Object=null):void
		{
			loadingFile = true;
			currentFile = newFile;
			if (fileData) 
			{
				super.openFileAsStringHandler(fileData as String);
				return;
			}

			
        }



        protected function handleEditorCollectionChange(event:CollectionEvent):void
		{
			if (event.kind == CollectionEventKind.REMOVE && event.items[0] == this)
			{

				editor.removeEventListener(TextEditorChangeEvent.TEXT_CHANGE, handleTextChange);
				editor.removeEventListener(TextEditorLineEvent.TOGGLE_BREAKPOINT, handleToggleBreakpoint);
				dispatcher.removeEventListener(DominoLotusScriptAgentEditorTreeChangeEvent.DOMINO_LOTUSSCRIPT_AGENT_TREE_CHANGE, handleTreeSelectedEvent);
			
				dominoAgentLotusScriptEditor.removeEventListener(FlexEvent.CREATION_COMPLETE, onDominoAgentLotusScriptEditorCreationComplete);
				dispatcher.removeEventListener(EVENT_DOMINO_LOTUSSCRIPT_AGENT_COMPILE_OPEN, handleDominoLotusScriptAgentCompileOpen);	
				dispatcher.removeEventListener(EVENT_DOMINO_LOTUSSCRIPT_AGENT_COMPILE_CLOSE, handleDominoFormulaLotusSCriptCompileClose);
				dispatcher.removeEventListener(DominoLotusScriptCompileConnectedEvent.DOMINO_LOTUSSCRIPT_COMPILE_CONNECTED, handleLotusScriptCompileConnected);
				dispatcher.removeEventListener(DominoLotusScriptCompileReturnEvent.DOMINO_LOTUSSCRIPT_COMPILE,handleLotusScriptCompile);
				// if (dominoAgentLotusScriptEditor.dominoViewVisualEditor)
				// {
				// 	dominoAgentLotusScriptEditor.dominoViewVisualEditor.dominoViewPropertyEditor.removeEventListener(Event.CHANGE, onDominoAgentFormulaPropertyChange);
			
				// 	dominoAgentLotusScriptEditor.dominoViewVisualEditor.dominoViewPropertyEditor.removeEventListener(PropertyEditorChangeEvent.PROPERTY_EDITOR_CHANGED, onPropertyEditorChanged);
				// 	dominoAgentLotusScriptEditor.dominoViewVisualEditor.removeEventListener("saveCode", onDominoViewEditorSaveCode);
				// 	dominoAgentLotusScriptEditor.removeEventListener(VisualEditorViewChangeEvent.CODE_CHANGE, onDominoViewCodeChange);

				// }
				
				//dispatcher.removeEventListener(TreeMenuItemEvent.FILE_RENAMED, fileRenamedHandler);

				model.editors.removeEventListener(CollectionEvent.COLLECTION_CHANGE, handleEditorCollectionChange);
				
			}
		}

		private function handleTreeSelectedEvent(event:DominoLotusScriptAgentEditorTreeChangeEvent):void
		{
			
			if(event.selectedTreeNode!=null){
				selectLotusScriptAgentType=event.selectedTreeNode ;
				//options,declarations,initialize,terminate
				if(selectLotusScriptAgentType){
					editor.text=loadingDominoLotusScriptFromAgentFileByKey(selectLotusScriptAgentType);
				}
				
			}
		}

		private function loadingDominoLotusScriptFromAgentFileByKey(keyLabel:String):String 
		{
			var lotusScriptInital:String = "";
			if(file){
				var xmlns:Namespace = new Namespace("http://www.lotus.com/dxl");
   
				var actionString:String=String(file.fileBridge.read());
				var actionXml:XML = new XML(actionString);

				for each(var codeNode:XML in actionXml..code) //no matter of depth Note here
				{
					if(codeNode.@event==keyLabel){
						if(codeNode.text()){
							lotusScriptInital=codeNode.children()[0].text();
						}
					}
				}
				
				if(lotusScriptInital==null || lotusScriptInital==""){
					
					var body:XMLList = actionXml.children();
					for each (var item:XML in body)
					{
						var itemName:String = item.name();
						if (itemName=="http://www.lotus.com/dxl::code" && item.@event==keyLabel)
						{	
							var childbody:XMLList = item.children();
							for each (var childitem:XML in childbody)
							{
								if(childitem.name()=="http://www.lotus.com/dxl::lotusscript")
								{
									lotusScriptInital=childitem.text();
								}
							}
						
							
						}
					}
				}

			
			
				

			}
			
			return lotusScriptInital;
		}

		private function handleDominoLotusScriptAgentCompileOpen(event:Event):void
		{
			dispatcher.addEventListener(DominoLotusScriptCompileConnectedEvent.DOMINO_LOTUSSCRIPT_COMPILE_CONNECTED, handleLotusScriptCompileConnected);
			dispatcher.addEventListener(DominoLotusScriptCompileReturnEvent.DOMINO_LOTUSSCRIPT_COMPILE,handleLotusScriptCompile);
			
			//remove the lotus compile from form objects view	
			dispatcher.dispatchEvent(new Event(DominoObjectsPlugin.EVENT_DOMINO_OBJECTS_UI_CLOSE));
			
			initializeSocket();
		}

		private function handleDominoFormulaLotusSCriptCompileClose(event:Event):void
		{
			dispatcher.removeEventListener(DominoLotusScriptCompileConnectedEvent.DOMINO_LOTUSSCRIPT_COMPILE_CONNECTED, handleLotusScriptCompileConnected);
			dispatcher.removeEventListener(DominoLotusScriptCompileReturnEvent.DOMINO_LOTUSSCRIPT_COMPILE,handleLotusScriptCompile);
				
			
		}	

		private function handleLotusScriptCompileConnected(even:DominoLotusScriptCompileConnectedEvent):void
		{
			compileConnected=even.connectedSuccess;
			
			if(compileConnected==true){
				
				var editorText:String=super.text;
				var agentNode:XML=new XML("<lotusscript>"+editorText+"</lotusscript>");
				var codeNode:XML=new XML("<code event='"+selectLotusScriptAgentType+"'></code>");
				codeNode.appendChild(agentNode);
				editorText=codeNode.toXMLString();
				if(super.text!=null&&super.text.length>0){
					editorText=StringHelper.base64Encode(editorText);
					editorText="compileLotusScriptAgent#"+editorText;
					editorText=editorText+"\r\n";
					compile.sendString(editorText);
				}
			}
			
			
		}

        private function onDominoAgentFormulaPropertyChange(event:Event):void
		{
			updateChangeStatus();
		}

		override public function save():void 
		{

			//selectLotusScriptAgentType
			//StringHelper.base64Encode()
			var actionString:String=String(file.fileBridge.read());
			var lotusScriptAgentXml:XML = new XML(actionString);
			var body:XMLList = lotusScriptAgentXml.children();

			var lotusScriptString:String=StringHelperUtils.fixXmlSpecailCharacter(super.text);
			
			var formulNode:XML=new XML("<lotusscript>"+lotusScriptString+"</lotusscript>");
			var codeNode:XML=new XML("<code event='"+selectLotusScriptAgentType+"'></code>");
			codeNode.appendChild(formulNode);
			for each (var item:XML in body)
			{
				var itemName:String = item.name();
				if (itemName=="http://www.lotus.com/dxl::code" && item.@event==selectLotusScriptAgentType)
				{	
					var parent:XML=item.parent();
					parent.insertChildBefore(item,codeNode);
					delete parent.children()[item.childIndex()];
					
				
				}
			}
			
			var saveText:String = lotusScriptAgentXml.toXMLString();
			needVaildLotusScirpt=saveText;
			if(compileConnected==true){
			}else{
				executeSave(saveText)
			}
			//
			initializeSocket();
			if(compile!=null ){
				compile.closeSocket();
				compile.doConnectAction();
			}

			
		}

		private function executeSave(saveText:String):void{
			if (ConstantsCoreVO.IS_AIR)
			{
				file.fileBridge.save(saveText);
				editor.save();
				super.updateChangeStatus();

			
				// Tell the world we've changed
				dispatcher.dispatchEvent(
					new SaveFileEvent(SaveFileEvent.FILE_SAVED, file, this)
				);
			}if (!ConstantsCoreVO.IS_AIR)
			{
				dispatcher.dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_OUTPUT, file.fileBridge.name +": Saving in process..."));
				super.loader = new DataAgent(URLDescriptorVO.FILE_MODIFY, onSaveSuccess, onSaveFault,
						{path:file.fileBridge.nativePath,saveText:saveText});
			}
		}

		protected function handleLotusScriptCompile(event:DominoLotusScriptCompileReturnEvent):void 
		{
			if(event.compileResult){
				
				if(event.compileResult.length>1){
				
					if(event.compileResult.indexOf("#")){
						var list:Array=event.compileResult.split("#");
						var type:String=StringUtil.trim(list[0]);
						var result:String=null;
						if(type=="compileLotusScriptAgent"){
							result=StringUtil.trim(list[1]);
							if(result=="success"){
								executeSave(needVaildLotusScirpt)
								
							}else{
								var errorLineNumber:int=getErrorLineNumber(result);
								if(errorLineNumber&&errorLineNumber>0){
									if(selectLotusScriptAgentType=="initialize"){
										errorLineNumber=errorLineNumber-7;
										if(errorLineNumber>1){
											errorLineNumber=errorLineNumber-1;
										}
									}else if(selectLotusScriptAgentType=="options"){
										errorLineNumber=errorLineNumber-1;
									}else if(selectLotusScriptAgentType=="declarations"){
										errorLineNumber=errorLineNumber-5;
									}else if(selectLotusScriptAgentType=="terminate"){
										errorLineNumber=errorLineNumber-7;
										if(errorLineNumber>1){
											errorLineNumber=errorLineNumber-1;
										}
									}
								}
								
								//"+errorLineNumber.toString()+"
								var errorLine:String="LotusScript compile error on :\n";
								
								errorLine=errorLine+errorLineNumber.toString();
								//getCorrectDetailsLotusScritpCompileInfo(result);
								
								Alert.show(errorLine);
							}
							
						}else if(type=="convertJavaScriptToDxlRaw"){
							
							
						}else if(type=="compileFormula"){
							
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

		private function onSaveFault(message:String):void
		{
			dispatcher.dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_OUTPUT, file.fileBridge.name +": Save error!"));
			loader = null;
		}
		
		private function onSaveSuccess(value:Object, message:String=null):void
		{
			super.loader = null;
			editor.save();
			updateChangeStatus();
			dispatcher.dispatchEvent(
					new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_OUTPUT, file.fileBridge.name +": Saving successful."));
			dispatcher.dispatchEvent(new SaveFileEvent(SaveFileEvent.FILE_SAVED, file, this));
		}

		private function initializeSocket():void 
		{
			if(compile==null){
				//inital lotus script compile :
				compile=DominoObjectsViewLotusScriptCompile.getInstance();
			}

			
		}

       
    }
}