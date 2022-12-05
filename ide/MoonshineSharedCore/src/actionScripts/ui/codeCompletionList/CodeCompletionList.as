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
