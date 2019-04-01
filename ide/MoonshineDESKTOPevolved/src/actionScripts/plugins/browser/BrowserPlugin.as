////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
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
// Author: Prominic.NET, Inc.
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugins.browser
{
	import flash.events.Event;
	import flash.net.SharedObject;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.settings.ISettingsProvider;
	import actionScripts.plugin.settings.SettingsView;
	import actionScripts.plugin.settings.vo.AbstractSetting;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.MultiOptionSetting;
	import actionScripts.plugin.settings.vo.NameValuePair;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.ui.IContentWindow;
	import actionScripts.utils.SharedObjectConst;
	import actionScripts.valueObjects.ConstantsCoreVO;
	
	public class BrowserPlugin extends PluginBase implements ISettingsProvider
	{
		override public function get name():String			{ return "Browser"; }
		override public function get author():String		{ return "Moonshine Project Team"; }
		override public function get description():String	{ return "Browser Preference Plugin."; }
		
		private static const TYPE_INTERNAL:String = "typeInternal";
		private static const TYPE_EXTERNAL:String = "typeExternal";
		private static const DEFAULT_LABEL:String = "System Default";
		
		public var browserPath:String = DEFAULT_LABEL;
		
		private var externalBrowserSettings:PathSetting;
		private var browserList:ArrayCollection;
		private var cookie:SharedObject;
		
		private var _activeType:String = TYPE_INTERNAL;
		public function get activeType():String
		{
			return _activeType;
		}
		public function set activeType(value:String):void
		{
			_activeType = value;
			ConstantsCoreVO.IS_EXTERNAL_BROWSER = externalBrowserSettings.isEditable = (value == TYPE_EXTERNAL);
		}
		
		override public function activate():void
		{
			super.activate();
		}
		
		override public function deactivate():void
		{
			super.deactivate();
		}
		
		override public function resetSettings():void
		{
			ConstantsCoreVO.IS_EXTERNAL_BROWSER = false;
			ConstantsCoreVO.EXTERNAL_BROWSER_PATH = null;
		}
		
		public function getSettingsList():Vector.<ISetting>
		{
			browserList = new ArrayCollection();
			browserList.addItemAt("System Default", 0);
			cookie = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_LOCAL);
			if (cookie.data.hasOwnProperty('externalBrowsersPaths'))
			{
				browserList.addAll(new ArrayList(cookie.data.externalBrowsersPaths));
			}
			
			var nvps:Vector.<NameValuePair> = Vector.<NameValuePair>([
				new NameValuePair("Internal", TYPE_INTERNAL),
				new NameValuePair("External", TYPE_EXTERNAL)
			]);
			var typeSettings:MultiOptionSetting = new MultiOptionSetting(this, "activeType", "Choose Browsing Type", nvps);
			typeSettings.isCommitOnChange = true;
			
			externalBrowserSettings = new PathSetting(this, 'browserPath', 'Select or Decleare an External Browser', false, null, false, true);
			externalBrowserSettings.dropdownListItems = browserList;
			externalBrowserSettings.isEditable = (activeType != TYPE_INTERNAL);
			externalBrowserSettings.addEventListener(AbstractSetting.PATH_SELECTED, onExternalPathChanged, false, 0, true);
			
			var timeoutValue:uint = setTimeout(function():void
			{
				clearTimeout(timeoutValue);
				listenToSettingsSave();
			}, 1000);
			
			return Vector.<ISetting>([
				typeSettings,
				externalBrowserSettings
			]);
		}
		
		private function listenToSettingsSave():void
		{
			for each (var tab:IContentWindow in model.editors)
			{
				if ((tab is SettingsView) && (tab as SettingsView).label == "Settings")
				{
					tab.addEventListener(SettingsView.EVENT_SAVE, onSettingsSave);
					tab.addEventListener(SettingsView.EVENT_CLOSE, onSettingsClose);
				}
			}
		}
		
		private function onExternalPathChanged(event:Event, makeNull:Boolean=true):void
		{
			// add only if not exists
			if (browserList.getItemIndex(externalBrowserSettings.stringValue) == -1)
			{
				browserList.addItem(externalBrowserSettings.stringValue);
			}
		}
		
		private function onSettingsClose(event:Event):void
		{
			event.target.removeEventListener(SettingsView.EVENT_SAVE, onSettingsSave);
			event.target.removeEventListener(SettingsView.EVENT_CLOSE, onSettingsClose);
		}
		
		private function onSettingsSave(event:Event):void
		{
			onSettingsClose(event);
			ConstantsCoreVO.IS_EXTERNAL_BROWSER = (activeType == TYPE_EXTERNAL);
			ConstantsCoreVO.EXTERNAL_BROWSER_PATH = browserPath;
			if (browserList.length > 1)
			{
				browserList.removeItemAt(0);
				cookie.data["externalBrowsersPaths"] = browserList.source;
				cookie.flush();
			}
		}
	}
}