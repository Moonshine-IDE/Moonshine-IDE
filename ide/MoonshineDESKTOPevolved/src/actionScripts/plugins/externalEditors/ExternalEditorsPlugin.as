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
package actionScripts.plugins.externalEditors
{	
	import com.adobe.utils.StringUtil;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
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
		
		private static const EVENT_ADD_EDITOR:String = "addNewEditor";
		private static const EVENT_RESET_ALL_EDITORS:String = "resetAllEditors";
		
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
		private var needUpdateSyncDateUTC:String = "Thu Jun 11 05:58:26 2020 UTC";
		
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
				for each (var setting:AbstractSetting in setting)
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
				linkOnlySetting.removeEventListener(EVENT_ADD_EDITOR, onEditorAdd);
				linkOnlySetting.removeEventListener(EVENT_RESET_ALL_EDITORS, onResetAll);
			}
			
			editorsUntilSave = null;
			settings = null;
			linkOnlySetting = null;
		}
		
        public function getSettingsList():Vector.<ISetting>
        {
			// not to affect original collection 
			// unless a save 
			registerClassAlias("actionScripts.plugins.externalEditors.vo.ExternalEditorVO", ExternalEditorVO);
			registerClassAlias("flash.filesystem.File", File);
			editorsUntilSave = ObjectUtil.copy(editors) as ArrayCollection;
			if (editorsUntilSave) UtilsCore.sortCollection(editorsUntilSave, ["title"]);
			
			settings = new Vector.<ISetting>();
			linkOnlySetting = new LinkOnlySetting(new <LinkOnlySettingVO>[
				new LinkOnlySettingVO("Add New", EVENT_ADD_EDITOR),
				new LinkOnlySettingVO("Reset to Default", EVENT_RESET_ALL_EDITORS)
			]);
			linkOnlySetting.addEventListener(EVENT_ADD_EDITOR, onEditorAdd, false, 0, true);
			linkOnlySetting.addEventListener(EVENT_RESET_ALL_EDITORS, onResetAll, false, 0, true);
			
			settings.push(linkOnlySetting);
			for each (var editor:ExternalEditorVO in editorsUntilSave)
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
				var newUpdateDate:Date = new Date(Date.parse(needUpdateSyncDateUTC));
				if (SharedObjectUpdaterWithNewUpdates.isValidForNewUpdate(newUpdateDate))
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
		
		private function onEditorAdd(event:Event):void
		{
			openEditorModifyPopup();
		}
		
		private function onResetAll(event:Event):void
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
				command = "open -a '"+ editor.installPath.nativePath +"' '"+ onPath.fileBridge.nativePath +"'";
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
				this.stop();
			}
		}
	}
}