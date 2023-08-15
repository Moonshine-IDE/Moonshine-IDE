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
    import actionScripts.plugins.help.view.DominoShareColumnEditor;
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

	import actionScripts.plugins.help.view.events.VisualEditorViewChangeEvent;

    public class DominoViewShareColumnEditor extends BasicTextEditor  
	{
        private var dominoShareColumnEditor:DominoShareColumnEditor;
        private var visualEditorProject:ProjectVO;
		private var hasChangedProperties:Boolean;
        
        

        public function DominoViewShareColumnEditor(visualEditorProject:ProjectVO = null)
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
			editor.addEventListener(TextEditorChangeEvent.TEXT_CHANGE, handleTextChange);
			editor.addEventListener(TextEditorLineEvent.TOGGLE_BREAKPOINT, handleToggleBreakpoint);
			editorWrapper = new FeathersUIWrapper(editor);
			editorWrapper.percentHeight = 100;
			editorWrapper.percentWidth = 100;
			text = "";
			
			dominoShareColumnEditor = new DominoShareColumnEditor();
			dominoShareColumnEditor.addEventListener(FlexEvent.CREATION_COMPLETE, onDominoViewEditorCreationComplete);
			
			dominoShareColumnEditor.percentWidth = 100;
			dominoShareColumnEditor.percentHeight = 100;
			dominoShareColumnEditor.addEventListener(VisualEditorViewChangeEvent.CODE_CHANGE, onDominoViewCodeChange);

			dominoShareColumnEditor.codeEditor = editorWrapper;
			model.editors.addEventListener(CollectionEvent.COLLECTION_CHANGE, handleEditorCollectionChange);
			
			
		}
		//dominoViewPropertyEditor
		protected function handleEditorCollectionChange(event:CollectionEvent):void
		{
			if (event.kind == CollectionEventKind.REMOVE && event.items[0] == this)
			{
				dominoShareColumnEditor.removeEventListener(FlexEvent.CREATION_COMPLETE, onDominoViewEditorCreationComplete);
				
				if (dominoShareColumnEditor.dominoViewVisualEditor)
				{
					dominoShareColumnEditor.dominoViewVisualEditor.dominoViewPropertyEditor.removeEventListener(Event.CHANGE, onDominoViewPropertyChange);
			
					dominoShareColumnEditor.dominoViewVisualEditor.dominoViewPropertyEditor.removeEventListener(PropertyEditorChangeEvent.PROPERTY_EDITOR_CHANGED, onPropertyEditorChanged);
					dominoShareColumnEditor.dominoViewVisualEditor.removeEventListener("saveCode", onDominoViewEditorSaveCode);
					dominoShareColumnEditor.removeEventListener(VisualEditorViewChangeEvent.CODE_CHANGE, onDominoViewCodeChange);

				}
				
				//dispatcher.removeEventListener(TreeMenuItemEvent.FILE_RENAMED, fileRenamedHandler);

				model.editors.removeEventListener(CollectionEvent.COLLECTION_CHANGE, handleEditorCollectionChange);
				
			}
		}

		private function onDominoViewCodeChange(event:VisualEditorViewChangeEvent):void
		{
			
			dominoShareColumnEditor.dominoViewVisualEditor.saveEditedFile()
			editor.text=dominoShareColumnEditor.dominoViewVisualEditor.loadDxlFile();
			

			updateChangeStatus()
		}


		private function onDominoViewEditorSaveCode(event:Event):void
		{
            _isChanged = true;
			this.save();
		}
		override public function save():void
		{
			hasChangedProperties = _isChanged = false;
			dominoShareColumnEditor.dominoViewVisualEditor.saveEditedFile();
			dispatchEvent(new Event('labelChanged'));
		
		}

		private function onDominoViewEditorCreationComplete(event:FlexEvent):void
		{
			dominoShareColumnEditor.removeEventListener(FlexEvent.CREATION_COMPLETE, onDominoViewEditorCreationComplete);
			dominoShareColumnEditor.dominoViewVisualEditor.dominoViewPropertyEditor.addEventListener(PropertyEditorChangeEvent.PROPERTY_EDITOR_CHANGED, onPropertyEditorChanged);
			dominoShareColumnEditor.dominoViewVisualEditor.dominoViewPropertyEditor.addEventListener(Event.CHANGE, onDominoViewPropertyChange);
			
			dominoShareColumnEditor.dominoViewVisualEditor.addEventListener("saveCode", onDominoViewEditorSaveCode);
			dominoShareColumnEditor.dominoViewVisualEditor.visualEditorFilePath = this.currentFile.fileBridge.nativePath;
		}
		private function onDominoViewPropertyChange(event:Event):void
		{
			updateChangeStatus();
		}

		override protected function closeTabHandler(event:Event):void
		{
			super.closeTabHandler(event);
			
			if (!dominoShareColumnEditor.dominoViewVisualEditor) return;

			if (model.activeEditor == this)
			{
				dominoShareColumnEditor.dominoViewVisualEditor.dominoViewPropertyEditor.removeEventListener(PropertyEditorChangeEvent.PROPERTY_EDITOR_CHANGED, onPropertyEditorChanged);
				dominoShareColumnEditor.dominoViewVisualEditor.dominoViewPropertyEditor.removeEventListener(Event.CHANGE, onDominoViewPropertyChange);
				
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
					_isChanged = dominoShareColumnEditor.dominoViewVisualEditor.hasChanged;
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
			addElement(dominoShareColumnEditor);
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
			dominoShareColumnEditor.dominoViewVisualEditor.loadFile(filePath);
		}

		public function getFilePath():String {
			return file.fileBridge.nativePath;
		}
    }
}