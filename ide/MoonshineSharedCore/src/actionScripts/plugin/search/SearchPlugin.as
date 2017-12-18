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
    import flash.display.DisplayObject;
    import flash.events.Event;
    
    import mx.core.FlexGlobals;
    import mx.events.CloseEvent;
    import mx.managers.PopUpManager;
    
    import actionScripts.events.AddTabEvent;
    import actionScripts.events.GlobalEventDispatcher;
    import actionScripts.plugin.PluginBase;
    import actionScripts.ui.IContentWindow;
    
    import components.popup.SearchInProjectPopup;
    import components.views.other.SearchInProjectView;

    public class SearchPlugin extends PluginBase
    {
		public static const SEARCH_IN_PROJECTS:String = "SEARCH_IN_PROJECTS";
		public static const WORKSPACE:String = "WORKSPACE";
		public static const PROJECT:String = "PROJECT";
		public static const LINKED_PROJECTS:String = "LINKED_PROJECTS";
		
		private var searchPopup:SearchInProjectPopup;
		
        override public function get name():String 	{return "Search in Projects";}
        override public function get author():String {return "Moonshine Project Team";}
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
			
			if (!searchPopup)
			{
				searchPopup = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, SearchInProjectPopup, false) as SearchInProjectPopup;
				searchPopup.addEventListener(CloseEvent.CLOSE, onSearchPopupClosed);
				PopUpManager.centerPopUp(searchPopup);
			}
			else
			{
				PopUpManager.bringToFront(searchPopup);
			}
		}
		
		private function onSearchPopupClosed(event:CloseEvent):void
		{
			event.target.removeEventListener(CloseEvent.CLOSE, onSearchPopupClosed);
			
			// probable termination
			if (!searchPopup.isClosedAsSubmit)
			{
				searchPopup = null;
				return;
			}
			
			var tmpTab:SearchInProjectView = new SearchInProjectView();
			tmpTab.valueToSearch = searchPopup.txtSearch.text;
			tmpTab.patterns = searchPopup.txtPatterns.text;
			tmpTab.scope = String(searchPopup.rbgScope.selectedValue);
			tmpTab.isMatchCase = searchPopup.optionMatchCase.selected;
			tmpTab.isRegexp = searchPopup.optionRegExp.selected;
			
			searchPopup = null;
			
			// adding as a tab
			GlobalEventDispatcher.getInstance().dispatchEvent(
				new AddTabEvent(tmpTab as IContentWindow)
			);
		}
    }
}
