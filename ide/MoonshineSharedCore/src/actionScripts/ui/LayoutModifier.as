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
	import flash.net.SharedObject;
	
	import mx.core.FlexGlobals;
	
	import actionScripts.events.GeneralEvent;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.locator.IDEModel;

	public class LayoutModifier
	{
		public static const SAVE_LAYOUT_CHANGE_EVENT:String = "SAVE_LAYOUT_CHANGE_EVENT";
		public static const TOURDE_FLEX_FIELD:String = "isTourDeWindow";
		public static const USEFULLINKS_FIELD:String = "isUsefulLinksWindow";
		public static const CONSOLE_COLLAPSED_FIELD:String = "isConsoleCollapsed";
		public static const PROBLEMS_VIEW_FIELD:String = "isProblemsWindow";
		public static const DEBUG_FIELD:String = "isDebugWindow";
		public static const CONSOLE_HEIGHT:String = "consoleHeight";
		public static const SIDEBAR_WIDTH:String = "sidebarWidth";
		public static const IS_MAIN_WINDOW_MAXIMIZED:String = "isMainWindowMaximized";
		
		private static const dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		
		public static function parseCookie(value:SharedObject):void
		{
			if (value.data.hasOwnProperty(TOURDE_FLEX_FIELD)) isTourDeFlex = value.data[TOURDE_FLEX_FIELD];
			if (value.data.hasOwnProperty(USEFULLINKS_FIELD)) isUsefulLinks = value.data[USEFULLINKS_FIELD];
			if (value.data.hasOwnProperty(PROBLEMS_VIEW_FIELD)) isProblemsWindow = value.data[PROBLEMS_VIEW_FIELD];
			if (value.data.hasOwnProperty(DEBUG_FIELD)) isDebugWindow = value.data[DEBUG_FIELD];
			if (value.data.hasOwnProperty(CONSOLE_COLLAPSED_FIELD)) isConsoleCollapsed = value.data[CONSOLE_COLLAPSED_FIELD];
			if (value.data.hasOwnProperty(CONSOLE_HEIGHT)) consoleHeight = value.data[CONSOLE_HEIGHT];
			if (value.data.hasOwnProperty(IS_MAIN_WINDOW_MAXIMIZED)) isAppMaximized = value.data[IS_MAIN_WINDOW_MAXIMIZED];
			if (value.data.hasOwnProperty(SIDEBAR_WIDTH)) sidebarWidth = value.data[SIDEBAR_WIDTH];
			
			if (isAppMaximized) FlexGlobals.topLevelApplication.stage.nativeWindow.maximize();
			if (sidebarWidth != -1) IDEModel.getInstance().mainView.sidebar.width = (sidebarWidth >= 0) ? sidebarWidth : 0;
		}
		
		public static function setButNotSaveValue(type:String, value:Boolean):void
		{
			switch (type)
			{
				case TOURDE_FLEX_FIELD:
					_isTourDeFlex = value;
					break;
				case USEFULLINKS_FIELD:
					_isUsefulLinks = value;
					break;
				case PROBLEMS_VIEW_FIELD:
					_isProblemsWindow = value;
					break;
				case DEBUG_FIELD:
					_isDebugWindow = value;
					break;
			}
		}
		
		private static var _isTourDeFlex:Boolean = true;
		
		public static function get isTourDeFlex():Boolean
		{
			return _isTourDeFlex;
		}
		public static function set isTourDeFlex(value:Boolean):void
		{
			_isTourDeFlex = value;
			dispatcher.dispatchEvent(new GeneralEvent(SAVE_LAYOUT_CHANGE_EVENT, {label:TOURDE_FLEX_FIELD, value:value}));
		}
		
		private static var _isUsefulLinks:Boolean = true;
		
		public static function get isUsefulLinks():Boolean
		{
			return _isUsefulLinks;
		}
		public static function set isUsefulLinks(value:Boolean):void
		{
			_isUsefulLinks = value;
			dispatcher.dispatchEvent(new GeneralEvent(SAVE_LAYOUT_CHANGE_EVENT, {label:USEFULLINKS_FIELD, value:value}));
		}
		
		private static var _isProblemsWindow:Boolean = true;
		
		public static function get isProblemsWindow():Boolean
		{
			return _isProblemsWindow;
		}
		public static function set isProblemsWindow(value:Boolean):void
		{
			_isProblemsWindow = value;
			dispatcher.dispatchEvent(new GeneralEvent(SAVE_LAYOUT_CHANGE_EVENT, {label:PROBLEMS_VIEW_FIELD, value:value}));
		}
		
		private static var _isDebugWindow:Boolean = true;
		
		public static function get isDebugWindow():Boolean
		{
			return _isDebugWindow;
		}
		public static function set isDebugWindow(value:Boolean):void
		{
			_isDebugWindow = value;
			dispatcher.dispatchEvent(new GeneralEvent(SAVE_LAYOUT_CHANGE_EVENT, {label:DEBUG_FIELD, value:value}));
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