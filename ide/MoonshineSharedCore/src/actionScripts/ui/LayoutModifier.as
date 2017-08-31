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
package actionScripts.ui
{
	import flash.events.Event;
	import flash.net.SharedObject;
	
	import mx.core.FlexGlobals;
	
	import actionScripts.events.GeneralEvent;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.locator.IDEModel;

	public class LayoutModifier
	{
		public static const SAVE_LAYOUT_CHANGE_EVENT:String = "SAVE_LAYOUT_CHANGE_EVENT";
		public static const CONSOLE_COLLAPSED_FIELD:String = "isConsoleCollapsed";
		public static const CONSOLE_HEIGHT:String = "consoleHeight";
		public static const SIDEBAR_WIDTH:String = "sidebarWidth";
		public static const IS_MAIN_WINDOW_MAXIMIZED:String = "isMainWindowMaximized";
		public static const SIDEBAR_CHILDREN:String = "sidebarChildren";
		
		private static const dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private static const model:IDEModel = IDEModel.getInstance();

		public static var isSidebarCreated:Boolean;
		public static var sidebarChildren:Array;
		
		public static function parseCookie(value:SharedObject):void
		{
			if (value.data.hasOwnProperty(CONSOLE_COLLAPSED_FIELD)) isConsoleCollapsed = value.data[CONSOLE_COLLAPSED_FIELD];
			if (value.data.hasOwnProperty(CONSOLE_HEIGHT)) consoleHeight = value.data[CONSOLE_HEIGHT];
			if (value.data.hasOwnProperty(IS_MAIN_WINDOW_MAXIMIZED)) isAppMaximized = value.data[IS_MAIN_WINDOW_MAXIMIZED];
			if (value.data.hasOwnProperty(SIDEBAR_WIDTH)) sidebarWidth = value.data[SIDEBAR_WIDTH];
			if (value.data.hasOwnProperty(SIDEBAR_CHILDREN)) sidebarChildren = value.data[SIDEBAR_CHILDREN];
			
			if (isAppMaximized) FlexGlobals.topLevelApplication.stage.nativeWindow.maximize();
			if (sidebarWidth != -1) model.mainView.sidebar.width = (sidebarWidth >= 0) ? sidebarWidth : 0;
		}
		
		public static function saveLastSidebarState():void
		{
			var numChildren:int = model.mainView.sidebar.numChildren;
			if (numChildren == 0) return;
			
			var ordering:Array = [];
			for (var i:int=0; i < numChildren; i ++)
			{
				var tmpSection:Object = model.mainView.sidebar.getChildAt(i);
				ordering.push({className: tmpSection.className, height: tmpSection.percentHeight});
			}
			
			// saving sidebar last state
			dispatcher.dispatchEvent(new GeneralEvent(SAVE_LAYOUT_CHANGE_EVENT, {label:SIDEBAR_CHILDREN, value:ordering}));
		}
		
		public static function addToSidebar(section:IPanelWindow, event:Event = null):void
		{
			model.mainView.addPanel(section);
			if (event is GeneralEvent && GeneralEvent(event).value) section.percentHeight = int(GeneralEvent(event).value);
			else LayoutModifier.justifyHeights(section);
		}
		
		public static function justifyHeights(section:IPanelWindow):void
		{
			if (!isSidebarCreated) return;
			
			var numChildren:int = model.mainView.sidebar.numChildren;
			if (numChildren == 0) return;
			
			var childWithLargestHeight:IPanelWindow;
			for (var i:int=0; i < numChildren; i ++)
			{
				var tmpSection:IPanelWindow = model.mainView.sidebar.getChildAt(i) as IPanelWindow;
				if (!childWithLargestHeight) childWithLargestHeight = tmpSection;
				else if (section != tmpSection && tmpSection.height > childWithLargestHeight.height) childWithLargestHeight = tmpSection;
			}
			
			if (childWithLargestHeight) 
			{
				childWithLargestHeight.percentHeight = childWithLargestHeight.percentHeight / 2;
				section.percentHeight = childWithLargestHeight.percentHeight;
			}
		}
		
		private static var _isConsoleCollapsed:Boolean;
		
		public static function get isConsoleCollapsed():Boolean
		{
			return _isConsoleCollapsed;
		}
		public static function set isConsoleCollapsed(value:Boolean):void
		{
			_isConsoleCollapsed = value;
			dispatcher.dispatchEvent(new GeneralEvent(SAVE_LAYOUT_CHANGE_EVENT, {label:CONSOLE_COLLAPSED_FIELD, value:value}));
		}
		
		private static var _consoleHeight:int = -1;
		
		public static function get consoleHeight():int
		{
			return _consoleHeight;
		}
		public static function set consoleHeight(value:int):void
		{
			_consoleHeight = value;
			dispatcher.dispatchEvent(new GeneralEvent(SAVE_LAYOUT_CHANGE_EVENT, {label:CONSOLE_HEIGHT, value:value}));
		}
		
		private static var _sidebarWidth:int = -1;
		
		public static function get sidebarWidth():int
		{
			return _sidebarWidth;
		}
		public static function set sidebarWidth(value:int):void
		{
			_sidebarWidth = value;
			dispatcher.dispatchEvent(new GeneralEvent(SAVE_LAYOUT_CHANGE_EVENT, {label:SIDEBAR_WIDTH, value:value}));
		}
		
		private static var _isAppMaximized:Boolean;
		
		public static function get isAppMaximized():Boolean
		{
			return _isAppMaximized;
		}
		public static function set isAppMaximized(value:Boolean):void
		{
			_isAppMaximized = value;
			dispatcher.dispatchEvent(new GeneralEvent(SAVE_LAYOUT_CHANGE_EVENT, {label:IS_MAIN_WINDOW_MAXIMIZED, value:value}));
		}
	}
}