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
package actionScripts.plugins.externalEditors
{	
	import com.adobe.utils.StringUtil;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.net.registerClassAlias;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	import mx.utils.ObjectUtil;
	
	import actionScripts.events.FilePluginEvent;
	import actionScripts.events.SettingsEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.settings.ISettingsProvider;
	import actionScripts.plugin.settings.event.LinkOnlySettingsEvent;
	import actionScripts.plugin.settings.vo.AbstractSetting;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.LinkOnlySetting;
	import actionScripts.plugin.settings.vo.LinkOnlySettingVO;
	import actionScripts.plugins.build.ConsoleBuildPluginBase;
	import actionScripts.plugins.domino.settings.UpdateSitePathSetting;
	import actionScripts.plugins.externalEditors.importer.ExternalEditorsImporter;
	import actionScripts.plugins.externalEditors.settings.ExternalEditorSetting;
	import actionScripts.plugins.externalEditors.utils.ExternalEditorsSharedObjectUtil;
	import actionScripts.plugins.externalEditors.vo.ExternalEditorVO;
	import actionScripts.ui.renderers.FTETreeItemRenderer;
	import actionScripts.utils.SharedObjectUpdaterWithNewUpdates;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ConstantsCoreVO;
	
	import components.popup.ExternalEditorAddEditPopup;
	
	public class ExternalEditorsPlugin extends ConsoleBuildPluginBase implements ISettingsProvider
	{
		public static var NAMESPACE:String = "actionScripts.plugins.externalEditors::ExternalEditorsPlugin";
		
		private static const ADD_EDITOR:String = "Add New";
		private static const RESET_ALL_EDITORS:String = "Reset to Default";
		
		[Bindable]
		public static var editors:ArrayCollection; 
		
		override public function get name():String			{ return "External Editors"; }
		override public function get author():String		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL + " Project Team"; }
		override public function get description():String	{ return "Accessing external editors from Moonshine-IDE"; }
		
		public var updateSitePath:String;
		
		private var updateSitePathSetting:UpdateSitePathSetting;
		private var editorsUntilSave:ArrayCollection;
		private var settings:Vector.<ISetting>;
		private var removedEditors:Array = [];
		private var addEditEditorWindow:ExternalEditorAddEditPopup;
		private var linkOnlySetting:LinkOnlySetting;
		private var needUpdateSyncDateUTC:String = "Fri Jun 12 07:30:56 2020 UTC";
		
		override public function activate():void
		{
			super.activate();
			
			generateEditorsList();
			
			dispatcher.addEventListener(SettingsEvent.EVENT_SETTINGS_SAVED, onSettingsSaved, false, 0, true);
		}
		
		override public function deactivate():void
		{
			super.deactivate();
			
			dispatcher.removeEventListener(SettingsEvent.EVENT_SETTINGS_SAVED, onSettingsSaved);
		}

		override public function resetSettings():void
		{
			ExternalEditorsSharedObjectUtil.resetExternalEditorsInSO();
			editors = ExternalEditorsImporter.getDefaultEditors();
		}
		
		override public function onSettingsClose():void
		{
			// remove all externaleditorsetting listeners
			if (settings)
			{
				for each (var setting:AbstractSetting in settings)
				{
					if (setting is ExternalEditorSetting)
					{
						setting.removeEventListener(ExternalEditorSetting.EVENT_MODIFY, onEditorModify);
						setting.removeEventListener(ExternalEditorSetting.EVENT_REMOVE, onEditorSettingRemove);
					}
				}
			}
			
			// remove all linkonlysetting listeners
			if (linkOnlySetting)
			{
				linkOnlySetting.removeEventListener(LinkOnlySettingsEvent.EVENT_LINK_CLICKED, onLinkItemClicked);
			}
			
			editorsUntilSave = null;
			settings = null;
			linkOnlySetting = null;
		}
		
        public function getSettingsList():Vector.<ISetting>
        {
			var editor:ExternalEditorVO;

			// we need a recheck to evaluate any recently updated
			// path in user's machine
			if (editors)
			{
				for each (editor in editors)
				{
					// this should update the isValid property
					editor.installPath = editor.installPath;
				}
				ExternalEditorsSharedObjectUtil.saveExternalEditorsInSO(editors);
			}

			// not to affect original collection 
			// unless a save 
			registerClassAlias("actionScripts.plugins.externalEditors.vo.ExternalEditorVO", ExternalEditorVO);
			registerClassAlias("flash.filesystem.File", File);
			editorsUntilSave = ObjectUtil.copy(editors) as ArrayCollection;
			if (editorsUntilSave) UtilsCore.sortCollection(editorsUntilSave, ["title"]);
			
			settings = new Vector.<ISetting>();
			linkOnlySetting = new LinkOnlySetting(new <LinkOnlySettingVO>[
				new LinkOnlySettingVO("Add New"),
				new LinkOnlySettingVO("Reset to Default")
			]);
			linkOnlySetting.addEventListener(LinkOnlySettingsEvent.EVENT_LINK_CLICKED, onLinkItemClicked, false, 0, true);
			
			settings.push(linkOnlySetting);
			for each (editor in editorsUntilSave)
			{
				settings.push(
					getEditorSetting(editor)
				);
			}
			
			return settings;
        }
		
		private function getEditorSetting(editor:ExternalEditorVO):ExternalEditorSetting
		{
			var tmpSetting:ExternalEditorSetting = new ExternalEditorSetting(editor);
			tmpSetting.addEventListener(ExternalEditorSetting.EVENT_MODIFY, onEditorModify, false, 0, true);
			tmpSetting.addEventListener(ExternalEditorSetting.EVENT_REMOVE, onEditorSettingRemove, false, 0, true);
			
			return tmpSetting;
		}
		
		private function generateEditorsList():void
		{
			editors = ExternalEditorsSharedObjectUtil.getExternalEditorsFromSO();
			if (!editors)
			{
				editors = ExternalEditorsImporter.getDefaultEditors();
			}
			else
			{
				//var newUpdateDate:Date = new Date(Date.parse(needUpdateSyncDateUTC));
				if (SharedObjectUpdaterWithNewUpdates.isValidForNewUpdate(ExternalEditorsImporter.lastUpdateDate))
				{
					editors = SharedObjectUpdaterWithNewUpdates.syncWithNewUpdates(editors, ExternalEditorsImporter.getDefaultEditors(), "localID") as ArrayCollection;
					ExternalEditorsSharedObjectUtil.saveExternalEditorsInSO(editors);
				}
			}
			
			updateEventListeners();
		}
		
		private function updateEventListeners():void
		{
			var eventName:String;
			for each (var editor:ExternalEditorVO in editors)
			{
				eventName = "eventOpenWithExternalEditor"+ editor.localID;
				dispatcher.addEventListener(eventName, onOpenWithExternalEditor, false, 0, true);
			}
			
			dispatcher.addEventListener(FTETreeItemRenderer.CONFIGURE_EXTERNAL_EDITORS, onOpenExternalEditorConfiguration, false, 0, true);
		}
		
		private function onSettingsSaved(event:SettingsEvent):void
		{
			// remove unnecessary listeners
			if (removedEditors.length > 0)
			{
				removedEditors.forEach(function(element:ExternalEditorVO, index:Number, arr:Array):void {
					dispatcher.removeEventListener("eventOpenWithExternalEditor"+ element.localID, onOpenWithExternalEditor);
				});
				
				removedEditors = [];
			}
			
			editors = editorsUntilSave;
			ExternalEditorsSharedObjectUtil.saveExternalEditorsInSO(editors);
		}
		
		private function onOpenWithExternalEditor(event:FilePluginEvent):void
		{
			var editorID:String = event.type.replace("eventOpenWithExternalEditor", "");
			var editor:ExternalEditorVO;
			editors.source.some(function(item:ExternalEditorVO, index:int, arr:Array):Boolean {
				if (item.localID == editorID)
				{
					editor = item;
					return true;
				}
				return false;
			});
			
			if (editor)
			{
				runExternalEditor(editor, event.file);
			}
		}
		
		private function onOpenExternalEditorConfiguration(event:Event):void
		{
			dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, NAMESPACE));
		}
		
		private function onEditorModify(event:Event):void
		{
			openEditorModifyPopup((event.target as ExternalEditorSetting).editor);
		}
		
		private function onLinkItemClicked(event:LinkOnlySettingsEvent):void
		{
			if (event.value.label == ADD_EDITOR)
			{
				openEditorModifyPopup();
			}
			else if (event.value.label == RESET_ALL_EDITORS)
			{
				onResetAll();
			}
		}
		
		private function onResetAll():void
		{
			var setting:ExternalEditorSetting;
			for (var i:int; i < settings.length; i++)
			{
				setting = settings[i] as ExternalEditorSetting;
				if (setting)
				{
					if (setting.editor.isMoonshineDefault)
					{
						setting.editor.installPath = new File(setting.editor.defaultInstallPath);
						setting.stringValue = setting.editor.installPath.nativePath;
					}
					else
					{
						removedEditors.push(setting.editor);
						settings.removeAt(i);
						i--;
					}
				}
			}
			
			dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_REFRESH_CURRENT_SETTINGS));
		}
		
		private function openEditorModifyPopup(editor:ExternalEditorVO=null):void
		{
			if (!addEditEditorWindow)
			{
				addEditEditorWindow = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, ExternalEditorAddEditPopup, true) as ExternalEditorAddEditPopup;
				addEditEditorWindow.editor = editor;
				addEditEditorWindow.editors = editorsUntilSave;
				addEditEditorWindow.addEventListener(CloseEvent.CLOSE, onEditorEditPopupClosed);
				addEditEditorWindow.addEventListener(ExternalEditorAddEditPopup.UPDATE_EDITOR, onUpdateExternalEditorObject);
				
				PopUpManager.centerPopUp(addEditEditorWindow);
			}
			else
			{
				PopUpManager.bringToFront(addEditEditorWindow);
			}	
		}
		
		protected function onUpdateExternalEditorObject(event:Event):void
		{
			var editor:ExternalEditorVO = addEditEditorWindow.editor;
			if (editorsUntilSave.getItemIndex(editor) == -1)
			{
				onEditorSettingAdd(editor);
			}
			else
			{
				onEditorSettingModified(editor);
			}
		}
		
		protected function onEditorEditPopupClosed(event:CloseEvent):void
		{
			addEditEditorWindow.removeEventListener(CloseEvent.CLOSE, onEditorEditPopupClosed);
			addEditEditorWindow.removeEventListener(ExternalEditorAddEditPopup.UPDATE_EDITOR, onUpdateExternalEditorObject);
			
			PopUpManager.removePopUp(addEditEditorWindow);
			addEditEditorWindow = null;
		}
		
		private function onEditorSettingRemove(event:Event):void
		{
			// store the editor references but
			// remove from the collection once Save
			// along with remove corresponding global listener
			removedEditors.push((event.target as ExternalEditorSetting).editor);
			
			editorsUntilSave.removeItem((event.target as ExternalEditorSetting).editor);
			settings.splice(settings.indexOf(event.target), 1);
			dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_REFRESH_CURRENT_SETTINGS));
		}
		
		private function onEditorSettingAdd(editor:ExternalEditorVO):void
		{
			editorsUntilSave.addItem(editor);
			UtilsCore.sortCollection(editorsUntilSave, ["title"]);
			
			var tmpSetting:ExternalEditorSetting = getEditorSetting(editor);
			settings.splice(editorsUntilSave.getItemIndex(editor)+2, 0, tmpSetting);
			
			var eventName:String = "eventOpenWithExternalEditor"+ editor.localID;
			dispatcher.addEventListener(eventName, onOpenWithExternalEditor, false, 0, true);
			
			// force redraw of setting list using existing renderer
			dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_REFRESH_CURRENT_SETTINGS));
		}
		
		private function onEditorSettingModified(editor:ExternalEditorVO):void
		{
			var oldTitleIndex:int;
			for (var i:int; i < settings.length; i++)
			{
				if ((settings[i] is ExternalEditorSetting) && (settings[i] as ExternalEditorSetting).editor == editor)
				{
					oldTitleIndex = i;
					break;
				}
			}
			
			var timeoutValue:uint = setTimeout(function():void
			{
				clearTimeout(timeoutValue);
				
				var newTitleIndex:int = editorsUntilSave.getItemIndex(editor);
				var tmpSetting:Object = settings.removeAt(oldTitleIndex);
				(tmpSetting as ExternalEditorSetting).editor = editor;
				(tmpSetting as ExternalEditorSetting).stringValue = editor.installPath.nativePath;
				settings.splice(newTitleIndex+2, 0, tmpSetting);
				
				dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_REFRESH_CURRENT_SETTINGS));
			}, 500);
			
		}
		
		private function runExternalEditor(editor:ExternalEditorVO, onPath:FileLocation):void
		{
			var command:String;
			var extraArguments:String = (editor.extraArguments && StringUtil.trim(editor.extraArguments).length != 0) ? editor.extraArguments : null;
			if (ConstantsCoreVO.IS_MACOS) 
			{
				if (editor.localID == "netbeans")
				{
					var executables:Array = editor.installPath.resolvePath("Contents/MacOS").getDirectoryListing();
					command = "'"+ executables[0].nativePath +"' '"+ onPath.fileBridge.nativePath +"'";
				}
				else
				{
					command = "open -a '"+ editor.installPath.nativePath +"' '"+ onPath.fileBridge.nativePath +"'";
				}
				if (extraArguments) command += " --args "+ extraArguments;
			}
			else
			{
				command = '"'+ editor.installPath.nativePath +'" "'+ onPath.fileBridge.nativePath +'"';
				if (extraArguments) command += " "+ extraArguments;
			}
			print("%s", command);
			
			this.start(
				new <String>[command], null
			);
		}
		
		override protected function set running(value:Boolean):void
		{
			super.running = value;
			
			/*
			 * NOTE:
			 * On Windows after triggering an application
			 * the NativeProcess never exits and prevent from
			 * opening any new file to the editor without 
			 * closing it first (unlike macOS).
			 * We need to manually close the NativeProcess
			 * top overcome this holding situation once
			 * NativeProcess once triggered
			 */
			if (!ConstantsCoreVO.IS_MACOS && value)
			{
				// a bit of interval before closing this
				// https://github.com/Moonshine-IDE/Moonshine-IDE/issues/707
				var timeoutValue:uint = setTimeout(function():void
				{
					stop();
					clearTimeout(timeoutValue);
				}, 1000);
			}
		}

		override protected function onNativeProcessStandardErrorData(event:ProgressEvent):void
		{
			stop();
		}
	}
}