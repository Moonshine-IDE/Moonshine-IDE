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
package actionScripts.plugin.symbols
{
	import actionScripts.events.OpenLocationEvent;
	import actionScripts.plugin.PluginBase;
	import actionScripts.ui.FeathersUIWrapper;
	import actionScripts.ui.editor.BasicTextEditor;
	import actionScripts.ui.editor.LanguageServerTextEditor;
	import actionScripts.valueObjects.ConstantsCoreVO;

	import feathers.data.ArrayCollection;

	import flash.display.DisplayObject;
	import flash.events.Event;

	import moonshine.lsp.DocumentSymbol;
	import moonshine.lsp.Location;
	import moonshine.lsp.Range;
	import moonshine.lsp.SymbolInformation;
	import moonshine.plugin.symbols.view.SymbolsView;

	import mx.core.UIComponent;
	import mx.managers.PopUpManager;
	import moonshine.lsp.LanguageClient;

	public class SymbolsPlugin extends PluginBase
	{
		public static const EVENT_OPEN_DOCUMENT_SYMBOLS_VIEW:String = "openDocumentSymbolsView";
		public static const EVENT_OPEN_WORKSPACE_SYMBOLS_VIEW:String = "openWorkspaceSymbolsView";

		private static const TITLE_DOCUMENT:String = "Find Symbol in Document";
		private static const TITLE_WORKSPACE:String = "Find Symbol in Project";

		public function SymbolsPlugin()
		{
			this.symbolsView = new SymbolsView();
			this.symbolsView.addEventListener(Event.CLOSE, symbolsView_closeHandler);
			this.symbolsViewWrapper = new FeathersUIWrapper(this.symbolsView);
		}

		override public function get name():String { return "Symbols Plugin"; }
		override public function get author():String { return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String { return "Displays symbols in current document or entire workspace."; }

		private var symbolsViewWrapper:FeathersUIWrapper;
		private var symbolsView:SymbolsView;
		private var isWorkspace:Boolean = false;

		override public function activate():void
		{
			super.activate();
			symbolsView.addEventListener(SymbolsView.EVENT_QUERY_CHANGE, handleQueryChange);
			dispatcher.addEventListener(EVENT_OPEN_DOCUMENT_SYMBOLS_VIEW, handleOpenDocumentSymbolsView);
			dispatcher.addEventListener(EVENT_OPEN_WORKSPACE_SYMBOLS_VIEW, handleOpenWorkspaceSymbolsView);
		}

		override public function deactivate():void
		{
			super.deactivate();
			symbolsView.removeEventListener(SymbolsView.EVENT_QUERY_CHANGE, handleQueryChange);
			dispatcher.removeEventListener(EVENT_OPEN_DOCUMENT_SYMBOLS_VIEW, handleOpenDocumentSymbolsView);
			dispatcher.removeEventListener(EVENT_OPEN_WORKSPACE_SYMBOLS_VIEW, handleOpenWorkspaceSymbolsView);
		}
		
		private function handleQueryChange(event:Event):void
		{
			if(symbolsViewWrapper.parent == null)
			{
				//ignore query changes if they happen after the window is closed
				return;
			}
			var query:String = this.symbolsView.query;
			if(this.isWorkspace)
			{
				var lspEditor:LanguageServerTextEditor = model.activeEditor as LanguageServerTextEditor;
				if(!lspEditor || !lspEditor.languageClient)
				{
					return;
				}
				lspEditor.languageClient.workspaceSymbols({
					query: query
				}, handleShowSymbols);
			}
			else
			{
				query = query.toLowerCase();
				var collection:ArrayCollection = this.symbolsView.symbols;
				collection.filterFunction = function(item:Object):Boolean
				{
					if(item is SymbolInformation)
					{
						var symbolInfo:SymbolInformation = SymbolInformation(item);
						return symbolInfo.name.toLowerCase().indexOf(query) >= 0;
					}
					else if(item is DocumentSymbol)
					{
						var documentSymbol:DocumentSymbol = DocumentSymbol(item);
						return documentSymbol.name.toLowerCase().indexOf(query) >= 0;
					}
					return false;
				};
				collection.refresh();
			}
		}

		private function symbolSortCompareFunction(symbol1:Object, symbol2:Object):int
		{
			var symbol1Name:String = null;
			var symbol2Name:String = null;
			if(symbol1 is DocumentSymbol)
			{
				var docSymbol1:DocumentSymbol = DocumentSymbol(symbol1);
				symbol1Name = docSymbol1.name;
			}
			else if(symbol1 is SymbolInformation)
			{
				var symbolInfo1:SymbolInformation = SymbolInformation(symbol1);
				symbol1Name = symbolInfo1.name;
			}
			if(symbol2 is DocumentSymbol)
			{
				var docSymbol2:DocumentSymbol = DocumentSymbol(symbol2);
				symbol2Name = docSymbol2.name;
			}
			else if(symbol2 is SymbolInformation)
			{
				var symbolInfo2:SymbolInformation = SymbolInformation(symbol2);
				symbol2Name = symbolInfo2.name;
			}
			symbol1Name = symbol1Name.toLowerCase();
			symbol2Name = symbol2Name.toLowerCase();
			if(symbol1Name < symbol2Name)
			{
				return -1;
			}
			else if(symbol1Name > symbol2Name)
			{
				return 1;
			}
			return 0;
		}

		private function handleOpenDocumentSymbolsView(event:Event):void
		{
			var lspEditor:LanguageServerTextEditor = model.activeEditor as LanguageServerTextEditor;
			if(!lspEditor || !lspEditor.languageClient)
			{
				return;
			}
			isWorkspace = false;
			symbolsView.title = TITLE_DOCUMENT;
			symbolsView.query = "";
			var collection:ArrayCollection = symbolsView.symbols;
			collection.filterFunction = null;
			collection.removeAll();
			var parentApp:Object = UIComponent(model.activeEditor).parentApplication;
			PopUpManager.addPopUp(symbolsViewWrapper, DisplayObject(parentApp), true);
			PopUpManager.centerPopUp(symbolsViewWrapper);
			lspEditor.languageClient.documentSymbols({
				textDocument: {
					uri: lspEditor.currentFile.fileBridge.url
				}
			}, handleShowSymbols);
			symbolsViewWrapper.assignFocus("top");
			symbolsViewWrapper.stage.addEventListener(Event.RESIZE, symbolsView_stage_resizeHandler, false, 0, true);
		}

		private function handleOpenWorkspaceSymbolsView(event:Event):void
		{
			var lspEditor:LanguageServerTextEditor = model.activeEditor as LanguageServerTextEditor;
			if(!lspEditor || !lspEditor.languageClient)
			{
				return;
			}
			isWorkspace = true;
			symbolsView.title = TITLE_WORKSPACE;
			symbolsView.query = "";
			var collection:ArrayCollection = symbolsView.symbols;
			collection.filterFunction = null;
			collection.removeAll();
			var parentApp:Object = UIComponent(model.activeEditor).parentApplication;
			PopUpManager.addPopUp(symbolsViewWrapper, DisplayObject(parentApp), true);
			PopUpManager.centerPopUp(symbolsViewWrapper);
			symbolsViewWrapper.assignFocus("top");
			symbolsViewWrapper.stage.addEventListener(Event.RESIZE, symbolsView_stage_resizeHandler, false, 0, true);
		
			//start by listing all symbols, if the language server supports it
			lspEditor.languageClient.workspaceSymbols({
				query: ""
			}, handleShowSymbols);
		}

		private function handleShowSymbols(symbols:Array):void
		{
			var collection:ArrayCollection = symbolsView.symbols;
			collection.filterFunction = null;
			//don't sort until after all items have been added because it's
			//expensive to repeatedly sort when adding new items one by one
			collection.sortCompareFunction = null;
			collection.removeAll();

			if(!symbols || symbols.length == 0)
			{
				return;
			}

			var itemCount:int = symbols.length;
			for(var i:int = 0; i < itemCount; i++)
			{
				var symbol:Object = symbols[i];
				if(symbol is SymbolInformation)
				{
					var symbolInfo:SymbolInformation = symbol as SymbolInformation;
					collection.add(symbolInfo);
				}
				else if(symbol is DocumentSymbol)
				{
					var documentSymbol:DocumentSymbol = symbol as DocumentSymbol;
					collection.add(documentSymbol);
					this.addDocumentSymbolChildren(documentSymbol, collection);
				}
			}
			collection.sortCompareFunction = symbolSortCompareFunction;
			collection.refresh();
		}

		private function addDocumentSymbolChildren(documentSymbol:DocumentSymbol, collection:ArrayCollection):void
		{
			if(!documentSymbol.children)
			{
				return;
			}
			var children:Array = documentSymbol.children;
			var childCount:int = children.length;
			for(var j:int = 0; j < childCount; j++)
			{
				var child:DocumentSymbol = children[j];
				collection.add(child);
				this.addDocumentSymbolChildren(child, collection);
			}
		}

		private function symbolsView_closeHandler(event:Event):void
		{
			var selectedSymbol:Object = this.symbolsView.selectedSymbol;
			if(selectedSymbol is SymbolInformation)
			{
				var symbolInfo:SymbolInformation = selectedSymbol as SymbolInformation;
				dispatcher.dispatchEvent(
					new OpenLocationEvent(OpenLocationEvent.OPEN_LOCATION, symbolInfo.location));
			}
			else if(selectedSymbol is DocumentSymbol)
			{
				var documentSymbol:DocumentSymbol = selectedSymbol as DocumentSymbol;
				var activeEditor:BasicTextEditor = model.activeEditor as BasicTextEditor;
				var uri:String = activeEditor.currentFile.fileBridge.url;
				var range:Range = documentSymbol.range;
				var location:Location = new Location(uri, range);
				dispatcher.dispatchEvent(
					new OpenLocationEvent(OpenLocationEvent.OPEN_LOCATION, location));
			}

			symbolsViewWrapper.stage.removeEventListener(Event.RESIZE, symbolsView_stage_resizeHandler);
			PopUpManager.removePopUp(symbolsViewWrapper);
		}

		protected function symbolsView_stage_resizeHandler(event:Event):void
		{
			PopUpManager.centerPopUp(symbolsViewWrapper);
		}

	}
}
