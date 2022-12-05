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
package actionScripts.plugins.browser
{
	import flash.events.Event;
	import flash.net.SharedObject;
	
	import mx.collections.ArrayCollection;
	
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
		override public function get author():String		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String	{ return "Browser Preference Plugin."; }
		
		private static const TYPE_INTERNAL:String = "typeInternal";
		private static const TYPE_EXTERNAL:String = "typeExternal";
		
		public var browserPath:String = "System Default";
		
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
			externalBrowserSettings.editable = (value == TYPE_EXTERNAL);
		}
		
		private var isInternalBrowser:Boolean;
		
		override public function activate():void
		{
			super.activate();
			
			/*dispatcher.addEventListener(SaveFileEvent.FILE_SAVED, handleFileSave);
			dispatcher.addEventListener(ProjectEvent.ADD_PROJECT, handleProjectOpen);
			dispatcher.addEventListener(CHECKOUT_REQUEST, handleCheckoutRequest);*/
		}
		
		override public function deactivate():void
		{
			super.deactivate();
			
			/*dispatcher.removeEventListener(SaveFileEvent.FILE_SAVED, handleFileSave);
			dispatcher.removeEventListener(ProjectEvent.ADD_PROJECT, handleProjectOpen);
			dispatcher.removeEventListener(CHECKOUT_REQUEST, handleCheckoutRequest);*/
		}
		
		override public function resetSettings():void
		{
		}
		
		public function getSettingsList():Vector.<ISetting>
		{
			browserList = new ArrayCollection();
			browserList.addItemAt("System Default", 0);
			cookie = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_LOCAL);
			if (cookie.data.hasOwnProperty('externalBrowsersPaths'))
			{
				browserList.source.concat(cookie.data.externalBrowsersPaths);
			}
			
			var nvps:Vector.<NameValuePair> = Vector.<NameValuePair>([
				new NameValuePair("Internal", TYPE_INTERNAL),
				new NameValuePair("External", TYPE_EXTERNAL)
			]);
			var typeSettings:MultiOptionSetting = new MultiOptionSetting(this, "activeType", "Choose Browsing Type", nvps);
			typeSettings.isCommitOnChange = true;
			
			externalBrowserSettings = new PathSetting(this, 'browserPath', 'Select or Decleare an External Browser', false, null, false, true);
			externalBrowserSettings.dropdownListItems = browserList;
			externalBrowserSettings.editable = false;
			externalBrowserSettings.addEventListener(AbstractSetting.PATH_SELECTED, onExternalPathChanged, false, 0, true);
			
			return Vector.<ISetting>([
				typeSettings,
				externalBrowserSettings
			]);
		}
		
		private function listenToSettingsSave():void
		{
			for each (var tab:IContentWindow in model.editors)
			{
				if (tab is SettingsView)
				{
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
		
		private function save():void
		{
			if (browserList.length > 1)
			{
				browserList.removeItemAt(0);
				cookie.data["externalBrowsersPaths"] = browserList.source;
				cookie.flush();
			}
		}
	}
}