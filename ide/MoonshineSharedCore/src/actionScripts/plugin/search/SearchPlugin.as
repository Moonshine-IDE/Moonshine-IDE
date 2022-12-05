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
package actionScripts.plugin.search
{
	import actionScripts.ui.FeathersUIWrapper;

	import flash.display.DisplayObject;
    import flash.events.Event;

	import moonshine.plugin.search.events.SearchViewEvent;

	import moonshine.plugin.search.view.SearchView;

    import mx.core.FlexGlobals;
    import mx.events.CollectionEvent;
    import mx.events.CollectionEventKind;
    import mx.managers.PopUpManager;
    
    import actionScripts.events.AddTabEvent;
    import actionScripts.events.GlobalEventDispatcher;
    import actionScripts.plugin.PluginBase;
    import actionScripts.ui.IContentWindow;
    import actionScripts.ui.tabview.TabEvent;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import actionScripts.valueObjects.ProjectVO;

    import components.views.other.SearchInProjectView;
	import feathers.data.ArrayCollection;
	import mx.events.DynamicEvent;
	import actionScripts.events.OpenFileEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.utils.TextUtil;
	import flash.utils.setTimeout;
	import flash.utils.clearTimeout;
	import actionScripts.events.GeneralEvent;
	import actionScripts.plugin.findreplace.FindReplacePlugin;

    public class SearchPlugin extends PluginBase
    {
		public static const SEARCH_IN_PROJECTS:String = "SEARCH_IN_PROJECTS";
		public static const WORKSPACE:String = "WORKSPACE";
		private static const PROJECT:String = "PROJECT";

		public static var previouslySelectedPatterns:ArrayCollection;
		public static var previouslySelectedScope:int = 1;
		public static var previouslySelectedIncludeExternalSourcePath:Boolean;
		public static var previousSearchPhrase:String;
		public static var previouslySelectedProject:ProjectVO;

		[Bindable]
		public static var isReplaceActive:Boolean;

		private var searchView:SearchView;
		private var searchViewWrapper:FeathersUIWrapper;

		private var searchResultView:SearchInProjectView;

		private var isCollectionChangeListenerAdded:Boolean;
		
        override public function get name():String 	{return "Search in Projects";}
        override public function get author():String {return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team";}
        override public function get description():String 	{return "Search string in one or multiple project files.";}

        public function SearchPlugin()
        {
            super();
        }

        override public function activate():void
        {
            dispatcher.addEventListener(SEARCH_IN_PROJECTS, onSearchRequested, false, 0, true);
            super.activate();
        }

        override public function deactivate():void
        {
			dispatcher.removeEventListener(SEARCH_IN_PROJECTS, onSearchRequested);
            super.deactivate();
        }
		
		protected function onSearchRequested(event:Event):void
		{
			// probable termination
			if (model.projects.length == 0) return;

			if (!searchView)
			{
				searchView = new SearchView();
				searchView.addEventListener(SearchViewEvent.SEARCH_PHRASE, searchView_searchPhraseHandler);
				searchView.addEventListener(SearchViewEvent.REPLACE_PHRASE, searchView_replacePhraseHandler);
				searchView.addEventListener(Event.CLOSE, searchView_closeHandler);

				searchViewWrapper = new FeathersUIWrapper(searchView);
				PopUpManager.addPopUp(searchViewWrapper, FlexGlobals.topLevelApplication as DisplayObject, false);
				PopUpManager.centerPopUp(searchViewWrapper);

				searchViewWrapper.assignFocus("top");
				searchViewWrapper.stage.addEventListener(Event.RESIZE, searchView_stage_resizeHandler, false, 0, true);

				searchView.projects = new feathers.data.ArrayCollection(model.projects.source);
				searchView.selectedProject = model.activeProject;

				if(!previouslySelectedPatterns)
				{
					previouslySelectedPatterns = new ArrayCollection();
					for each (var extension:String in ConstantsCoreVO.READABLE_FILES)
					{
						previouslySelectedPatterns.add({label: extension, isSelected: false});
					}
				}

				searchView.patterns = previouslySelectedPatterns;

				if (!isCollectionChangeListenerAdded) 
				{
					model.projects.addEventListener(CollectionEvent.COLLECTION_CHANGE, onProjectsCollectionChanged, false, 0, true);
					isCollectionChangeListenerAdded = true;
				}
			}
			else
			{
				searchViewWrapper.assignFocus("top");
			}
		}
		
		private function onProjectsCollectionChanged(event:CollectionEvent):void
		{
			if (event.kind == CollectionEventKind.REMOVE && event.items[0] == previouslySelectedProject)
			{
				previouslySelectedPatterns = null;
			}
		}

		private function searchView_searchPhraseHandler(event:SearchViewEvent):void
		{
			previouslySelectedScope = event.selectedSearchScopeIndex;
			previousSearchPhrase = event.searchText;
			previouslySelectedIncludeExternalSourcePath = event.includeExternalSourcePath;
			previouslySelectedProject = event.selectedProject;

			initializeSearchView(event, false);
		}

		private function searchView_replacePhraseHandler(event:SearchViewEvent):void
		{
			previouslySelectedScope = event.selectedSearchScopeIndex;
			previousSearchPhrase = event.searchText;
			previouslySelectedIncludeExternalSourcePath = event.includeExternalSourcePath;
			previouslySelectedProject = event.selectedProject;

			initializeSearchView(event, true);
		}

		private function searchView_closeHandler(event:Event):void
		{
			previouslySelectedPatterns = searchView.patterns;
			isReplaceActive = false;

			searchViewWrapper.stage.removeEventListener(Event.RESIZE, searchView_stage_resizeHandler);
			PopUpManager.removePopUp(searchViewWrapper);

			searchView.removeEventListener(SearchViewEvent.SEARCH_PHRASE, searchView_searchPhraseHandler);
			searchView.removeEventListener(SearchViewEvent.REPLACE_PHRASE, searchView_replacePhraseHandler);
			searchView.removeEventListener(Event.CLOSE, searchView_closeHandler);
			searchView = null;
			searchViewWrapper = null;
		}

		private function initializeSearchView(event:SearchViewEvent, isReplace:Boolean):void
		{
			if (!searchResultView)
			{
				searchResultView = new SearchInProjectView();
				searchResultView.addEventListener("openResult", onOpenSearchResult);
				searchResultView.addEventListener(TabEvent.EVENT_TAB_CLOSE, onSearchResultsClosed);
				updateSearchViewProperties(event, isReplace);

				// adding as a tab
				GlobalEventDispatcher.getInstance().dispatchEvent(
						new AddTabEvent(searchResultView as IContentWindow)
				);
			}
			else
			{
				// another new search initiated
				// while existing search tab already opens
				updateSearchViewProperties(event, isReplace);
				model.activeEditor = searchResultView;
				searchResultView.resetSearch();
			}
		}

		private function updateSearchViewProperties(event:SearchViewEvent, isReplace:Boolean = false):void
		{
			searchResultView.valueToSearch = event.searchText;
			searchResultView.patterns = event.patternsText;
			searchResultView.scope = event.selectedSearchScopeIndex == 0 ? SearchPlugin.WORKSPACE : SearchPlugin.PROJECT;
			searchResultView.isEnclosingProjects = event.includeExternalSourcePath;
			searchResultView.isMatchCase = event.matchCaseEnabled;
			searchResultView.isRegexp = event.regExpEnabled;
			searchResultView.isEscapeChars = event.escapeCharsEnabled;
			searchResultView.isShowReplaceWhenDone = isReplace;
			searchResultView.selectedProjectToSearch = previouslySelectedProject ? previouslySelectedProject : null;
		}
		protected function searchView_stage_resizeHandler(event:Event):void
		{
			PopUpManager.centerPopUp(searchViewWrapper);
		}

		private function onSearchResultsClosed(event:TabEvent):void
		{
			event.target.removeEventListener(TabEvent.EVENT_TAB_CLOSE, onSearchResultsClosed);
			searchResultView = null;
		}

		private function onOpenSearchResult(event:DynamicEvent):void
		{
			var tmpFL:FileLocation = event.fileLocation;
			var range:Object = event.range;
			var line:int = range ? range.startLineIndex : -1;
			var searchResultView:SearchInProjectView = SearchInProjectView(event.currentTarget);
			var isEscapeChars:Boolean = searchResultView.isEscapeChars;
			var isMatchCase:Boolean = searchResultView.isMatchCase;
			var valueToSearch:String = searchResultView.valueToSearch;
			
			var openEvent:OpenFileEvent = new OpenFileEvent(OpenFileEvent.JUMP_TO_SEARCH_LINE, [tmpFL], line);
			dispatcher.dispatchEvent(openEvent);
				
			// this needs some timeout to get the tab open first
			var timeoutValue:uint = setTimeout(function():void
			{
				var searchString:String = isEscapeChars ? TextUtil.escapeRegex(valueToSearch) : valueToSearch;
				var flags:String = 'g';
				if (!isMatchCase) flags += 'i';
				var searchRegExp:RegExp = new RegExp(searchString, flags);
				
				dispatcher.dispatchEvent(
					new GeneralEvent(FindReplacePlugin.EVENT_FIND_SHOW_ALL, {search:searchRegExp, range: range})
				);
				clearTimeout(timeoutValue);
			}, 300);
		}
    }
}
