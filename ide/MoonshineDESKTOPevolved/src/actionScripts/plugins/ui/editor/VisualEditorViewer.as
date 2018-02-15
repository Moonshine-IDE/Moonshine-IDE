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
    import flash.events.Event;
    import flash.filesystem.File;
    
    import mx.events.FlexEvent;
    
    import actionScripts.events.AddTabEvent;
    import actionScripts.events.ChangeEvent;
    import actionScripts.interfaces.IVisualEditorViewer;
    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
    import actionScripts.plugins.help.view.VisualEditorView;
    import actionScripts.plugins.help.view.events.VisualEditorViewChangeEvent;
    import actionScripts.ui.editor.BasicTextEditor;
    import actionScripts.ui.editor.text.TextEditor;
    import actionScripts.ui.tabview.CloseTabEvent;
    import actionScripts.ui.tabview.TabEvent;

    import utils.VisualEditorType;

    public class VisualEditorViewer extends BasicTextEditor implements IVisualEditorViewer
    {
        private var visualEditorView:VisualEditorView;
        private var hasChangedProperties:Boolean;

        private var visualEditorProject:AS3ProjectVO;
        
        public function VisualEditorViewer(visualEditorProject:AS3ProjectVO = null)
        {
            this.visualEditorProject = visualEditorProject;

            super();
        }

        override protected function initializeChildrens():void
        {
            isVisualEditor = true;
            
            visualEditorView = new VisualEditorView();
            visualEditorProject.isPrimeFacesVisualEditorProject ?
            VisualEditorType.setInstance(VisualEditorType.PRIME_FACES) :
            VisualEditorType.setInstance(VisualEditorType.FLEX);
            visualEditorView.percentWidth = 100;
            visualEditorView.percentHeight = 100;
            visualEditorView.addEventListener(FlexEvent.CREATION_COMPLETE, onVisualEditorCreationComplete);
            visualEditorView.addEventListener(VisualEditorViewChangeEvent.CODE_CHANGE, onVisualEditorViewCodeChange);

            editor = new TextEditor(true);
            editor.percentHeight = 100;
            editor.percentWidth = 100;
            editor.addEventListener(ChangeEvent.TEXT_CHANGE, handleTextChange);
            editor.dataProvider = "";

            visualEditorView.codeEditor = editor;
            
            dispatcher.addEventListener(AddTabEvent.EVENT_ADD_TAB, onTabAdd);
            dispatcher.addEventListener(CloseTabEvent.EVENT_CLOSE_TAB, onTabOpenClose);
            dispatcher.addEventListener(TabEvent.EVENT_TAB_SELECT, onTabSelect);
        }

        private function onVisualEditorCreationComplete(event:FlexEvent):void
        {
            visualEditorView.removeEventListener(FlexEvent.CREATION_COMPLETE, onVisualEditorCreationComplete);
            visualEditorView.visualEditor.editingSurface.addEventListener(Event.CHANGE, onEditingSurfaceChange);
            visualEditorView.visualEditor.propertyEditor.addEventListener("propertyEditorChanged", onPropertyEditorChanged);
        }

        private function onVisualEditorViewCodeChange(event:VisualEditorViewChangeEvent):void
        {
            editor.dataProvider = getMxmlCode();

            updateChangeStatus()
        }

        override protected function createChildren():void
        {
            addElement(visualEditorView);
            
            super.createChildren();
        }

        override public function save():void
        {
            visualEditorView.visualEditor.saveEditedFile();
            editor.dataProvider = getMxmlCode();
            hasChangedProperties = false;

            super.save();
        }

        override protected function openHandler(event:Event):void
        {
            super.openHandler(event);

            createVisualEditorFile();
        }

        override protected function updateChangeStatus():void
        {
            if (hasChangedProperties)
            {
                _isChanged = true;
            }
            else
            {
                _isChanged = editor.hasChanged;
                if (!_isChanged)
                {
                    _isChanged = visualEditorView.visualEditor.editingSurface.hasChanged;
                }
            }
            
            dispatchEvent(new Event('labelChanged'));
        }

        private function onEditingSurfaceChange(event:Event):void
        {
            updateChangeStatus();
        }

        private function onPropertyEditorChanged(event:Event):void
        {
            hasChangedProperties = _isChanged = true;
            dispatchEvent(new Event('labelChanged'));
        }

        private function onTabAdd(event:Event):void
        {
            if (!visualEditorView.visualEditor) return;

            visualEditorView.visualEditor.editingSurface.selectedItem = null;
        }

        private function onTabOpenClose(event:Event):void
        {
            if (!visualEditorView.visualEditor) return;
            
			if (event is CloseTabEvent)
			{
				var tmpEvent:CloseTabEvent = event as CloseTabEvent;
	            if (tmpEvent.tab.hasOwnProperty("editor") && tmpEvent.tab["editor"] == this.editor)
	            {
	                visualEditorView.visualEditor.editingSurface.removeEventListener(Event.CHANGE, onEditingSurfaceChange);
	                visualEditorView.visualEditor.propertyEditor.removeEventListener("propertyEditorChanged", onPropertyEditorChanged);
	                visualEditorView.visualEditor.editingSurface.selectedItem = null;
	            }
			}
        }

        private function onTabSelect(event:TabEvent):void
        {
            if (!visualEditorView.visualEditor) return;

            if (!event.child.hasOwnProperty("editor") || event.child["editor"] != this.editor)
            {
                visualEditorView.visualEditor.editingSurface.selectedItem = null;
            }
        }

        private function getMxmlCode():String
        {
            var mxmlCode:XML = visualEditorView.visualEditor.editingSurface.toMXML();
            var markAsXml:String = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n";
            
            return markAsXml + mxmlCode.toXMLString();
        }

        private function createVisualEditorFile():void
        {
            var veFilePath:String = getVisualEditorFilePath();
            if (veFilePath)
            {
                visualEditorView.visualEditor.loadFile(veFilePath);
            }
        }

        private function getVisualEditorFilePath():String
        {
            var splittedFileName:Array = file.fileBridge.name.split(".");

            if (splittedFileName.length == 2)
            {
                var cleanFileName:String = splittedFileName[0];
                if (visualEditorProject.visualEditorSourceFolder)
                {
                    return visualEditorProject.visualEditorSourceFolder
                            .fileBridge.nativePath
                            .concat(File.separator, cleanFileName, ".xml");
                }
            }

            return null;
        }
    }
}
