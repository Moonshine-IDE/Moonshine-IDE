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

	import feathers.data.ArrayHierarchicalCollection;
	import feathers.data.TreeNode;

	import moonshine.lsp.DocumentSymbol;
	import moonshine.lsp.Location;
	import moonshine.lsp.Range;
	import moonshine.lsp.SymbolInformation;
	import moonshine.plugin.outline.view.OutlineView;
	import moonshine.editor.text.events.TextEditorChangeEvent;
	import actionScripts.ui.tabview.CloseTabEvent;
	import actionScripts.plugin.settings.ISettingsProvider;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.BooleanSetting;
	import mx.collections.ArrayCollection;
	import actionScripts.plugin.settings.vo.DropDownListSetting;
	import actionScripts.plugin.settings.event.SetSettingsEvent;

	public class OutlinePlugin extends PluginBase implements ISettingsProvider
	{
		public static const EVENT_OUTLINE:String = "EVENT_OUTLINE";

		private static const LANGUAGE_SERVER_CAPABILITY_DOCUMENT_SYMBOLS:String = "textDocument/documentSymbol";

		public function OutlinePlugin()
		{
			super();
			
			outlineView = new OutlineView();
			outlineView.addEventListener(Event.CHANGE, outlineView_changeHandler);
			outlineView.addEventListener(Event.CLOSE, outlineView_closeHandler);
			outlineView.addEventListener(OutlineView.EVENT_SORT_CHANGE, outlineView_sortChangeHandler);
			outlineViewWrapper = new OutlineViewWrapper(outlineView);
			outlineViewWrapper.percentWidth = 100;
			outlineViewWrapper.percentHeight = 100;

			changeTimer = new Timer(500, 1);
			changeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, changeTimer_timerCompleteHandler);
		}

		override public function get name():String { return "Outline Plugin"; }
		override public function get author():String { return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String { return "Displays an outline of the symbols in a source file."; }

		private var _sortBy:String = OutlineView.SORT_BY_POSITION;

		public function get sortBy():String {
			return _sortBy;
		}

		public function set sortBy(value:String):void {
			_sortBy = value;
			outlineView.sortBy = value;
		}
		
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
			dispatcher.addEventListener(CloseTabEvent.EVENT_TAB_CLOSED, handleTabClose);
			dispatcher.addEventListener(TabEvent.EVENT_TAB_SELECT, handleTabSelect);
			dispatcher.addEventListener(ProjectEvent.LANGUAGE_SERVER_OPENED, handleLanguageServerOpened);
			dispatcher.addEventListener(ProjectEvent.LANGUAGE_SERVER_REGISTER_CAPABILITY, handleLanguageServerRegisterCapability);
			dispatcher.addEventListener(SaveFileEvent.FILE_SAVED, handleDidSave);
		}

		override public function deactivate():void
		{
			super.deactivate();
			dispatcher.removeEventListener(EVENT_OUTLINE, handleOutlineShow);
			dispatcher.removeEventListener(CloseTabEvent.EVENT_TAB_CLOSED, handleTabClose);
			dispatcher.removeEventListener(TabEvent.EVENT_TAB_SELECT, handleTabSelect);
			dispatcher.removeEventListener(ProjectEvent.LANGUAGE_SERVER_OPENED, handleLanguageServerOpened);
			dispatcher.removeEventListener(SaveFileEvent.FILE_SAVED, handleDidSave);
		}

        public function getSettingsList():Vector.<ISetting>
        {
			return new <ISetting>[
				new DropDownListSetting(this, "sortBy", "Sort By", new ArrayCollection([
					{ value: OutlineView.SORT_BY_POSITION },
					{ value: OutlineView.SORT_BY_NAME },
					{ value: OutlineView.SORT_BY_CATEGORY },
				]), "value")
			];
        }
		
		override public function onSettingsClose():void
		{
			// if (pathSetting)
			// {
			// 	pathSetting.removeEventListener(AbstractSetting.PATH_SELECTED, onSDKPathSelected);
			// 	pathSetting = null;
			// }
		}

		private function handleLanguageServerOpened(event:ProjectEvent):void
		{
			//start fresh because it's a new language server instance
			var collection:ArrayHierarchicalCollection = outlineView.outline;
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
			var collection:ArrayHierarchicalCollection = outlineView.outline;
			collection.removeAll();

			//we may have tried to refresh the symbols previously, but it would
			//not have been successful because the language server did not have
			//this capability registered yet
			this.refreshSymbols();
		}

		private function handleOutlineShow(event:Event):void
		{
			var collection:ArrayHierarchicalCollection = outlineView.outline;
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
			var collection:ArrayHierarchicalCollection = outlineView.outline;
			collection.removeAll();

			if(!symbols || symbols.length == 0)
			{
				return;
			}

			collection = new ArrayHierarchicalCollection(null, function(item:Object):Array
			{
				if (item is DocumentSymbol)
				{
					return DocumentSymbol(item).children;
				}
				return null;
			});

			var itemCount:int = symbols.length;
			for(var i:int = 0; i < itemCount; i++)
			{
				var symbol:Object = symbols[i];
				if(symbol is SymbolInformation)
				{
					var symbolInfo:SymbolInformation = symbol as SymbolInformation;
					collection.addAt(symbolInfo, [i]);
				}
				else if(symbol is DocumentSymbol)
				{
					var documentSymbol:DocumentSymbol = symbol as DocumentSymbol;
					collection.addAt(documentSymbol, [i]);
				}
			}
			outlineView.outline = collection;
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
				var collection:ArrayHierarchicalCollection = outlineView.outline;
				collection.removeAll();
				return;
			}
			lspEditor.languageClient.documentSymbols({
				textDocument: {
					uri: lspEditor.currentFile.fileBridge.url
				}
			}, handleShowDocumentSymbols);
		}

		private function handleTabClose(event:CloseTabEvent):void
		{
			if (_activeEditor != event.tab)
			{
				return;
			}
			//we closed the current file, so remove the old symbols
			var collection:ArrayHierarchicalCollection = outlineView.outline;
			collection.removeAll();

			setActiveEditor(null);

			//nothing to refresh, wait for tab select
		}

		private function handleTabSelect(event:TabEvent):void
		{
			if (_activeEditor != event.child) {
				//we switched to a different file, so remove the old symbols
				var collection:ArrayHierarchicalCollection = outlineView.outline;
				collection.removeAll();
			}

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

		private function outlineView_sortChangeHandler(event:Event):void {
			sortBy = outlineView.sortBy;
			var thisSettings:Vector.<ISetting> = getSettingsList();
			dispatcher.dispatchEvent(new SetSettingsEvent(SetSettingsEvent.SAVE_SPECIFIC_PLUGIN_SETTING, null, "actionScripts.plugin.outline::OutlinePlugin", thisSettings));
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