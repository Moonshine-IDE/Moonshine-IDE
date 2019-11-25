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
package actionScripts.plugin.outline
{
	import actionScripts.plugin.outline.view.OutlineView;
	import actionScripts.plugin.PluginBase;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import flash.events.Event;
	import actionScripts.ui.LayoutModifier;
	import actionScripts.events.SymbolsEvent;
	import actionScripts.valueObjects.DocumentSymbol;
	import mx.collections.ArrayCollection;
	import actionScripts.valueObjects.SymbolInformation;
	import actionScripts.ui.tabview.TabEvent;
	import actionScripts.events.LanguageServerEvent;
	import actionScripts.ui.editor.LanguageServerTextEditor;
	import actionScripts.events.OpenFileEvent;
	import actionScripts.valueObjects.Location;
	import actionScripts.events.OpenLocationEvent;
	import actionScripts.ui.editor.BasicTextEditor;
	import actionScripts.valueObjects.Range;
	import actionScripts.events.ProjectEvent;
	import flash.utils.Timer;
	import flash.events.TimerEvent;

	public class OutlinePlugin extends PluginBase
	{
		public static const EVENT_OUTLINE:String = "EVENT_OUTLINE";

		public function OutlinePlugin()
		{
			super();
			
			outlineView  = new OutlineView();
			outlineView.addEventListener(Event.CHANGE, outlineView_changeHandler);

			changeTimer = new Timer(500, 1);
			changeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, changeTimer_timerCompleteHandler);
		}

		override public function get name():String { return "Outline Plugin"; }
		override public function get author():String { return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String { return "Displays an outline of the symbols in a source file."; }
		
		private var outlineView:OutlineView;
		private var isStartupCall:Boolean = true;
		private var changeTimer:Timer;

		override public function activate():void
		{
			super.activate();
			dispatcher.addEventListener(EVENT_OUTLINE, handleOutlineShow);
			dispatcher.addEventListener(SymbolsEvent.EVENT_SHOW_DOCUMENT_SYMBOLS, handleShowDocumentSymbols);
			dispatcher.addEventListener(TabEvent.EVENT_TAB_SELECT, handleTabSelect);
			dispatcher.addEventListener(ProjectEvent.LANGUAGE_SERVER_OPENED, handleLanguageServerOpened);
			dispatcher.addEventListener(LanguageServerEvent.EVENT_DIDCHANGE, handleDidChange);
			dispatcher.addEventListener(LanguageServerEvent.EVENT_DIDSAVE, handleDidSave);
		}

		override public function deactivate():void
		{
			super.deactivate();
			dispatcher.removeEventListener(EVENT_OUTLINE, handleOutlineShow);
			dispatcher.removeEventListener(SymbolsEvent.EVENT_SHOW_DOCUMENT_SYMBOLS, handleShowDocumentSymbols);
			dispatcher.removeEventListener(TabEvent.EVENT_TAB_SELECT, handleTabSelect);
			dispatcher.removeEventListener(ProjectEvent.LANGUAGE_SERVER_OPENED, handleLanguageServerOpened);
			dispatcher.removeEventListener(LanguageServerEvent.EVENT_DIDCHANGE, handleDidChange);
			dispatcher.removeEventListener(LanguageServerEvent.EVENT_DIDSAVE, handleDidSave);
		}

		private function handleLanguageServerOpened(event:ProjectEvent):void
		{
			//start fresh because it's a new language server instance
			var collection:ArrayCollection = outlineView.outline;
			collection.removeAll();

			//we may have tried to refresh the symbols previously, but it would
			//not have been successful because the language server was not ready
			//yet. try again now.
			this.refreshSymbols();
		}

		private function handleOutlineShow(event:Event):void
		{
			var collection:ArrayCollection = outlineView.outline;
			collection.removeAll();
			
			if (!outlineView.parent)
            {
				LayoutModifier.addToSidebar(outlineView, event);

				this.refreshSymbols();
            }
			else
			{
				//don't bother refreshing because the outline view is being
				//hidden
				changeTimer.reset();

				LayoutModifier.removeFromSidebar(outlineView);
			}
			isStartupCall = false;
		}

		private function handleShowDocumentSymbols(event:SymbolsEvent):void
		{
			if(!outlineView.parent)
			{
				//we can ignore this event when the outline isn't visible
				return;
			}
			var collection:ArrayCollection = outlineView.outline;
			collection.removeAll();
			var symbols:Array = event.symbols;
			var itemCount:int = symbols.length;
			for(var i:int = 0; i < itemCount; i++)
			{
				var symbol:Object = symbols[i];
				if(symbol is SymbolInformation)
				{
					var symbolInfo:SymbolInformation = symbol as SymbolInformation;
					collection.addItem({label: symbolInfo.name, symbol: symbolInfo});
				}
				else if(symbol is DocumentSymbol)
				{
					var documentSymbol:DocumentSymbol = symbol as DocumentSymbol;
					var item:Object = this.getDocumentSymbolItem(documentSymbol);
					collection.addItem(item);
				}
			}
		}

		private function getDocumentSymbolItem(documentSymbol:DocumentSymbol):Object
		{
			var item:Object = {label: documentSymbol.name, symbol: documentSymbol, children: null};
			var symbolChildren:Vector.<DocumentSymbol> = documentSymbol.children;
			if(documentSymbol.children)
			{
				var children:Array = [];
				var childCount:int = symbolChildren.length;
				for(var i:int = 0; i < childCount; i++)
				{
					var child:DocumentSymbol = symbolChildren[i];
					children[i] = this.getDocumentSymbolItem(child);
				}
				item.children = children;
			}
			return item;
		}

		private function refreshSymbols():void
		{
			//don't clear the old symbols here because sometimes we want to
			//refresh the symbols in the same file and keep the stale (but
			//mostly accurate) symbols visible until the new values arrive

			//reset the timer, if it's running, because we're refreshing immediately
			changeTimer.reset();

			if(!outlineView.parent)
			{
				//we can ignore this event when the outline isn't visible
				return;
			}
			var editor:LanguageServerTextEditor = model.activeEditor as LanguageServerTextEditor;
			if(!editor)
			{
				//this is not a language server editor, so there's nothing
				//to display
				return;
			}
			dispatcher.dispatchEvent(new LanguageServerEvent(LanguageServerEvent.EVENT_DOCUMENT_SYMBOLS,
				editor.currentFile.fileBridge.url));
		}

		private function handleTabSelect(event:TabEvent):void
		{
			//we switched to a different file, so remove the old symbols
			var collection:ArrayCollection = outlineView.outline;
			collection.removeAll();

			this.refreshSymbols();
		}

		private function outlineView_changeHandler(event:Event):void
		{
			var activeEditor:LanguageServerTextEditor = model.activeEditor as LanguageServerTextEditor;
			if(!activeEditor)
			{
				return;
			}
			var selectedSymbol:Object = outlineView.selectedSymbol;
			if(!selectedSymbol)
			{
				return;
			}

			var location:Location = null;
			if(selectedSymbol is SymbolInformation)
			{
				location = SymbolInformation(selectedSymbol).location;
			}
			else if(selectedSymbol is DocumentSymbol)
			{
				var documentSymbol:DocumentSymbol = DocumentSymbol(selectedSymbol);
				var uri:String = activeEditor.currentFile.fileBridge.url;
				var range:Range = documentSymbol.range;
				location = new Location(uri, range);
			}
			if(!location)
			{
				return;
			}
			dispatcher.dispatchEvent(new OpenLocationEvent(OpenLocationEvent.OPEN_LOCATION, location));
		}

		private function handleDidChange(event:LanguageServerEvent):void
		{
			//the file has been edited. to avoid updating the outline too often,
			//reset the timer and start over from the beginning.
			changeTimer.reset();
			
			if(!outlineView.parent)
			{
				//we can ignore this event when the outline isn't visible
				return;
			}
			changeTimer.start();
		}

		private function handleDidSave(event:LanguageServerEvent):void
		{
			//we can update immediately on save
			this.refreshSymbols();
		}

		private function changeTimer_timerCompleteHandler(event:TimerEvent):void
		{
			//the user has finished editing the file, so update the outline to
			//reflect the new changes
			this.refreshSymbols();
		}
	}
}