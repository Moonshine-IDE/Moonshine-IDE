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
    
    import moonshine.editor.text.TextEditor;
    import moonshine.editor.text.events.TextEditorChangeEvent;
    import moonshine.editor.text.syntax.parser.PlainTextLineParser;
	import moonshine.editor.text.events.TextEditorLineEvent;


    import actionScripts.ui.FeathersUIWrapper;
	import flash.events.Event;
	import mx.events.FlexEvent;

    public class DominoViewEditor extends BasicTextEditor  
	{
        private var dominoViewEditor:DominoViewVisualEditor;
        private var visualEditorProject:ProjectVO;
        
        

        public function DominoViewEditor(visualEditorProject:ProjectVO = null)
		{
			this.visualEditorProject = visualEditorProject;
			
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
			
			dominoViewEditor = new DominoViewVisualEditor();
			dominoViewEditor.addEventListener(FlexEvent.CREATION_COMPLETE, onDominoViewEditorCreationComplete);
			dominoViewEditor.percentWidth = 100;
			dominoViewEditor.percentHeight = 100;

			dominoViewEditor.codeEditor = editorWrapper;
		}

		private function onDominoViewEditorCreationComplete(event:FlexEvent):void
		{
			dominoViewEditor.removeEventListener(FlexEvent.CREATION_COMPLETE, onDominoViewEditorCreationComplete);
			dominoViewEditor.dominoViewVisualEditor.visualEditorFilePath = this.currentFile.fileBridge.nativePath;
			dominoViewEditor.dominoViewVisualEditor.loadFile(this.currentFile.fileBridge.nativePath);
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
			dominoViewEditor.dominoViewVisualEditor.loadFile(filePath);
			
		}
    }
}