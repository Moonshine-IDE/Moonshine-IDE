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
package actionScripts.ui.codeCompletionList
{
    import actionScripts.events.GlobalEventDispatcher;
    import actionScripts.ui.codeCompletionList.renderers.CodeCompletionItemRenderer;
    import actionScripts.utils.KeyboardShortcutManager;
    import actionScripts.valueObjects.KeyboardShortcut;
    import actionScripts.valueObjects.Settings;

    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;

    import mx.core.ClassFactory;
    import mx.events.CloseEvent;
    import mx.managers.PopUpManager;

    import spark.components.List;
    import spark.filters.DropShadowFilter;
    import spark.layouts.HorizontalAlign;
    import spark.layouts.VerticalLayout;

    public class CodeCompletionList extends List
    {
        private var codeDocumentationPopup:CodeDocumentationPopup;
        private var keyboardShortcutManager:KeyboardShortcutManager;

        private var previousSelectedIndex:int;

        public function CodeCompletionList()
        {
            super();

            this.keyboardShortcutManager = KeyboardShortcutManager.getInstance();
            this.styleName = "completionList";
            this.itemRenderer = new ClassFactory(CodeCompletionItemRenderer);
            this.labelField = "label";
            this.minWidth = 350;
            this.maxWidth = 650;
            
            var layout:VerticalLayout = new VerticalLayout();
            layout.requestedMaxRowCount = 8;
            layout.gap = 0;
            layout.horizontalAlign = HorizontalAlign.CONTENT_JUSTIFY;
            layout.useVirtualLayout = true;
            layout.rowHeight = 22;
            layout.variableRowHeight = false;
            this.layout = layout;
            this.doubleClickEnabled = true;
            this.filters = [new DropShadowFilter(3, 90, 0, 0.2, 8, 8)];

            this.addEventListener(Event.ADDED_TO_STAGE, onCodeCompletionListAddedToStage);
            this.addEventListener(Event.REMOVED_FROM_STAGE, onCodeCompletionListRemovedFromStage);
            this.addEventListener(KeyboardEvent.KEY_UP, onCodeCompletionListKeyDown);
        }

        override public function setSelectedIndex(rowIndex:int, dispatchChangeEvent:Boolean = false, changeCaret:Boolean = true):void
        {
            previousSelectedIndex = selectedIndex;
            super.setSelectedIndex(rowIndex, dispatchChangeEvent, changeCaret);
        }

        public function closeDocumentation():void
        {
            if (codeDocumentationPopup)
            {
                PopUpManager.removePopUp(codeDocumentationPopup);
                codeDocumentationPopup.removeEventListener(CloseEvent.CLOSE, onCodeDocumentationPopupClose);
                codeDocumentationPopup.data = null;
                codeDocumentationPopup = null;
            }
        }

        private function onCodeCompletionListAddedToStage(event:Event):void
        {
            GlobalEventDispatcher.getInstance().addEventListener("showDocumentation", onCodeCompletionListShowDocumentation);
            activateShortcuts();
        }

        private function onCodeCompletionListRemovedFromStage(event:Event):void
        {
            GlobalEventDispatcher.getInstance().removeEventListener("showDocumentation", onCodeCompletionListShowDocumentation);
            deactivateShortcuts();
        }

        private function onCodeCompletionListShowDocumentation(event:Event):void
        {
            if (selectedItem && selectedItem.documentation)
            {
                if (!codeDocumentationPopup)
                {
                    codeDocumentationPopup = new CodeDocumentationPopup();
                    codeDocumentationPopup.addEventListener(CloseEvent.CLOSE, onCodeDocumentationPopupClose);
                }

                if (codeDocumentationPopup.data != this.selectedItem)
                {
                    codeDocumentationPopup.data = this.selectedItem;
                    PopUpManager.addPopUp(codeDocumentationPopup, this);

                    codeDocumentationPopup.maxWidth = 350;
                    codeDocumentationPopup.maxHeight = 300;
                    codeDocumentationPopup.x = this.x + this.width;
                    codeDocumentationPopup.y = this.y;
                }
                else
                {
                    PopUpManager.removePopUp(codeDocumentationPopup);
                    codeDocumentationPopup.data = null;
                }
            }
        }

        private function onCodeDocumentationPopupClose(event:CloseEvent):void
        {
            PopUpManager.removePopUp(codeDocumentationPopup);
            codeDocumentationPopup.data = null;
        }

        private function activateShortcuts():void
        {
            if (Settings.os == "win")
            {
                this.keyboardShortcutManager.activate(new KeyboardShortcut("showDocumentation", "q", [Keyboard.CONTROL]));
            }
            else
            {
                this.keyboardShortcutManager.activate(new KeyboardShortcut("showDocumentation", "F1", [Keyboard.F1]));
            }
        }

        private function onCodeCompletionListKeyDown(event:KeyboardEvent):void
        {
            if (event.keyCode == Keyboard.UP)
            {
                if (isFirstRow && previousSelectedIndex == 0)
                {
                    selectedIndex = dataProvider.length - 1;
                    ensureIndexIsVisible(selectedIndex);
                }
            }
            else if (event.keyCode == Keyboard.DOWN)
            {
                if (isLastRow && previousSelectedIndex == dataProvider.length - 1)
                {
                    selectedIndex = 0;
                    ensureIndexIsVisible(0);
                }
            }
        }

        private function deactivateShortcuts():void
        {
            if (Settings.os == "win")
            {
                this.keyboardShortcutManager.deactivate(new KeyboardShortcut("showDocumentation", "q", [Keyboard.CONTROL]));
            }
            else
            {
                this.keyboardShortcutManager.deactivate(new KeyboardShortcut("showDocumentation", "F1", [Keyboard.F1]));
            }
        }
    }
}
