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
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import actionScripts.events.OpenLocationEvent;
	import actionScripts.events.ProjectEvent;
	import actionScripts.events.SaveFileEvent;
	import actionScripts.plugin.PluginBase;
	import actionScripts.ui.LayoutModifier;
	import actionScripts.ui.editor.LanguageServerTextEditor;
	import actionScripts.ui.tabview.TabEvent;
	import actionScripts.valueObjects.ConstantsCoreVO;

	import feathers.data.TreeCollection;
	import feathers.data.TreeNode;

	import moonshine.lsp.DocumentSymbol;
	import moonshine.lsp.Location;
	import moonshine.lsp.Range;
	import moonshine.lsp.SymbolInformation;
	import moonshine.plugin.outline.view.OutlineView;
	import moonshine.editor.text.events.TextEditorChangeEvent;

	public class OutlinePlugin extends PluginBase
	{
		public static const EVENT_OUTLINE:String = "EVENT_OUTLINE";

		private static const LANGUAGE_SERVER_CAPABILITY_DOCUMENT_SYMBOLS:String = "textDocument/documentSymbol";

		public function OutlinePlugin()
		{
			super();
			
			outlineView = new OutlineView();
			outlineView.addEventListener(Event.CHANGE, outlineView_changeHandler);
			outlineView.addEventListener(Event.CLOSE, outlineView_closeHandler);
			outlineViewWrapper = new OutlineViewWrapper(outlineView);
			outlineViewWrapper.percentWidth = 100;
			outlineViewWrapper.percentHeight = 100;

			changeTimer = new Timer(500, 1);
			changeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, changeTimer_timerCompleteHandler);
		}

		override public function get name():String { return "Outline Plugin"; }
		override public function get author():String { return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String { return "Displays an outline of the symbols in a source file."; }
		
		private var _activeEditor:LanguageServerTextEditor;

		private function setActiveEditor(value:LanguageServerTextEditor):void {

			if(_activeEditor == value)
			{
				return;
			}
			if(_activeEditor)
			{
				_activeEditor.getEditorComponent().removeEventListener(TextEditorChangeEvent.TEXT_CHANGE, handleDidChange);
			}
			_activeEditor = value;
			if(_activeEditor)
			{
				_activeEditor.getEditorComponent().addEventListener(TextEditorChangeEvent.TEXT_CHANGE, handleDidChange);
			}
		}

		private var outlineViewWrapper:OutlineViewWrapper;
		private var outlineView:OutlineView;
		private var isStartupCall:Boolean = true;
		private var changeTimer:Timer;

		override public function activate():void
		{
			super.activate();
			dispatcher.addEventListener(EVENT_OUTLINE, handleOutlineShow);
			dispatcher.addEventListener(TabEvent.EVENT_TAB_SELECT, handleTabSelect);
			dispatcher.addEventListener(ProjectEvent.LANGUAGE_SERVER_OPENED, handleLanguageServerOpened);
			dispatcher.addEventListener(ProjectEvent.LANGUAGE_SERVER_REGISTER_CAPABILITY, handleLanguageServerRegisterCapability);
			dispatcher.addEventListener(SaveFileEvent.FILE_SAVED, handleDidSave);
		}

		override public function deactivate():void
		{
			super.deactivate();
			dispatcher.removeEventListener(EVENT_OUTLINE, handleOutlineShow);
			dispatcher.removeEventListener(TabEvent.EVENT_TAB_SELECT, handleTabSelect);
			dispatcher.removeEventListener(ProjectEvent.LANGUAGE_SERVER_OPENED, handleLanguageServerOpened);
			dispatcher.removeEventListener(SaveFileEvent.FILE_SAVED, handleDidSave);
		}

		private function handleLanguageServerOpened(event:ProjectEvent):void
		{
			//start fresh because it's a new language server instance
			var collection:TreeCollection = outlineView.outline;
			collection.removeAll();

			//we may have tried to refresh the symbols previously, but it would
			//not have been successful because the language server was not ready
			//yet. try again now.
			this.refreshSymbols();
		}

		private function handleLanguageServerRegisterCapability(event:ProjectEvent):void
		{
			if(event.extras[0] != LANGUAGE_SERVER_CAPABILITY_DOCUMENT_SYMBOLS)
			{
				return;
			}
			
			//start fresh because this capapbility wasn't registered before
			var collection:TreeCollection = outlineView.outline;
			collection.removeAll();

			//we may have tried to refresh the symbols previously, but it would
			//not have been successful because the language server did not have
			//this capability registered yet
			this.refreshSymbols();
		}

		private function handleOutlineShow(event:Event):void
		{
			var collection:TreeCollection = outlineView.outline;
			collection.removeAll();
			
			if (!outlineViewWrapper.parent)
            {
				LayoutModifier.addToSidebar(outlineViewWrapper, event);

				this.refreshSymbols();
            }
			else
			{
				//don't bother refreshing because the outline view is being
				//hidden
				changeTimer.reset();

				LayoutModifier.removeFromSidebar(outlineViewWrapper);
			}
			isStartupCall = false;
		}

		private function handleShowDocumentSymbols(symbols:Array):void
		{
			if(!outlineViewWrapper.parent)
			{
				//we can ignore this event when the outline isn't visible
				return;
			}
			var collection:TreeCollection = outlineView.outline;
			collection.removeAll();

			if(!symbols || symbols.length == 0)
			{
				return;
			}

			//TODO: remove when addAt() bug is fixed in alpha.3
			var nodes:Array = [];

			var itemCount:int = symbols.length;
			for(var i:int = 0; i < itemCount; i++)
			{
				var symbol:Object = symbols[i];
				if(symbol is SymbolInformation)
				{
					var symbolInfo:SymbolInformation = symbol as SymbolInformation;
					//TODO: remove when addAt() bug is fixed in alpha.3
					//collection.addAt(new TreeNode(symbolInfo), [i]);
					nodes.push(new TreeNode(symbolInfo));
				}
				else if(symbol is DocumentSymbol)
				{
					var documentSymbol:DocumentSymbol = symbol as DocumentSymbol;
					var item:TreeNode = this.getDocumentSymbolItem(documentSymbol);
					//TODO: remove when addAt() bug is fixed in alpha.3
					nodes.push(item);
					//collection.addAt(item, [i]);
				}
			}
			//TODO: remove when addAt() bug is fixed in alpha.3
			outlineView.outline = new TreeCollection(nodes);
		}

		private function getDocumentSymbolItem(documentSymbol:DocumentSymbol):TreeNode
		{
			var nodeChildren:Array = null;
			var symbolChildren:Array = documentSymbol.children;
			if(documentSymbol.children)
			{
				nodeChildren = [];
				var childCount:int = symbolChildren.length;
				for(var i:int = 0; i < childCount; i++)
				{
					var child:DocumentSymbol = symbolChildren[i];
					nodeChildren[i] = this.getDocumentSymbolItem(child);
				}
			}
			return new TreeNode(documentSymbol, nodeChildren);
		}

		private function refreshSymbols():void
		{
			//don't clear the old symbols here because sometimes we want to
			//refresh the symbols in the same file and keep the stale (but
			//mostly accurate) symbols visible until the new values arrive

			//reset the timer, if it's running, because we're refreshing immediately
			changeTimer.reset();

			if(!outlineViewWrapper.parent)
			{
				//we can ignore this event when the outline isn't visible
				return;
			}
			var lspEditor:LanguageServerTextEditor = _activeEditor as LanguageServerTextEditor;
			if(!lspEditor || !lspEditor.currentFile || !lspEditor.languageClient)
			{
				//we can clear the collection if we can't proceed
				var collection:TreeCollection = outlineView.outline;
				collection.removeAll();
				return;
			}
			lspEditor.languageClient.documentSymbols({
				textDocument: {
					uri: lspEditor.currentFile.fileBridge.url
				}
			}, handleShowDocumentSymbols);
		}

		private function handleTabSelect(event:TabEvent):void
		{
			//we switched to a different file, so remove the old symbols
			var collection:TreeCollection = outlineView.outline;
			collection.removeAll();

			setActiveEditor(event.child as LanguageServerTextEditor);

			refreshSymbols();
		}

		private function outlineView_changeHandler(event:Event):void
		{
			var lspEditor:LanguageServerTextEditor = _activeEditor as LanguageServerTextEditor;
			if(!lspEditor)
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
				var uri:String = lspEditor.currentFile.fileBridge.url;
				var range:Range = documentSymbol.range;
				location = new Location(uri, range);
			}
			if(!location)
			{
				return;
			}
			dispatcher.dispatchEvent(new OpenLocationEvent(OpenLocationEvent.OPEN_LOCATION, location));
		}

		private function outlineView_closeHandler(event:Event):void
		{
			LayoutModifier.removeFromSidebar(outlineViewWrapper);
		}

		private function handleDidChange(event:TextEditorChangeEvent):void
		{
			//the file has been edited. to avoid updating the outline too often,
			//reset the timer and start over from the beginning.
			changeTimer.reset();
			
			if(!outlineViewWrapper.parent)
			{
				//we can ignore this event when the outline isn't visible
				return;
			}
			changeTimer.start();
		}

		private function handleDidSave(event:SaveFileEvent):void
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

import actionScripts.interfaces.IViewWithTitle;
import actionScripts.ui.FeathersUIWrapper;
import actionScripts.ui.IPanelWindow;

import moonshine.plugin.outline.view.OutlineView;

//IPanelWindow used by LayoutModifier.addToSidebar() and removeFromSidebar()
class OutlineViewWrapper extends FeathersUIWrapper implements IPanelWindow, IViewWithTitle {
	public function OutlineViewWrapper(outlineView:OutlineView)
	{
		super(outlineView);
	}

	public function get title():String
	{
		return OutlineView(feathersUIControl).title;
	}

	override public function get className():String
	{
		//className used by LayoutModifier.attachSidebarSections
		return "OutlineView";
	}
}