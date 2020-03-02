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
package actionScripts.plugins.domino
{
	import flash.events.Event;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	
	import actionScripts.events.SettingsEvent;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.settings.ISettingsProvider;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.ui.menu.MenuPlugin;
	import actionScripts.utils.HelperUtils;
	import actionScripts.utils.PathSetupHelperUtil;
	import actionScripts.valueObjects.ComponentTypes;
	import actionScripts.valueObjects.ComponentVO;
	import actionScripts.valueObjects.ConstantsCoreVO;
	
	import components.popup.NotesMacPermissionPopup;
	
	public class DominoPlugin extends PluginBase implements ISettingsProvider
	{
		public static var RELAY_MAC_NOTES_PERMISSION_REQUEST:String = "onMacNotesPermissionRequest";
		public static var NAMESPACE:String = "actionScripts.plugins.domino::DominoPlugin";
		
		override public function get name():String			{ return "Notes Domino"; }
		override public function get author():String		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL + " Project Team"; }
		override public function get description():String	{ return "Domino Plugin"; }
		
		private var pathSetting:PathSetting;
		private var notesMacPermissionPop:NotesMacPermissionPopup;

        public function get notesPath():String
        {
            return model ? model.notesPath : null;
        }
        public function set notesPath(value:String):void
        {
            if (model.notesPath != value)
            {
                model.notesPath = value;
            }
        }
		
		override public function activate():void
		{
			super.activate();
			
			dispatcher.addEventListener(RELAY_MAC_NOTES_PERMISSION_REQUEST, onMacNotesAccessRequest, false, 0, true);
		}
		
		override public function deactivate():void
		{
			super.deactivate();
			
			dispatcher.removeEventListener(RELAY_MAC_NOTES_PERMISSION_REQUEST, onMacNotesAccessRequest);
		}

		override public function resetSettings():void
		{
			notesPath = null;
		}
		
		override public function onSettingsClose():void
		{
			if (pathSetting)
			{
				pathSetting = null;
			}
		}
		
        public function getSettingsList():Vector.<ISetting>
        {
			onSettingsClose();

			pathSetting = new PathSetting(this, 'notesPath', 'IBM/HCL Notes Executable', ConstantsCoreVO.IS_MACOS ? false : true, notesPath);
			
			return Vector.<ISetting>([
                pathSetting
			]);
        }
		
		private function onMacNotesAccessRequest(event:Event):void
		{
			// if calls during startup 
			// do not open the prompt
			var component:ComponentVO = HelperUtils.getComponentByType(ComponentTypes.TYPE_NOTES);
			if (!notesMacPermissionPop && component.installToPath && !model.notesPath)
			{
				component.hasWarning = null;
				notesMacPermissionPop = new NotesMacPermissionPopup;
				notesMacPermissionPop.installLocationPath = component.installToPath;
				notesMacPermissionPop.horizontalCenter = notesMacPermissionPop.verticalCenter = 0;
				notesMacPermissionPop.addEventListener(Event.CLOSE, onNotesPermissionClosed, false, 0, true);
				FlexGlobals.topLevelApplication.addElement(notesMacPermissionPop);
			}
			else
			{
				dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, NAMESPACE));
			}
		}
		
		private function onNotesPermissionClosed(event:Event):void
		{
			var isDiscarded:Boolean = notesMacPermissionPop.isDiscarded;
			var isGranted:Boolean;
			var component:ComponentVO = HelperUtils.getComponentByType(ComponentTypes.TYPE_NOTES);
			
			var isValidPath:Boolean = HelperUtils.isValidSDKDirectoryBy(component.type, notesMacPermissionPop.installLocationPath, component.pathValidation);
			if (!isValidPath)
			{
				isGranted = false;
				component.hasWarning = "Feature available. Click on Configure to allow";
				Alert.show("Provide Notes.app path only. Validation error.", "Error!");
			}
			else if (!isDiscarded) 
			{
				isGranted = true;
				
				//dispatcher.dispatchEvent(new VersionControlEvent(VersionControlEvent.OSX_XCODE_PERMISSION_GIVEN, xCodePermissionWindow.xCodePath));
				Alert.show("Permission accepted. You can now use Notes Domino functionalities.", "Success!");
				
				// save the path
				model.notesPath = notesMacPermissionPop.installLocationPath;
				PathSetupHelperUtil.updateNotesPath(notesMacPermissionPop.installLocationPath, true);
			}
			else
			{
				isGranted = false;
			}
			
			if (ConstantsCoreVO.IS_GIT_OSX_AVAILABLE != isGranted)
			{
				ConstantsCoreVO.IS_SVN_OSX_AVAILABLE = ConstantsCoreVO.IS_GIT_OSX_AVAILABLE = isGranted;
				dispatcher.dispatchEvent(new Event(MenuPlugin.CHANGE_GIT_CLONE_PERMISSION_LABEL));
				dispatcher.dispatchEvent(new Event(MenuPlugin.CHANGE_SVN_CHECKOUT_PERMISSION_LABEL));
			}
			
			notesMacPermissionPop.removeEventListener(Event.CLOSE, onNotesPermissionClosed);
			FlexGlobals.topLevelApplication.removeElement(notesMacPermissionPop);
			notesMacPermissionPop = null;
		}
	}
}