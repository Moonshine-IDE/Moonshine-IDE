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

	import actionScripts.plugins.help.view.DominoAgentFormulaVisualEditor;
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
	import mx.events.CollectionEventKind;
	             
    public class DominoAgentFormulaEditor extends BasicTextEditor  
	{

		private var dominoAgentFormulaEditor:DominoAgentFormulaVisualEditor;
    	private var visualEditorProject:ProjectVO;
		private var hasChangedProperties:Boolean;

        public function DominoAgentFormulaEditor(visualEditorProject:ProjectVO = null){
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
			editorWrapper = new FeathersUIWrapper(editor);
			editorWrapper.percentHeight = 100;
			editorWrapper.percentWidth = 100;
			text = "";
			
			dominoAgentFormulaEditor = new DominoAgentFormulaVisualEditor();
			dominoAgentFormulaEditor.addEventListener(FlexEvent.CREATION_COMPLETE, onDominoAgentFormulaEditorCreationComplete);
			
			dominoAgentFormulaEditor.percentWidth = 100;
			dominoAgentFormulaEditor.percentHeight = 100;
			//dominoAgentFormulaEditor.addEventListener(VisualEditorViewChangeEvent.CODE_CHANGE, onDominoAgentFormulaCodeChange);

			dominoAgentFormulaEditor.codeEditor = editorWrapper;
			model.editors.addEventListener(CollectionEvent.COLLECTION_CHANGE, handleEditorCollectionChange);
			
			
		}

        private function onDominoAgentFormulaEditorCreationComplete(event:FlexEvent):void
		{
			//dominoAgentFormulaEditor.removeEventListener(FlexEvent.CREATION_COMPLETE, onDominoViewEditorCreationComplete);
			//dominoAgentFormulaEditor.dominoViewVisualEditor.dominoViewPropertyEditor.addEventListener(PropertyEditorChangeEvent.PROPERTY_EDITOR_CHANGED, onPropertyEditorChanged);
			//dominoAgentFormulaEditor.dominoViewVisualEditor.dominoViewPropertyEditor.addEventListener(Event.CHANGE, onDominoAgentFormulaPropertyChange);
			
			//dominoAgentFormulaEditor.dominoViewVisualEditor.addEventListener("saveCode", onDominoViewEditorSaveCode);
			//dominoAgentFormulaEditor.dominoViewVisualEditor.visualEditorFilePath = this.currentFile.fileBridge.nativePath;
			
		}

        // private function onDominoAgentFormulaCodeChange(event:VisualEditorViewChangeEvent):void
		// {
			
		// 	var xmlStr:String="<?xml version=\"1.0\" encoding=\"utf-8\"?>"+"\r\n";
		// 	var xmlView:XML=dominoAgentFormulaEditor.dominoViewVisualEditor.getSavedXMLFromMemoryObject();
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
			addElement(dominoAgentFormulaEditor);
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
		// 	//dominoAgentFormulaEditor.dominoViewVisualEditor.loadFile(filePath);
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
				// dominoAgentFormulaEditor.removeEventListener(FlexEvent.CREATION_COMPLETE, onDominoViewEditorCreationComplete);
				
				// if (dominoAgentFormulaEditor.dominoViewVisualEditor)
				// {
				// 	dominoAgentFormulaEditor.dominoViewVisualEditor.dominoViewPropertyEditor.removeEventListener(Event.CHANGE, onDominoAgentFormulaPropertyChange);
			
				// 	dominoAgentFormulaEditor.dominoViewVisualEditor.dominoViewPropertyEditor.removeEventListener(PropertyEditorChangeEvent.PROPERTY_EDITOR_CHANGED, onPropertyEditorChanged);
				// 	dominoAgentFormulaEditor.dominoViewVisualEditor.removeEventListener("saveCode", onDominoViewEditorSaveCode);
				// 	dominoAgentFormulaEditor.removeEventListener(VisualEditorViewChangeEvent.CODE_CHANGE, onDominoViewCodeChange);

				// }
				
				//dispatcher.removeEventListener(TreeMenuItemEvent.FILE_RENAMED, fileRenamedHandler);

				//model.editors.removeEventListener(CollectionEvent.COLLECTION_CHANGE, handleEditorCollectionChange);
				
			}
		}

        private function onDominoAgentFormulaPropertyChange(event:Event):void
		{
			updateChangeStatus();
		}

       
    }
}