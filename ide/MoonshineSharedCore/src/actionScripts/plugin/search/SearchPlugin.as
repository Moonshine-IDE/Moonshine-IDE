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
    }
}
