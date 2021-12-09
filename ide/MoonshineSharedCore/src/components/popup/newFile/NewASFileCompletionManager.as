////////////////////////////////////////////////////////////////////////////////
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0 
// 
// Unless required by applicable law or agreed to in writing, software 
// distributed under the License is distributed on an "AS IS" BASIS, 
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and 
// limitations under the License
// 
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
// 
////////////////////////////////////////////////////////////////////////////////
package components.popup.newFile
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.ui.Keyboard;

    import mx.collections.ArrayCollection;
    import mx.events.CloseEvent;
    import mx.managers.PopUpManager;

    import spark.components.TitleWindow;

    import actionScripts.events.GlobalEventDispatcher;
    import actionScripts.ui.codeCompletionList.CodeCompletionList;
    import actionScripts.utils.symbolKindToCompletionItemKind;
    import actionScripts.valueObjects.ProjectVO;
    import actionScripts.valueObjects.SymbolKind;

    import moonshine.lsp.CompletionItem;
    import moonshine.lsp.DocumentSymbol;
    import moonshine.lsp.SymbolInformation;
    import actionScripts.languageServer.LanguageServerProjectVO;

    [Event(name="itemSelected", type="flash.events.Event")]
    public class NewASFileCompletionManager extends EventDispatcher
    {
        private static const CLASSES_LIST:String = "classesList";
        private static const INTERFACES_LIST:String = "interfacesList";
        private static const NO_PACKAGE:String = "No Package";

        protected var dispatcher:EventDispatcher = GlobalEventDispatcher.getInstance();

        private var view:TitleWindow;
        private var project:ProjectVO;

        private var completionList:CodeCompletionList;
        private var menuCollection:ArrayCollection;

        private var completionListType:String;

        public function NewASFileCompletionManager(view:TitleWindow, project:ProjectVO)
        {
            this.view = view;
            this.project = project;

            completionList = new CodeCompletionList();
            completionList.requireSelection = true;
            completionList.width = 574;
            menuCollection = new ArrayCollection();
            completionList.dataProvider = menuCollection;

            view.addEventListener(MouseEvent.CLICK, onViewClick);
            view.addEventListener(CloseEvent.CLOSE, onViewClose);
            view.addEventListener(KeyboardEvent.KEY_DOWN, onViewKeyDown);
        }

        [Bindable]
        public var superClassName:String;

        [Bindable]
        public var interfaceName:String;

        private var _classesImports:Array = [];
        public function get classesImports():Array
        {
            return _classesImports;
        }

        private var _interfacesImports:Array = [];
        public function get interfacesImports():Array
        {
            return _interfacesImports;
        }

        public function showCompletionListClasses(text:String, position:Point):void
        {
            this.completionListType = CLASSES_LIST;
            this.internalShowCompletionList(text, position);
        }

        public function showCompletionListInterfaces(text:String, position:Point):void
        {
            this.completionListType = INTERFACES_LIST;
            this.internalShowCompletionList(text, position);
        }

        private function handleShowWorkspaceSymbols(symbols:Array):void
        {
            menuCollection.source.splice(0, menuCollection.length);
            if (symbols.length == 0)
            {
                if (this.completionListType == CLASSES_LIST)
                {
                    _classesImports.splice(0, _classesImports.length);
                }
                else
                {
                    _interfacesImports.splice(0, _interfacesImports.length);
                }
                return;
            }

            if (this.completionListType == CLASSES_LIST)
            {
                symbols = symbols.filter(filterClasses);
            }
            else
            {
                symbols = symbols.filter(filterInterfaces);
            }

            if (symbols.length == 0)
            {
                return;
            }

            var symbolsCount:int = symbols.length;
            for (var i:int = 0; i < symbolsCount; i++)
            {
                var symbolInformation:SymbolInformation = symbols[i] as SymbolInformation;
                if(!symbolInformation)
                {
                    continue;
                }
                var packageName:String = symbolInformation.containerName ? symbolInformation.containerName + "." + symbolInformation.name : "";
                var completionItemKind:int = symbolKindToCompletionItemKind(symbolInformation.kind);

                var completionItem:CompletionItem = new CompletionItem();
                completionItem.label = symbolInformation.name;
                completionItem.detail = packageName;
                completionItem.kind = completionItemKind;
                menuCollection.source.push(completionItem);
            }

            menuCollection.refresh();

            this.showCompletionList();
        }

        private function onViewClose(event:Event):void
        {
            view.removeEventListener(MouseEvent.CLICK, onViewClick);
            view.removeEventListener(CloseEvent.CLOSE, onViewClose);
            view.removeEventListener(KeyboardEvent.KEY_DOWN, onViewKeyDown);

            this.closeCompletionList();
        }

        private function onViewClick(event:MouseEvent):void
        {
            this.closeCompletionList();
        }

        private function onViewKeyDown(event:KeyboardEvent):void
        {
            if (!completionList.isPopUp) return;

            if (event.keyCode == Keyboard.ENTER)
            {
                this.completeItem(completionList.selectedItem as CompletionItem);
            }

            if (event.keyCode == Keyboard.DOWN || event.keyCode == Keyboard.UP)
            {
                this.completionList.setFocus();
            }
        }

        private function onCompletionListDoubleClick(event:MouseEvent):void
        {
            this.completeItem(completionList.selectedItem as CompletionItem);
        }

        private function onCompletionListRemovedFromStage(event:Event):void
        {
            menuCollection.removeAll();
        }

        private function completeItem(completionItem:CompletionItem):void
        {
            var isDetailValid:Boolean = completionItem.detail && completionItem.detail.indexOf("No Package") == -1;

            if (this.completionListType == CLASSES_LIST)
            {
                this.superClassName = completionItem.label;
                if (isDetailValid)
                {
                    this._classesImports.push(completionItem.detail);
                }
            }
            else if (this.completionListType == INTERFACES_LIST)
            {
                this.interfaceName = completionItem.label;
                if (isDetailValid)
                {
                    this._interfacesImports.push(completionItem.detail);
                }
            }

            dispatchEvent(new Event("itemSelected"));
            this.closeCompletionList();
        }

        private function internalShowCompletionList(text:String, position:Point):void
        {
            var lspProject:LanguageServerProjectVO = project as LanguageServerProjectVO;
            if(!lspProject || !lspProject.languageClient)
            {
                return;
            }
            lspProject.languageClient.workspaceSymbols({
                query: text
            }, handleShowWorkspaceSymbols);

            completionList.x = position.x;
            completionList.y = position.y;
        }

        private function showCompletionList():void
        {
            if (completionList.isPopUp) return;

            PopUpManager.addPopUp(completionList, this.view, false);
            completionList.addEventListener(KeyboardEvent.KEY_DOWN, onViewKeyDown);
            completionList.addEventListener(MouseEvent.DOUBLE_CLICK, onCompletionListDoubleClick);
            completionList.addEventListener(Event.REMOVED_FROM_STAGE, onCompletionListRemovedFromStage);
        }

        private function closeCompletionList():void
        {
            if(!completionList.isPopUp) return;

            PopUpManager.removePopUp(completionList);
            completionList.removeEventListener(KeyboardEvent.KEY_DOWN, onViewKeyDown);
            completionList.removeEventListener(Event.REMOVED_FROM_STAGE, onCompletionListRemovedFromStage);
            completionList.removeEventListener(MouseEvent.DOUBLE_CLICK, onCompletionListDoubleClick);

            completionList.closeDocumentation();
        }

        private function filterClasses(item:Object, index:int, vector:Array):Boolean
        {
            if(item is SymbolInformation)
            {
                var symbolInfo:SymbolInformation = SymbolInformation(item);
                return symbolInfo.kind == SymbolKind.CLASS;
            }
            if(item is DocumentSymbol)
            {
                var documentSymbol:DocumentSymbol = DocumentSymbol(item);
                return documentSymbol.kind == SymbolKind.CLASS;
            }
            return false;
        }

        private function filterInterfaces(item:Object, index:int, vector:Array):Boolean
        {
            if(item is SymbolInformation)
            {
                var symbolInfo:SymbolInformation = SymbolInformation(item);
                return symbolInfo.kind == SymbolKind.INTERFACE;
            }
            if(item is DocumentSymbol)
            {
                var documentSymbol:DocumentSymbol = DocumentSymbol(item);
                return documentSymbol.kind == SymbolKind.INTERFACE;
            }
            return false;
        }
    }
}