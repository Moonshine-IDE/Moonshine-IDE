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
package actionScripts.plugin.findreplace
{
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.findreplace.view.SearchView;
	import actionScripts.ui.editor.BasicTextEditor;
	import actionScripts.ui.editor.text.vo.SearchResult;
	import actionScripts.ui.menu.MenuPlugin;
	import actionScripts.utils.TextUtil;
	
	import components.popup.FindResourcePopup;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;

	public class FindReplacePlugin extends PluginBase
	{
		public static const EVENT_FIND_NEXT:String = "findNextEvent";
		public static const EVENT_FIND_PREV:String = "findPrevEvent";
		public static const EVENT_REPLACE_ONE:String = "replaceOneEvent";
		public static const EVENT_REPLACE_ALL:String = "replaceAllEvent";
		public static const EVENT_FIND_RESOURCE: String = "fineResource";
		
		private var lastSearchQuery:String;
		private var lastSearchNumResults:int;
		
		private var searchView:SearchView;
		private var resourceSearchView:FindResourcePopup;
		
		private var searchReplaceRe:RegExp = /^(?:\/)?((?:\\[^\/]|\\\/|\[(?:\\[^\]]|\\\]|[^\\\]])+\]|[^\[\]\\\/])+)\/((?:\\[^\/]|\\\/|[^\\\/])+)?(?:\/([gismx]*))?$/
		private var tempObj:Object;
		
		public function FindReplacePlugin()
		{
			super();
		}
		
		override public function get author():String { return "Moonshine Project Team"; }
		override public function get description():String { return "Provides Find/Replace"; }
		override public function get name():String { return "Find & Replace"; }
		
		override public function activate():void
		{
			super.activate()
			
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
			
			/*registerCommand('f',"", search);
			registerCommand('sr', "",search);
			registerCommand('sr',"", searchRegexp);*/
			
			GlobalEventDispatcher.getInstance().addEventListener(EVENT_FIND_NEXT, handleSearch);
			GlobalEventDispatcher.getInstance().addEventListener(EVENT_FIND_PREV, handleSearch);
			GlobalEventDispatcher.getInstance().addEventListener(EVENT_FIND_RESOURCE, findResource);
		}
		
		/*public function getMenu():MenuItem
		{
			// Since plugin will be activated if needed we can return null to block menu
			if( !_activated ) return null;
			return new MenuItem(
					"Search/Replace", 
					[
						new MenuItem("Find", null, EVENT_FIND_NEXT,
							 'f', [Keyboard.COMMAND],
							 'f', [Keyboard.CONTROL]),
						new MenuItem("Find previous", null, EVENT_FIND_PREV,
							 'f', [Keyboard.COMMAND, Keyboard.SHIFT],
							 'f', [Keyboard.CONTROL, Keyboard.SHIFT]),
					]
			);
		}*/
		
		protected function handleSearch(event:Event):void
		{
			// No searching for other components than BasicTextEditor
			if (!model.activeEditor || (model.activeEditor as BasicTextEditor) == null) return;
			
			if (searchView)
			{
				dialogSearch(event);
			}
			else
			{
				searchView = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, SearchView, false) as SearchView;
				
				// Set initial selection
				var editor:BasicTextEditor = BasicTextEditor(model.activeEditor);
				var str:String = editor.getEditorComponent().getSelection(); 
				if (str.indexOf("\n") == -1) 
				{
					searchView.initialSearchString = str;
				}
				
				searchView.addEventListener(Event.CLOSE, handleSearchViewClose);
				searchView.addEventListener(EVENT_FIND_NEXT, dialogSearch);
				searchView.addEventListener(EVENT_FIND_PREV, dialogSearch);
				searchView.addEventListener(EVENT_REPLACE_ALL, dialogSearch);
				searchView.addEventListener(EVENT_REPLACE_ONE, dialogSearch);
				
				// Close window when app is closed
				dispatcher.addEventListener(MenuPlugin.MENU_QUIT_EVENT, closeSearchView);
				PopUpManager.centerPopUp(searchView);
			}
		}
		
		protected function findResource(event:Event):void
		{
			if (!resourceSearchView)
			{
				resourceSearchView = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, FindResourcePopup, false) as FindResourcePopup;
				resourceSearchView.addEventListener(CloseEvent.CLOSE, handleResourceSearchViewClose);
				
				PopUpManager.centerPopUp(resourceSearchView);
			}
		}
		
		protected function closeSearchView(event:Event):void
		{
			PopUpManager.removePopUp(searchView);
		}
		
		protected function handleSearchViewClose(event:Event):void
		{
			searchView.removeEventListener(Event.CLOSE, handleSearchViewClose);
			searchView.removeEventListener(EVENT_FIND_NEXT, dialogSearch);
			searchView.removeEventListener(EVENT_FIND_PREV, dialogSearch);
			searchView.removeEventListener(EVENT_REPLACE_ALL, dialogSearch);
			searchView.removeEventListener(EVENT_REPLACE_ONE, dialogSearch);
			
			dispatcher.removeEventListener(MenuPlugin.MENU_QUIT_EVENT, closeSearchView);
			
			searchView = null;
		}
		
		protected function handleResourceSearchViewClose(event:CloseEvent):void
		{
			resourceSearchView.removeEventListener(CloseEvent.CLOSE, handleResourceSearchViewClose);
			resourceSearchView = null;
		}
		
		protected function search(args:Array):void
		{
			var editor:BasicTextEditor = model.activeEditor as BasicTextEditor;
			if (editor && args.length)
			{
				var search:String = args[0];
				if (search == "" || search == null) return;
				var res:SearchResult = editor.search(search, false);
				
				if (res.totalMatches == 0)
				{
					print("No matches for '%s'", search);
				}
				else
				{
					print("%s matches for '%s'", res.totalMatches, search);
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
					var res:SearchResult;
					
					if (replace)
					{
						res = editor.searchReplace(re, replace, hadGlobalFlag);
						
						if (res.totalReplaces > 0)
						{
							print("Replaced %s occurances of '%s'", res.totalReplaces, search);
						}
						else
						{
							print("No matches for '%s'", search);	
						}
					}
					else
					{	
						res = editor.search(re);
						if (res.totalMatches == 0)
						{
							print("No matches for '%s'", search);
						}
						else
						{
							print("%s matches for '%s'", res.totalMatches, search);
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
			
			var searchText:String = searchView.findInput.text;
			var replaceText:String = searchView.replaceInput.text;
			var searchRegExp:RegExp;
			
			if (searchText == "") return;
			
			if (searchView.optionRegExp.selected)
			{
				var flags:String = 'g';
				if (!searchView.optionMatchCase.selected) flags += 'i';
				if (searchView.optionEscapeChars.selected) searchText = TextUtil.escapeRegex(searchText);
				searchRegExp = new RegExp(searchText, flags);
			} 
			else if (searchView.optionMatchCase.selected == false)
			{
				// We need to use regexp for case non-matching,
				//  but we hide that from the user. (always escape chars)
				flags = 'gi';
				searchText = TextUtil.escapeRegex(searchText);
				searchRegExp = new RegExp(searchText, flags);
			}
			
			var result:SearchResult;
			
			// Perform search of type
			if (event.type == EVENT_FIND_NEXT)
			{
				result = editor.search(searchRegExp || searchText);	
			}
			else if (event.type == EVENT_FIND_PREV)
			{
				result = editor.search(searchRegExp || searchText, true);
			}
			else if (event.type == EVENT_REPLACE_ALL)
			{
				result = editor.searchReplace(searchRegExp || searchText, replaceText, true);
			}
			else if (event.type == EVENT_REPLACE_ONE)
			{
				result = editor.searchReplace(searchRegExp || searchText, replaceText, false);
			}
			
			// Display # of matches & position if any
			if (result.totalMatches > 0)
			{
				searchView.findInput.resultText = (result.selectedIndex+1) + "/" + result.totalMatches;
			}
			else
			{
				searchView.findInput.resultText = result.totalMatches.toString();
			}
		}
		
	}
}
