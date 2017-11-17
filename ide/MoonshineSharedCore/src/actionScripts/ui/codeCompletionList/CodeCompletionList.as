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
    import actionScripts.ui.codeCompletionList.renderers.CodeCompletionItemRenderer;

    import flash.events.Event;

    import mx.core.ClassFactory;
    import mx.events.CloseEvent;
    import mx.managers.PopUpManager;

    import spark.components.List;
    import spark.filters.DropShadowFilter;
    import spark.layouts.HorizontalAlign;
    import spark.layouts.VerticalLayout;

    public class CodeCompletionList extends List
    {
        private var _codeDocumentationPopup:CodeDocumentationPopup;
        
        public function CodeCompletionList()
        {
            super();

            this.styleName = "completionList";
            this.itemRenderer = new ClassFactory(CodeCompletionItemRenderer);
            this.labelField = "labelWithPrefix";
            this.minWidth = 350;

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

            this.addEventListener("showDocumentation", onCodeCompletionListShowDocumentation);
        }

        public function closeDocumentation():void
        {
            if (_codeDocumentationPopup)
            {
                PopUpManager.removePopUp(_codeDocumentationPopup);
                _codeDocumentationPopup.removeEventListener(CloseEvent.CLOSE, onCodeDocumentationPopupClose);
                _codeDocumentationPopup.data = null;
                _codeDocumentationPopup = null;
            }
        }

        private function onCodeCompletionListShowDocumentation(event:Event):void
        {
            event.stopImmediatePropagation();

            if (selectedItem && selectedItem.documentation)
            {
                if (!_codeDocumentationPopup)
                {
                    _codeDocumentationPopup = new CodeDocumentationPopup();
                    _codeDocumentationPopup.addEventListener(CloseEvent.CLOSE, onCodeDocumentationPopupClose);
                }

                if (_codeDocumentationPopup.data != this.selectedItem)
                {
                    _codeDocumentationPopup.data = this.selectedItem;
                    PopUpManager.addPopUp(_codeDocumentationPopup, this);

                    _codeDocumentationPopup.maxWidth = 350;
                    _codeDocumentationPopup.maxHeight = 300;
                    _codeDocumentationPopup.x = this.x + this.width;
                    _codeDocumentationPopup.y = this.y;
                }
                else
                {
                    PopUpManager.removePopUp(_codeDocumentationPopup);
                    _codeDocumentationPopup.data = null;
                }
            }
        }

        private function onCodeDocumentationPopupClose(event:CloseEvent):void
        {
            PopUpManager.removePopUp(_codeDocumentationPopup);
            _codeDocumentationPopup.data = null;
        }
    }
}
