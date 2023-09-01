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
    import actionScripts.ui.editor.BasicTextEditor;
    import actionScripts.plugins.help.view.DominoViewVisualEditor;
    import actionScripts.valueObjects.ProjectVO;
	
	import view.suportClasses.events.PropertyEditorChangeEvent;
    
    import moonshine.editor.text.TextEditor;
    import moonshine.editor.text.events.TextEditorChangeEvent;
    import moonshine.editor.text.syntax.parser.PlainTextLineParser;
	import moonshine.editor.text.events.TextEditorLineEvent;


    import actionScripts.ui.FeathersUIWrapper;
	import flash.events.Event;
	import mx.events.FlexEvent;
	import mx.controls.Alert;

	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import actionScripts.impls.IVisualEditorLibraryBridgeImp;
	import actionScripts.plugins.help.view.events.VisualEditorViewChangeEvent;
	import view.suportClasses.events.DominoViewUpdateEvent;
	import view.suportClasses.events.DominoSharedColumnUpdateViewEvent;
	import actionScripts.events.GlobalEventDispatcher;
    public class DominoViewEditor extends BasicTextEditor  
	{
        private var dominoViewEditor:DominoViewVisualEditor;
        private var visualEditorProject:ProjectVO;
		private var hasChangedProperties:Boolean;
        private var visualEditoryLibraryCore:IVisualEditorLibraryBridgeImp;
        

        public function DominoViewEditor(visualEditorProject:ProjectVO = null)
		{
			this.visualEditorProject = visualEditorProject;
			
			super();
		}

        override protected function initializeChildrens():void
		{
			if(!editor)
			{
				editor = new TextEditor(null, true);
			}
			if(!editor.parser)
			{
				editor.parser = new PlainTextLineParser();
			}

			visualEditoryLibraryCore = new IVisualEditorLibraryBridgeImp();
			visualEditoryLibraryCore.visualEditorProject = visualEditorProject;

			editor.addEventListener(TextEditorChangeEvent.TEXT_CHANGE, handleTextChange);
			editor.addEventListener(TextEditorLineEvent.TOGGLE_BREAKPOINT, handleToggleBreakpoint);
			editorWrapper = new FeathersUIWrapper(editor);
			editorWrapper.percentHeight = 100;
			editorWrapper.percentWidth = 100;
			text = "";
			
			dominoViewEditor = new DominoViewVisualEditor();
			dominoViewEditor.addEventListener(FlexEvent.CREATION_COMPLETE, onDominoViewEditorCreationComplete);
			
			dominoViewEditor.percentWidth = 100;
			dominoViewEditor.percentHeight = 100;
			dominoViewEditor.addEventListener(VisualEditorViewChangeEvent.CODE_CHANGE, onDominoViewCodeChange);
			dominoViewEditor.codeEditor = editorWrapper;
			model.editors.addEventListener(CollectionEvent.COLLECTION_CHANGE, handleEditorCollectionChange);
			
			
		}
		//dominoViewPropertyEditor
		protected function handleEditorCollectionChange(event:CollectionEvent):void
		{
			if (event.kind == CollectionEventKind.REMOVE && event.items[0] == this)
			{
				dominoViewEditor.removeEventListener(FlexEvent.CREATION_COMPLETE, onDominoViewEditorCreationComplete);
				
				if (dominoViewEditor.dominoViewVisualEditor)
				{
					dominoViewEditor.dominoViewVisualEditor.dominoViewPropertyEditor.removeEventListener(Event.CHANGE, onDominoViewPropertyChange);
			
					dominoViewEditor.dominoViewVisualEditor.dominoViewPropertyEditor.removeEventListener(PropertyEditorChangeEvent.PROPERTY_EDITOR_CHANGED, onPropertyEditorChanged);
					dominoViewEditor.dominoViewVisualEditor.removeEventListener("saveCode", onDominoViewEditorSaveCode);
					dominoViewEditor.removeEventListener(VisualEditorViewChangeEvent.CODE_CHANGE, onDominoViewCodeChange);

				}
				
				//dispatcher.removeEventListener(TreeMenuItemEvent.FILE_RENAMED, fileRenamedHandler);

				model.editors.removeEventListener(CollectionEvent.COLLECTION_CHANGE, handleEditorCollectionChange);
				
			}
		}

		private function onDominoViewCodeChange(event:VisualEditorViewChangeEvent):void
		{
			
			dominoViewEditor.dominoViewVisualEditor.saveEditedFile()
			editor.text=dominoViewEditor.dominoViewVisualEditor.loadDxlFile();
			

			updateChangeStatus()
		}

		private function onDominoViewUpdateAndRoload(event:DominoSharedColumnUpdateViewEvent):void 
		{
			if(event.viewFilePath==file.fileBridge.nativePath){
				openLoadingFile(event.viewFilePath);
			}
			
		}


		private function onDominoViewEditorSaveCode(event:Event):void
		{
            _isChanged = true;
			this.save();
		}
		override public function save():void
		{
			hasChangedProperties = _isChanged = false;
			dominoViewEditor.dominoViewVisualEditor.saveEditedFile();
			dispatchEvent(new Event('labelChanged'));
		
		}

		private function onDominoViewEditorCreationComplete(event:FlexEvent):void
		{
			dominoViewEditor.removeEventListener(FlexEvent.CREATION_COMPLETE, onDominoViewEditorCreationComplete);
			dominoViewEditor.dominoViewVisualEditor.dominoViewPropertyEditor.addEventListener(PropertyEditorChangeEvent.PROPERTY_EDITOR_CHANGED, onPropertyEditorChanged);
			dominoViewEditor.dominoViewVisualEditor.dominoViewPropertyEditor.addEventListener(Event.CHANGE, onDominoViewPropertyChange);
			
			dominoViewEditor.dominoViewVisualEditor.addEventListener("saveCode", onDominoViewEditorSaveCode);
			dominoViewEditor.dominoViewVisualEditor.visualEditorFilePath = this.currentFile.fileBridge.nativePath;
			dominoViewEditor.dominoViewVisualEditor.moonshineBridge = visualEditoryLibraryCore;
			
			GlobalEventDispatcher.getInstance().addEventListener(DominoSharedColumnUpdateViewEvent.VIEW_UPDATE_AND_RELOAD,onDominoViewUpdateAndRoload);
		
		}
		private function onDominoViewPropertyChange(event:Event):void
		{
			updateChangeStatus();
		}

		override protected function closeTabHandler(event:Event):void
		{
			super.closeTabHandler(event);
			
			if (!dominoViewEditor.dominoViewVisualEditor) return;

			if (model.activeEditor == this)
			{
				dominoViewEditor.dominoViewVisualEditor.dominoViewPropertyEditor.removeEventListener(PropertyEditorChangeEvent.PROPERTY_EDITOR_CHANGED, onPropertyEditorChanged);
				dominoViewEditor.dominoViewVisualEditor.dominoViewPropertyEditor.removeEventListener(Event.CHANGE, onDominoViewPropertyChange);
				GlobalEventDispatcher.getInstance().removeEventListener(DominoSharedColumnUpdateViewEvent.VIEW_UPDATE_AND_RELOAD,onDominoViewUpdateAndRoload);
				//SharedObjectUtil.removeLocationOfEditorFile(model.activeEditor);
			}
		}
		override protected function updateChangeStatus():void
		{
			if (hasChangedProperties)
			{
				_isChanged = true;
			}
			else
			{
				_isChanged = editor.edited;
				if (!_isChanged)
				{
					_isChanged = dominoViewEditor.dominoViewVisualEditor.hasChanged;
				}
			}
			
			dispatchEvent(new Event('labelChanged'));
		}

		private function onPropertyEditorChanged(event:PropertyEditorChangeEvent):void
		{
			hasChangedProperties = _isChanged = true;
			dispatchEvent(new Event('labelChanged'));
		}

        override protected function createChildren():void
		{
			addElement(dominoViewEditor);
			super.createChildren();
		}


		override protected function openHandler(event:Event):void
		{
			super.openHandler(event);
			var filePath:String = file.fileBridge.nativePath;
			
			openLoadingFile(filePath);
			
		}


		public function openLoadingFile(filePath:String):void
		{
			dominoViewEditor.dominoViewVisualEditor.loadFile(filePath);
		}

		public function getFilePath():String {
			return file.fileBridge.nativePath;
		}
    }
}