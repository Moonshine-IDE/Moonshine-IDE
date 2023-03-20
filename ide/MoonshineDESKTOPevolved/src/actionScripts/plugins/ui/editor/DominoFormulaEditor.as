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
	import actionScripts.factory.FileLocation;
	
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.events.SaveFileEvent;
	import actionScripts.valueObjects.URLDescriptorVO;

	import actionScripts.plugin.console.ConsoleOutputEvent;
	import actionScripts.controllers.DataAgent;
	import actionScripts.valueObjects.URLDescriptorVO;

	import actionScripts.utils.TextUtil;

	import actionScripts.ui.FeathersUIWrapper;

	import actionScripts.plugins.help.view.DominoActionVisualEditorView;
	import moonshine.editor.text.events.TextEditorChangeEvent;

	import moonshine.editor.text.TextEditor;
	import actionScripts.ui.editor.BasicTextEditor;
	import moonshine.editor.text.syntax.parser.PlainTextLineParser;
	import moonshine.editor.text.events.TextEditorLineEvent;

	//import actionScripts.plugins.help.view.events.DominoActionPropertyChangeEvent;
	import mx.controls.Alert;
	import actionScripts.utils.DominoUtils;
	public class DominoFormulaEditor extends BasicTextEditor
	{

		private var actionTitle:String = "";
		private var actionShowInMenu:String = "false";
		private var actionShowInBar:String = "false";

		private var actionXmlCache:XML=null;

		private var dominoActionVisualEditorView:DominoActionVisualEditorView;
    
		// public function get dominoActionView():DominoActionVisualEditorView
		// {
		// 	return dominoActionVisualEditorView;
		// }

        public function DominoFormulaEditor()
		{
			super();
        }

		

		override protected function initializeChildrens():void
		{

			if(!editor)
			{
				editor = new TextEditor(null, false);
			}
			if(!editor.parser)
			{
				editor.parser = new PlainTextLineParser();
			}
			editor.addEventListener(TextEditorChangeEvent.TEXT_CHANGE, handleTextChange);
			editor.addEventListener(TextEditorLineEvent.TOGGLE_BREAKPOINT, handleToggleBreakpoint);
			editorWrapper = new FeathersUIWrapper(editor);
			editorWrapper.percentHeight = 100;
			editorWrapper.percentWidth = 100;
			text = "";
			dominoActionVisualEditorView = new DominoActionVisualEditorView();
			//dominoActionVisualEditorView.addEventListener(DominoActionPropertyChangeEvent.PROPERTY_CHANGE, onDominoActionPropertyChange);
		
			dominoActionVisualEditorView.codeEditor = editorWrapper;
		
		}

		 override protected function createChildren():void
		{
			addElement(dominoActionVisualEditorView);
			
			super.createChildren();
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

		/**
		 * For domino action ,it only generate from template file 
		 * So we don't need consider the file not existing case
		 */
		override public function save():void 
		{

			//StringHelper.base64Encode()
			var actionString:String=String(file.fileBridge.read());
			var actionXml:XML = new XML(actionString);
			var sourceTitle:String=actionXml.@title;
			var sourceShowMenu:String=actionXml.@showinmenu;
			var sourceShowBar:String=actionXml.@showinbar;
			for each(var formula:XML in actionXml..formula) //no matter of depth Note here
			{
				if(super.text){
					var encodeBase64:String = TextUtil.base64Encode(super.text);
					var newFormulaNode:XML = new XML("<formula>"+encodeBase64+"</formula>");
					formula.parent().appendChild(newFormulaNode);
					delete formula.parent().children()[formula.childIndex()];
					
				}
			}
			

			//update actionTitle

			if(actionTitle!=""){

				if(actionTitle!=sourceTitle){
					actionXml.@title=actionTitle;
				}

			}

			if(actionShowInBar!=""){ 

				if(actionShowInBar!=sourceShowBar){
					actionXml.@showinbar=actionShowInBar
				}

			}

			if(actionShowInMenu!=""){ 

				if(actionShowInMenu!=sourceShowMenu){
					actionXml.@showinmenu=actionShowInMenu
				}

			}

			var saveText:String = actionXml.toXMLString();

			if (ConstantsCoreVO.IS_AIR)
			{
				file.fileBridge.save(saveText);
				editor.save();
				super.updateChangeStatus();

				//update domino action from dxl
				//updateDominoActionList(actionXml.@title,saveText);
				
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

		// private function updateDominoActionList(actionTitle:String,actionSourceText:String):void 
		// {
		// 	//1.get the domin action dxl file  
		// 	var separator:String= file.fileBridge.separator;
		// 	var actionDxlFolderPath:String=file.fileBridge.parent.fileBridge.parent.fileBridge.parent.fileBridge.nativePath+separator+"Code"+separator+"actions";
		// 	var actionFolderPath:FileLocation=new FileLocation(actionDxlFolderPath);
		// 	if(!actionFolderPath.fileBridge.exists){
		// 		actionFolderPath.fileBridge.createDirectory();
		// 	} 
		// 	var actionDxlPath:String = actionFolderPath.fileBridge.nativePath+separator+"Shared Actions";
		// 	var actionDxl:FileLocation=new FileLocation(actionDxlPath); 
		// 	if(!actionDxl.fileBridge.exists){
		// 			//actionDxl.fileBridge.save(DominoUtils.getDominActionDxlTemplate());
		// 	}
		// 	var actionString:String=String(actionDxl.fileBridge.read());
		// 	var	actionDxlCache:XML = new XML(actionString);
		// 	var actionSourceXml:XML= new XML(actionSourceText);

		// 	for each(var formulaXMLNode:XML in actionSourceXml..formula) //no matter of depth Note here
		// 	{
		// 		if(formulaXMLNode.text()){

		// 			var decodeBase64: String =  TextUtil.base64Decode(formulaXMLNode.text());
		// 			var newFormulaNode:XML = new XML("<formula>"+decodeBase64+"</formula>");
		// 			formulaXMLNode.parent().appendChild(newFormulaNode);
		// 			delete formulaXMLNode.parent().children()[formulaXMLNode.childIndex()];
		// 		}
		// 	}

			
		// 	var actionFlag:Boolean = false;
		// 	var idCount:Number=1;
		// 	for each(var action:XML in actionDxlCache..action)
		// 	{
		// 		if(actionTitle==action.@title){
		// 			actionSourceXml.@id=action.@id;
		// 			action.parent().appendChild(actionSourceXml);
		// 			delete action.parent().children()[action.childIndex()];
		// 			actionFlag=true;
		// 		}
		// 		idCount++;
										
		// 	}
			
		// 	if(actionFlag==false){
		// 		actionSourceXml.@id=idCount;
				
		// 		for each(var shareaction:XML in actionDxlCache..sharedactions)
		// 		{
					
		// 			shareaction.appendChild(actionSourceXml);
		// 		}
			
		// 	}

			
		// 	//actionDxlCache.@xmlns='http://www.lotus.com/dxl';
		
		// 	actionDxl.fileBridge.save(actionDxlCache.toXMLString());


		// }

		

		private function onSaveFault(message:String):void
		{
			//Alert.show("Save Fault"+message);
			dispatcher.dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_OUTPUT, file.fileBridge.name +": Save error!"));
			loader = null;
		}
		
		private function onSaveSuccess(value:Object, message:String=null):void
		{
			//Alert.show("Save Fault"+message);
			super.loader = null;
			editor.save();
			updateChangeStatus();
			dispatcher.dispatchEvent(
					new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_OUTPUT, file.fileBridge.name +": Saving successful."));
			dispatcher.dispatchEvent(new SaveFileEvent(SaveFileEvent.FILE_SAVED, file, this));
		}

		public function setEdited(value:Boolean):void 
		{
			_isChanged=value;

		}

		private function onDominoActionPropertyChange(event:Event):void
		{
			//updateChangeStatus();
		}

		public function updateTitle(title:String):void
		{
			if(title!=actionTitle){
				actionTitle=title;
				super._isChanged=true;
				dispatchEvent(new Event('labelChanged'));
			}
		}

		public function updateBar(bar:String):void
		{
			if(bar!=actionShowInBar){
				actionShowInBar=bar;
				super._isChanged=true;
				dispatchEvent(new Event('labelChanged'));
			}
		}
		public function updateMenu(menu:String):void
		{
			if(menu!=actionShowInMenu){
				actionShowInMenu=menu;
				super._isChanged=true;
				
				dispatchEvent(new Event('labelChanged'));
			}
		}



		public function getTitle():String
		{
			if(actionXmlCache==null){
				var actionString:String=String(file.fileBridge.read());
				actionXmlCache = new XML(actionString);
			}
			
			var sourceTitle:String=actionXmlCache.@title;

			return sourceTitle;
		}
		public function getShowinmenu():String
		{
			if(actionXmlCache==null){
				var actionString:String=String(file.fileBridge.read());
				actionXmlCache = new XML(actionString);
			}
			
			var source:String=actionXmlCache.@showinmenu;

			return source;
		}
		public function getShowinbar():String
		{
			if(actionXmlCache==null){
				var actionString:String=String(file.fileBridge.read());
				actionXmlCache = new XML(actionString);
			}
			
			var source:String=actionXmlCache.@showinbar;

			return source;
		}

		// override protected function removedFromStageHandler(event:Event):void
		// {
		// 	this.removeGlobalListeners();
		// 	dispatcher.removeEventListener(DominoActionPropertyChangeEvent.PROPERTY_CHANGE, onDominoActionPropertyChange);
		// }

	
		


		
       

       




    }
}