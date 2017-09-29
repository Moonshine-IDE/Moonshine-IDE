////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugins.ui.editor
{
    import actionScripts.events.ChangeEvent;
    import actionScripts.interfaces.IVisualEditorViewer;
    import actionScripts.plugins.help.view.VisualEditorView;
    import actionScripts.plugins.help.view.events.VisualEditorViewChangeEvent;
    import actionScripts.ui.editor.*;
    import actionScripts.ui.editor.text.TextEditor;

    public class VisualEditorViewer extends BasicTextEditor implements IVisualEditorViewer
    {
        private var visualEditorView:VisualEditorView;
        
        public function VisualEditorViewer()
        {
            super();
        }

        override protected function initializeChildrens():void
        {
            isVisualEditor = true;
            
            visualEditorView = new VisualEditorView();
            visualEditorView.percentWidth = 100;
            visualEditorView.percentHeight = 100;
            visualEditorView.addEventListener(VisualEditorViewChangeEvent.CODE_CHANGE, onVisualEditorViewCodeChange);
            visualEditorView.addEventListener(VisualEditorViewChangeEvent.VISUAL_CHANGE, onVisualEditorViewVisualChange);

            editor = new TextEditor(true);
            editor.percentHeight = 100;
            editor.percentWidth = 100;
            editor.addEventListener(ChangeEvent.TEXT_CHANGE, handleTextChange);
            editor.dataProvider = "";

            visualEditorView.codeEditor = editor;
        }

        private function onVisualEditorViewVisualChange(event:VisualEditorViewChangeEvent):void
        {
            
        }

        private function onVisualEditorViewCodeChange(event:VisualEditorViewChangeEvent):void
        {
            var mxmlCode:XML = visualEditorView.visualEditor.editingSurface.toMXML();
            var mxmlCodeList:XMLList = mxmlCode.children();

            var mxmlEditor:XML = new XML(editor.dataProvider);
            mxmlEditor.setChildren("");

            for each (var child:XML in mxmlCodeList)
            {
                mxmlEditor.appendChild(child);
            }

            var markAsXml:String = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n";
            var xmlString:String = markAsXml + mxmlEditor.toXMLString();

            editor.dataProvider = xmlString;

            _isChanged = visualEditorView.visualEditor.editingSurface.hasChanged;
        }

        override protected function createChildren():void
        {
            addElement(visualEditorView);
            
            super.createChildren();
        }
    }
}
