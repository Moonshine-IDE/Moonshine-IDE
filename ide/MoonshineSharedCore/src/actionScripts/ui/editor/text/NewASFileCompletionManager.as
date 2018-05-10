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
package actionScripts.ui.editor.text
{
    import actionScripts.events.GlobalEventDispatcher;
    import actionScripts.events.SymbolsEvent;
    import actionScripts.events.TypeAheadEvent;
    import actionScripts.ui.codeCompletionList.CodeCompletionList;
    import actionScripts.valueObjects.CompletionItem;
    import actionScripts.valueObjects.SymbolInformation;

    import components.popup.newFile.NewASFilePopup;

    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.ui.Keyboard;

    import mx.collections.ArrayCollection;
    import mx.events.CloseEvent;
    import mx.managers.PopUpManager;

    public class NewASFileCompletionManager
    {
        private static const CLASSES_LIST:String = "classesList";
        private static const INTERFACES_LIST:String = "interfacesList";

        protected var dispatcher:EventDispatcher = GlobalEventDispatcher.getInstance();

        private var newAsFileView:NewASFilePopup;

        private var completionList:CodeCompletionList;
        private var menuCollection:ArrayCollection;

        private var completionListType:String;

        public function NewASFileCompletionManager(newAsFileView:NewASFilePopup)
        {
            this.newAsFileView = newAsFileView;

            completionList = new CodeCompletionList();
            completionList.requireSelection = true;
            completionList.width = 574;
            menuCollection = new ArrayCollection();
            completionList.dataProvider = menuCollection;

            dispatcher.addEventListener(SymbolsEvent.EVENT_SHOW_SYMBOLS, handleShowSymbols);
            newAsFileView.addEventListener(MouseEvent.CLICK, onNewFileViewClick);
            newAsFileView.addEventListener(CloseEvent.CLOSE, onNewAsFileClose);
            newAsFileView.addEventListener(KeyboardEvent.KEY_DOWN, onNewAsFileKeyDown);
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

        private function handleShowSymbols(event:SymbolsEvent):void
        {
            menuCollection.source.splice(0, menuCollection.length);
            if (event.symbols.length == 0)
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

            var symbols:Vector.<SymbolInformation>;
            if (this.completionListType == CLASSES_LIST)
            {
                symbols = event.symbols.filter(filterClasses);
            }
            else
            {
                symbols = event.symbols.filter(filterInterfaces);
            }

            if (symbols.length == 0)
            {
                return;
            }

            var symbolsCount:int = symbols.length;
            for (var i:int = 0; i < symbolsCount; i++)
            {
                var symbolInformation:SymbolInformation = symbols[i];
                var packageName:String = symbolInformation.containerName ? symbolInformation.containerName + "." + symbolInformation.name : "";
                menuCollection.source.push(new CompletionItem(symbolInformation.name,
                        "", symbolInformation.kind, packageName));
            }

            menuCollection.refresh();

            this.showCompletionList();
        }

        private function onNewAsFileClose(event:Event):void
        {
            dispatcher.removeEventListener(SymbolsEvent.EVENT_SHOW_SYMBOLS, handleShowSymbols);
            newAsFileView.removeEventListener(MouseEvent.CLICK, onNewFileViewClick);
            newAsFileView.removeEventListener(CloseEvent.CLOSE, onNewAsFileClose);
            newAsFileView.removeEventListener(KeyboardEvent.KEY_DOWN, onNewAsFileKeyDown);

            this.closeCompletionList();
        }

        private function onNewFileViewClick(event:MouseEvent):void
        {
            this.closeCompletionList();
        }

        private function onNewAsFileKeyDown(event:KeyboardEvent):void
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
            if (this.completionListType == CLASSES_LIST)
            {
                this.superClassName = completionItem.label;
                if (completionItem.detail)
                {
                    this._classesImports.push(completionItem.detail);
                }
            }
            else if (this.completionListType == INTERFACES_LIST)
            {
                this.interfaceName = completionItem.label;
                if (completionItem.detail)
                {
                    this._interfacesImports.push(completionItem.detail);
                }
            }

            this.closeCompletionList();
        }

        private function internalShowCompletionList(text:String, position:Point):void
        {
            var languageServerEvent:TypeAheadEvent = new TypeAheadEvent(TypeAheadEvent.EVENT_WORKSPACE_SYMBOLS);
            languageServerEvent.newText = text;
            dispatcher.dispatchEvent(languageServerEvent);

            completionList.x = position.x;
            completionList.y = position.y;
        }

        private function showCompletionList():void
        {
            if (completionList.isPopUp) return;

            PopUpManager.addPopUp(completionList, this.newAsFileView, false);
            completionList.addEventListener(KeyboardEvent.KEY_DOWN, onNewAsFileKeyDown);
            completionList.addEventListener(MouseEvent.DOUBLE_CLICK, onCompletionListDoubleClick);
            completionList.addEventListener(Event.REMOVED_FROM_STAGE, onCompletionListRemovedFromStage);
        }

        private function closeCompletionList():void
        {
            if(!completionList.isPopUp) return;

            PopUpManager.removePopUp(completionList);
            completionList.removeEventListener(KeyboardEvent.KEY_DOWN, onNewAsFileKeyDown);
            completionList.removeEventListener(Event.REMOVED_FROM_STAGE, onCompletionListRemovedFromStage);
            completionList.removeEventListener(MouseEvent.DOUBLE_CLICK, onCompletionListDoubleClick);

            completionList.closeDocumentation();
        }

        private function filterClasses(item:SymbolInformation, index:int, vector:Vector.<SymbolInformation>):Boolean
        {
            return item.kind == "Class";
        }

        private function filterInterfaces(item:SymbolInformation, index:int, vector:Vector.<SymbolInformation>):Boolean
        {
            return item.kind == "Interface";
        }
    }
}