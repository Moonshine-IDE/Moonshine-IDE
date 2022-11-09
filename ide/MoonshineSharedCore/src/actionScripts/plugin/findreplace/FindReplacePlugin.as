////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2016-present Prominic.NET, Inc.
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
package actionScripts.plugin.findreplace
{
	import actionScripts.interfaces.IVisualEditorViewer;

	import flash.display.DisplayObject;
	import flash.events.Event;

	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;

	import actionScripts.events.ApplicationEvent;
	import actionScripts.events.GeneralEvent;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.ui.FeathersUIWrapper;
	import actionScripts.ui.editor.BasicTextEditor;
	import actionScripts.utils.TextUtil;
	import actionScripts.valueObjects.ConstantsCoreVO;

	import moonshine.editor.text.TextEditor;
	import moonshine.editor.text.TextEditorSearchResult;
	import moonshine.plugin.findreplace.view.FindReplaceView;
	import moonshine.plugin.findreplace.view.GoToLineView;
	import actionScripts.ui.tabview.TabEvent;
	import actionScripts.ui.IContentWindow;

	public class FindReplacePlugin extends PluginBase
	{
		public static const EVENT_FIND_NEXT:String = "findNextEvent";
		public static const EVENT_FIND_PREV:String = "findPrevEvent";
		public static const EVENT_FIND_SHOW_ALL:String = "findAndShowAllEvent";
		public static const EVENT_GO_TO_LINE:String = "goToLine";

		private var findReplaceView:FindReplaceView;
		private var findReplaceViewWrapper:FeathersUIWrapper;
		private var gotoLineView:GoToLineView;
		private var gotoLineViewWrapper:FeathersUIWrapper;
		
		private var searchReplaceRe:RegExp = /^(?:\/)?((?:\\[^\/]|\\\/|\[(?:\\[^\]]|\\\]|[^\\\]])+\]|[^\[\]\\\/])+)\/((?:\\[^\/]|\\\/|[^\\\/])+)?(?:\/([gismx]*))?$/;
		private var tempObj:Object;
		
		public function FindReplacePlugin()
		{
			super();
		}
		
		override public function get author():String { return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String { return "Provides Find/Replace"; }
		override public function get name():String { return "Find & Replace"; }
		
		override public function activate():void
		{
			super.activate();
			
			tempObj = new Object();
			tempObj.callback = search;
			tempObj.commandDesc = "Run a case-sensitive search in the currently open file.  Syntax:  f keyword";
			registerCommand("f",tempObj);
			
			tempObj = new Object();
			tempObj.callback = search;
			tempObj.commandDesc = "Same as 'f'.  Syntax:  s keyword";
			registerCommand("s",tempObj);
			
			tempObj = new Object();
			tempObj.callback = searchRegexp;
			tempObj.commandDesc = "Execute a regular expression in the currently open file.  See http://help.adobe.com/en_US/as3/dev/WS5b3ccc516d4fbf351e63e3d118a9b90204-7ea9.html .  Syntax:  sr /pattern/  -or-  sr /pattern/replacement/flags";
			registerCommand("sr",tempObj);

			dispatcher.addEventListener(TabEvent.EVENT_TAB_SELECT, tabSelectHandler);
			dispatcher.addEventListener(EVENT_FIND_NEXT, searchHandler);
            dispatcher.addEventListener(EVENT_FIND_PREV, searchHandler);
			dispatcher.addEventListener(EVENT_FIND_SHOW_ALL, findAndShowAllHandler);
			dispatcher.addEventListener(EVENT_GO_TO_LINE, goToLineRequestHandler);
			dispatcher.addEventListener(ApplicationEvent.APPLICATION_EXIT, applicationExitHandler);
		}
		
		override public function deactivate():void
		{
			dispatcher.removeEventListener(TabEvent.EVENT_TAB_SELECT, tabSelectHandler);
			dispatcher.removeEventListener(EVENT_FIND_NEXT, searchHandler);
            dispatcher.removeEventListener(EVENT_FIND_PREV, searchHandler);
			dispatcher.removeEventListener(EVENT_FIND_SHOW_ALL, findAndShowAllHandler);
			dispatcher.removeEventListener(EVENT_GO_TO_LINE, goToLineRequestHandler);
			dispatcher.removeEventListener(ApplicationEvent.APPLICATION_EXIT, applicationExitHandler);
		}
		
		protected function searchHandler(event:Event):void
		{
			// No searching for other components than BasicTextEditor
			if (!model.activeEditor || (model.activeEditor as BasicTextEditor) == null) return;
			
			if (findReplaceView)
			{
				dialogSearch(event);
			}
			else
			{
				findReplaceView = new FindReplaceView();
				findReplaceViewWrapper = new FeathersUIWrapper(findReplaceView);
				PopUpManager.addPopUp(findReplaceViewWrapper, FlexGlobals.topLevelApplication as DisplayObject, false);

				// this will not show replace field
				if (model.activeEditor is IVisualEditorViewer)
				{
					findReplaceView.findOnly = true;
				}

				// Set initial selection
				var editor:BasicTextEditor = BasicTextEditor(model.activeEditor);
				var str:String = editor.editor.selectedText; 
				if (str.indexOf("\n") == -1) 
				{
					findReplaceView.initialFindText = str;
				}

				findReplaceView.addEventListener(Event.CLOSE, handleFindReplaceViewClose);
				findReplaceView.addEventListener(FindReplaceView.EVENT_FIND_NEXT, dialogSearch);
				findReplaceView.addEventListener(FindReplaceView.EVENT_FIND_PREVIOUS, dialogSearch);
				findReplaceView.addEventListener(FindReplaceView.EVENT_REPLACE_ONE, dialogSearch);
				findReplaceView.addEventListener(FindReplaceView.EVENT_REPLACE_ALL, dialogSearch);

				PopUpManager.centerPopUp(findReplaceViewWrapper);
				findReplaceViewWrapper.assignFocus("top");
				findReplaceViewWrapper.stage.addEventListener(Event.RESIZE, findReplaceView_stage_resizeHandler, false, 0, true);
			}
		}
		
		protected function findAndShowAllHandler(event:GeneralEvent):void
		{
			// No searching for other components than BasicTextEditor
			if (!model.activeEditor || (model.activeEditor as BasicTextEditor) == null) return;

			var editor:BasicTextEditor = model.activeEditor as BasicTextEditor;
			// editor.searchAndShowAll(event.value.search);
			if(event.value.range) {
				var startLine:int = event.value.range.startLineIndex;
				var startChar:int = event.value.range.startCharIndex;
				var endLine:int = event.value.range.endLineIndex;
				var endChar:int = event.value.range.endCharIndex;
				editor.getEditorComponent().setSelection(startLine, startChar, endLine, endChar);
			}
		}

		private function tabSelectHandler(event:TabEvent):void
		{
			for each(var tab:IContentWindow in model.editors)
			{
				var editor:BasicTextEditor = tab as BasicTextEditor;
				if (!editor || editor == event.child)
				{
					continue;
				}
				editor.clearSearch();
			}
			if (findReplaceView)
			{
				findReplaceView.resultIndex = 0;
				findReplaceView.resultCount = 0;
			}
		}
		
		protected function goToLineRequestHandler(event:Event):void
		{
			var activeEditor:BasicTextEditor = model.activeEditor as BasicTextEditor;
			if (!activeEditor)
			{
				Alert.show("Cannot go to line. No text document is open.", ConstantsCoreVO.MOONSHINE_IDE_LABEL);
				return;
			}
			
			if (!gotoLineView)
			{
				gotoLineView = new GoToLineView();
				gotoLineViewWrapper = new FeathersUIWrapper(gotoLineView);
				PopUpManager.addPopUp(gotoLineViewWrapper, FlexGlobals.topLevelApplication as DisplayObject, true);
				gotoLineView.maxLineNumber = activeEditor.editor.lines.length;
				gotoLineView.addEventListener(Event.CLOSE, onGotoLineClosed);
				PopUpManager.centerPopUp(gotoLineViewWrapper);
				gotoLineViewWrapper.assignFocus("top");
				gotoLineViewWrapper.stage.addEventListener(Event.RESIZE, gotoLineView_stage_resizeHandler, false, 0, true);
			}
		}
		
		private function onGotoLineClosed(event:Event):void
		{
			if (gotoLineView.lineNumber != -1)
			{
				var editor:BasicTextEditor = model.activeEditor as BasicTextEditor;
				var tmpLineIndex:int = gotoLineView.lineNumber - 1;
				editor.setSelection(tmpLineIndex, 0, tmpLineIndex, 0);
				editor.scrollToCaret();
			}
			
			gotoLineViewWrapper.stage.removeEventListener(Event.RESIZE, gotoLineView_stage_resizeHandler);
			PopUpManager.removePopUp(gotoLineViewWrapper);
			gotoLineView.removeEventListener(Event.CLOSE, onGotoLineClosed);
			gotoLineView = null;
			gotoLineViewWrapper = null;
		}

		protected function gotoLineView_stage_resizeHandler(event:Event):void
		{
			PopUpManager.centerPopUp(gotoLineViewWrapper);
		}

		protected function findReplaceView_stage_resizeHandler(event:Event):void
		{
			PopUpManager.centerPopUp(findReplaceViewWrapper);
		}

		protected function applicationExitHandler(event:Event):void
		{
			if(findReplaceView)
			{
				findReplaceView.dispatchEvent(new Event(Event.CLOSE));
			}
			if(gotoLineView)
			{
				gotoLineView.dispatchEvent(new Event(Event.CLOSE));
			}
		}
		
		protected function handleFindReplaceViewClose(event:Event):void
		{
			var editor:BasicTextEditor = model.activeEditor as BasicTextEditor;
			if (editor)
			{
				editor.clearSearch();
			}
			findReplaceView.resultCount = 0;
			findReplaceView.resultIndex = 0;
			
			findReplaceViewWrapper.stage.removeEventListener(Event.RESIZE, findReplaceView_stage_resizeHandler);
			PopUpManager.removePopUp(findReplaceViewWrapper);
			findReplaceViewWrapper = null;

			findReplaceView.removeEventListener(Event.CLOSE, handleFindReplaceViewClose);
			findReplaceView.removeEventListener(FindReplaceView.EVENT_FIND_NEXT, dialogSearch);
			findReplaceView.removeEventListener(FindReplaceView.EVENT_FIND_PREVIOUS, dialogSearch);
			findReplaceView.removeEventListener(FindReplaceView.EVENT_REPLACE_ONE, dialogSearch);
			findReplaceView.removeEventListener(FindReplaceView.EVENT_REPLACE_ALL, dialogSearch);
			findReplaceView = null;
		}

		protected function search(args:Array):void
		{
			var editor:BasicTextEditor = model.activeEditor as BasicTextEditor;
			if (editor && args.length)
			{
				var search:String = args[0];
				if (search == "" || search == null) return;
				var res:TextEditorSearchResult = editor.search(search, false);
				
				if (res.results.length == 0)
				{
					print("No matches for '%s'", search);
				}
				else
				{
					print("%s matches for '%s'", res.results.length, search);
				}
			}	
		}
		
		protected function searchRegexp(args:Array):void
		{
			var editor:BasicTextEditor = model.activeEditor as BasicTextEditor;
			if (editor && args.length)
			{
				var str:String = args[0];
				if (str == "" || str == null) return;
				
				//var match:Array = editor.text.match(str);
				var match:Array = str.match(searchReplaceRe);
				if (match)
				{
					var search:String = match[1];
					if (search == "" || search == null) return;
					// it convert regexp string to normal string so always fail at serach for regexp string for eg. [sS]cript
					//search = TextUtil.escapeRegex(search);  
					var replace:String = match[2];
					var flags:String = match[3];
					
					var hadGlobalFlag:Boolean = (flags && flags.indexOf('g') != -1); 
					
					// Need global flag for searching
					if (!flags) flags = "g";
					if (flags.indexOf('g') == -1) flags += 'g';
					
					var re:RegExp = new RegExp(search, flags);
					var res:TextEditorSearchResult;
					
					if (replace)
					{
						res = editor.searchReplace(re, replace, hadGlobalFlag);
						
						if (res.replaced.length > 0)
						{
							print("Replaced %s occurances of '%s'", res.replaced.length, search);
						}
						else
						{
							print("No matches for '%s'", search);	
						}
					}
					else
					{	
						res = editor.search(re);
						if (res.results.length == 0)
						{
							print("No matches for '%s'", search);
						}
						else
						{
							print("%s matches for '%s'", res.results.length, search);
						}
					}
				}
				else
				{
					// Bad input.
					print("Unknown format. Usage: sr /search/ or /search/replace/flags");
				}
			}
		}
		
		protected function dialogSearch(event:Event):void
		{
			var editor:BasicTextEditor = model.activeEditor as BasicTextEditor;
			var needsNewSearch:Boolean = false;
			
			var searchText:String = findReplaceView.findText;
			var replaceText:String = findReplaceView.replaceText;
			var searchRegExp:RegExp;
			
			if (!editor || searchText == "") return;
			
			if (findReplaceView.regExpEnabled)
			{
				var flags:String = 'g';
				if (!findReplaceView.matchCaseEnabled) flags += 'i';
				if (findReplaceView.escapeCharsEnabled) searchText = TextUtil.escapeRegex(searchText);
				searchRegExp = new RegExp(searchText, flags);
			} 
			else if (findReplaceView.matchCaseEnabled == false)
			{
				// We need to use regexp for case non-matching,
				//  but we hide that from the user. (always escape chars)
				flags = 'gi';
				searchText = TextUtil.escapeRegex(searchText);
				searchRegExp = new RegExp(searchText, flags);
			}
			
			var result:TextEditorSearchResult;
			
			// Perform search of type
			if (event.type == FindReplaceView.EVENT_FIND_NEXT)
			{
				result = editor.search(searchRegExp || searchText);	
			}
			else if (event.type == FindReplaceView.EVENT_FIND_PREVIOUS)
			{
				result = editor.search(searchRegExp || searchText, true);
			}
			else if (event.type == FindReplaceView.EVENT_REPLACE_ONE)
			{
				result = editor.searchReplace(searchRegExp || searchText, replaceText, false);
			}
			else if (event.type == FindReplaceView.EVENT_REPLACE_ALL)
			{
				result = editor.searchReplace(searchRegExp || searchText, replaceText, true);
			}
			
			// Display # of matches & position if any
			if (result.results.length > 0)
			{
				findReplaceView.resultCount = result.results.length;
				findReplaceView.resultIndex = (result.selectedIndex + 1);
			}
			else
			{
				findReplaceView.resultCount = result.results.length;
				findReplaceView.resultIndex = 0;
			}

			var as3Project:AS3ProjectVO = model.activeProject as AS3ProjectVO;
			if (as3Project)
			{
				if (as3Project.isVisualEditorProject)
				{
					dispatcher.dispatchEvent(new Event("switchTabToCode"));
				}
			}
		}
		
	}
}
