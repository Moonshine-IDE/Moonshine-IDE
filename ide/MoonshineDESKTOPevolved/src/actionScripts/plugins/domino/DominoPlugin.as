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
	import actionScripts.events.DominoEvent;

	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;

	import flash.events.Event;
	import flash.events.NativeProcessExitEvent;
	import flash.filesystem.File;
	
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	
	import spark.components.Alert;
	
	import actionScripts.events.SettingsEvent;
	import actionScripts.events.StatusBarEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.actionscript.as3project.settings.SimpleInformationOnlySetting;
	import actionScripts.plugin.ondiskproj.exporter.OnDiskMavenSettingsExporter;
	import actionScripts.plugin.settings.ISettingsProvider;
	import actionScripts.plugin.settings.vo.AbstractSetting;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.plugins.build.ConsoleBuildPluginBase;
	import actionScripts.plugins.domino.settings.UpdateSitePathSetting;
	import actionScripts.utils.FileUtils;
	import actionScripts.utils.HelperUtils;
	import actionScripts.utils.PathSetupHelperUtil;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ComponentTypes;
	import actionScripts.valueObjects.ComponentVO;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.HelperConstants;
	
	import components.containers.DominoSettingsInstruction;
	import components.popup.NotesMacPermissionPopup;
	
	public class DominoPlugin extends ConsoleBuildPluginBase implements ISettingsProvider
	{
		public static var RELAY_MAC_NOTES_PERMISSION_REQUEST:String = "onMacNotesPermissionRequest";
		public static var NAMESPACE:String = "actionScripts.plugins.domino::DominoPlugin";
		
		private static const TEMP_UPDATE_SITE_DOWNLOAD_PATH:File = File.applicationStorageDirectory.resolvePath("dominoUpdateSiteGeneration");
		
		override public function get name():String			{ return "Domino and Notes Client"; }
		override public function get author():String		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL + " Project Team.<br/>Based on <a href='https://github.com/OpenNTF/org.openntf.nsfodp'>NSF ODP Tooling</a> by Jesse Gallagher and the OpenNTF team."; }
		override public function get description():String	{ return "HCL® Notes / Domino Integration"; }

		private static const UPDATE_SITE_GENERATION:String = "update-site-generation";
		private static const NSD_KILL:String = "nsd-kill";
		
		private var pathSetting:PathSetting;
		private var updateSitePathSetting:UpdateSitePathSetting;
		private var notesMacPermissionPop:NotesMacPermissionPopup;
		private var targetUpdateSitePath:File;
		private var lastExecutionType:String;

		private var _macNDSDefaultLookupPath:String;
		public function get macNDSDefaultLookupPath():String
		{
			return _macNDSDefaultLookupPath;
		}
		public function set macNDSDefaultLookupPath(value:String):void
		{
			_macNDSDefaultLookupPath = value;
		}

		private var _updateSitePath:String;
		public function get updateSitePath():String
		{
			return _updateSitePath;
		}
		public function set updateSitePath(value:String):void
		{
			_updateSitePath = value;
		}

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
			dispatcher.addEventListener(SettingsEvent.EVENT_SETTINGS_SAVED, onSettingsSaved, false, 0, true);
			dispatcher.addEventListener(DominoEvent.NDS_KILL, onNDSKillRequest, false, 0, true);
			
			if (ConstantsCoreVO.IS_MACOS)
			{
				targetUpdateSitePath = FileUtils.getUserDownloadsDirectory().resolvePath(HelperConstants.DEFAULT_SDK_FOLDER_NAME +"/Domino/UpdateSite");
			}
			else
			{
				var tmpRootDirectories:Array = File.getRootDirectories();
				targetUpdateSitePath = (tmpRootDirectories.length > 0) ? 
					tmpRootDirectories[0].resolvePath(HelperConstants.DEFAULT_SDK_FOLDER_NAME +"/Domino/UpdateSite") : 
					File.userDirectory.resolvePath(HelperConstants.DEFAULT_SDK_FOLDER_NAME +"/Domino/UpdateSite");
			}

			// default lookup path for nsd between mac versions
			if (UtilsCore.isNotesDominoAvailable())
			{
				var lookupPaths:Array = [
					"/Contents/MacOS/Support/nsd.sh",
					"/Contents/Resources/Support/nsd.sh",
					File.separator + "nsd.exe"
				];
				for each (var nsdPath:String in lookupPaths)
				{
					if (FileUtils.isPathExists(model.notesPath + nsdPath))
					{
						macNDSDefaultLookupPath = model.notesPath + nsdPath;
						break;
					}
				}
			}
			
			OnDiskMavenSettingsExporter.mavenSettingsPath = new FileLocation(targetUpdateSitePath.parent.resolvePath("settings.xml").nativePath);
		}
		
		override public function deactivate():void
		{
			super.deactivate();
			
			dispatcher.removeEventListener(RELAY_MAC_NOTES_PERMISSION_REQUEST, onMacNotesAccessRequest);
			dispatcher.removeEventListener(SettingsEvent.EVENT_SETTINGS_SAVED, onSettingsSaved);
			dispatcher.removeEventListener(DominoEvent.NDS_KILL, onNDSKillRequest);
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
			if (updateSitePathSetting)
			{
				updateSitePathSetting.removeEventListener(UpdateSitePathSetting.EVENT_GENRATE_SITE, onGenerateSiteRequest);
				updateSitePathSetting = null;
			}
		}
		
        public function getSettingsList():Vector.<ISetting>
        {
			onSettingsClose();
			
			// check if all dependencies for 'update site > generate'
			// functionality, are present
			var updateSiteMessage:String;
			if (ConstantsCoreVO.IS_MACOS && 
				(!UtilsCore.isGitPresent() || !UtilsCore.isMavenAvailable() || !notesPath))
			{
				updateSiteMessage = "Automatic generation requires Git, Maven and Notes to be configured.";
			}

			pathSetting = new PathSetting(this, 'notesPath', 'HCL Notes Installation', ConstantsCoreVO.IS_MACOS ? false : true, notesPath);
			updateSitePathSetting = new UpdateSitePathSetting(this, 'updateSitePath', 'Update Site', true, updateSitePath);
			updateSitePathSetting.addEventListener(UpdateSitePathSetting.EVENT_GENRATE_SITE, onGenerateSiteRequest, false, 0, true);
			if (updateSiteMessage)
			{
				updateSitePathSetting.isGenerateButton = false;
				updateSitePathSetting.setMessage(updateSiteMessage, AbstractSetting.MESSAGE_IMPORTANT);
			}
			
			var instructions:SimpleInformationOnlySetting = new SimpleInformationOnlySetting();
			instructions.renderer = new DominoSettingsInstruction();
			
			return Vector.<ISetting>([
                pathSetting,
				updateSitePathSetting,
				new PathSetting(this, 'macNDSDefaultLookupPath', 'NSD Executable', false, macNDSDefaultLookupPath),
				instructions
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
			var component:ComponentVO = HelperUtils.getComponentByType(ComponentTypes.TYPE_NOTES);
			
			var isValidPath:Boolean = HelperUtils.isValidSDKDirectoryBy(component.type, notesMacPermissionPop.installLocationPath, component.pathValidation);
			if (!isValidPath)
			{
				component.hasWarning = "Feature available. Click on Configure to allow";
				Alert.show("Provide Notes.app path only. Validation error.", "Error!");
			}
			else if (!isDiscarded) 
			{
				Alert.show("Permission accepted. You can now use Notes Domino functionalities.", "Success!");
				
				// save the path
				model.notesPath = notesMacPermissionPop.installLocationPath;
				component.hasWarning = null;
				PathSetupHelperUtil.updateNotesPath(notesMacPermissionPop.installLocationPath, true);
			}
			
			notesMacPermissionPop.removeEventListener(Event.CLOSE, onNotesPermissionClosed);
			FlexGlobals.topLevelApplication.removeElement(notesMacPermissionPop);
			notesMacPermissionPop = null;
		}
		
		private function onGenerateSiteRequest(event:Event):void
		{
			var originalAlertYesSize:Number = Alert.buttonWidth;
			Alert.buttonWidth = originalAlertYesSize * 1.5;
			Alert.YES_LABEL = "Generate";
			
			Alert.show("Generate a new update site based on your local HCL Notes installation. This may take a couple minutes.", 
				"Generate Update Site", 
				Alert.YES|Alert.CANCEL, 
				null, 
				confirmHandler);
			
			/*
			 * @local
			 */
			function confirmHandler(e:CloseEvent):void
			{
				if (e.detail == Alert.YES) 
				{
					preStartUpdateSiteGeneration();
				}
				
				Alert.buttonWidth = originalAlertYesSize;
				Alert.YES_LABEL = "YES";
			}
		}
		
		private function preStartUpdateSiteGeneration():void
		{
			// pre-check if the default update-site directory
			// already exists and terminate
			if (targetUpdateSitePath.exists)
			{
				Alert.show("You have already generated an update site to '"+ targetUpdateSitePath.nativePath +"'. Please delete or rename this directory and try again.",
					"Error!"
					);
				return;
			}
			
			if (TEMP_UPDATE_SITE_DOWNLOAD_PATH.exists)
			{
				FileUtils.deleteDirectoryAsync(
					TEMP_UPDATE_SITE_DOWNLOAD_PATH,
					onReadyToRunGeneration,
					onTempUpdateFolderDeleteError
					);
			}
			else
			{
				onReadyToRunGeneration();
			}
			
			/*
			 * @local
			 */
			function onReadyToRunGeneration():void
			{
				updateSitePathSetting.editable = false;
				startUpdateSiteGeneration();
			}
			function onTempUpdateFolderDeleteError(message:String):void
			{
				Alert.show(message, "Error!");
			}
		}
		
		private function startUpdateSiteGeneration():void
		{
			var gitPath:String = (ConstantsCoreVO.IS_MACOS && ConstantsCoreVO.IS_APP_STORE_VERSION) ? 
				model.gitPath : "git";
			var mavenPath:String = (ConstantsCoreVO.IS_MACOS && ConstantsCoreVO.IS_APP_STORE_VERSION) ? 
				model.mavenPath +"/bin/mvn" : "mvn";
			
			var commandA:String = "mkdir '"+ TEMP_UPDATE_SITE_DOWNLOAD_PATH.nativePath +"'";
			var commandB:String = "cd '"+ TEMP_UPDATE_SITE_DOWNLOAD_PATH.nativePath +"'";
			var commandC:String = gitPath +" clone --progress -v https://github.com/OpenNTF/generate-domino-update-site .";
			var commandD:String = "cd generate-domino-update-site";
			var commandE:String = mavenPath +" install";
			var commandF:String = mavenPath +" org.openntf.p2:generate-domino-update-site:generateUpdateSite -Dsrc=\""+ notesPath +"/Contents/MacOS\" -Ddest=\""+ targetUpdateSitePath.nativePath +"\"";
			
			var fullCommand:String = [commandA, commandB, commandC, commandD, commandE, commandF].join(" && ");
			print("%s", fullCommand);

			lastExecutionType = UPDATE_SITE_GENERATION;
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, "Generating Update Site..", null, false));
			this.start(
				new <String>[fullCommand], 
				File.applicationStorageDirectory
			);
		}
		
		override protected function onNativeProcessExit(event:NativeProcessExitEvent):void
		{
			super.onNativeProcessExit(event);
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
			if (updateSitePathSetting)
				updateSitePathSetting.editable = true;
			
			// set as default Update site
			if ((lastExecutionType == UPDATE_SITE_GENERATION) &&
					targetUpdateSitePath.exists)
			{
				updateSitePath = targetUpdateSitePath.nativePath;
				if (updateSitePathSetting) updateSitePathSetting.path = updateSitePath;
				generateDominoMavenSettingsFile();
			}
		}
		
		private function onSettingsSaved(event:SettingsEvent):void
		{
			generateDominoMavenSettingsFile();
		}
		
		private function generateDominoMavenSettingsFile():void
		{
			if (updateSitePath && FileUtils.isPathExists(updateSitePath))
			{
				OnDiskMavenSettingsExporter.exportOnDiskMavenSettings(updateSitePath);
			}
		}

		private function onNDSKillRequest(event:Event):void
		{
			if (!UtilsCore.isNotesDominoAvailable() || !macNDSDefaultLookupPath)
			{
				dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, NAMESPACE));
				error("Error: Could not find 'nsd' executable in HCL Notes Installation. This can be configured in Moonshine > Settings > Domino and Notes Client.");
				return;
			}

			var originalAlertYesSize:Number = Alert.buttonWidth;
			Alert.buttonWidth = originalAlertYesSize * 3;
			Alert.YES_LABEL = "Proceed to run NSD Kill";
			Alert.show(
					"This will attempt to immediately terminate your HCL Notes Client and all related processes and shared memory segments. You should first close any remaining tabs and windows that are open if you still have access to the GUI. Do you wish to proceed with this action?",
					"Confirm!", Alert.YES|Alert.CANCEL, null, onNSDKillConfirmed);

			/*
			 * @local
			 */
			function onNSDKillConfirmed(event:CloseEvent):void
			{
				if (event.detail == Alert.YES)
				{
					lastExecutionType = NSD_KILL;
					dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, "Trying to kill NSD..", null, false));
					if (ConstantsCoreVO.IS_MACOS)
					{
						print("%s", "Executing NSD kill process on Terminal window.");
						startOSAScript();
					}
					else
					{
						var command:String = "\""+ macNDSDefaultLookupPath +"\" -batch -kill";
						print("%s", command);
						this.start(
								new <String>[command],
								null
						);
					}
				}

				Alert.buttonWidth = originalAlertYesSize;
				Alert.YES_LABEL = "YES";
			}
		}

		private function startOSAScript():void
		{
			if (nativeProcess.running && running)
			{
				warning("Build is running. Wait for finish...");
				return;
			}

			nativeProcess = new NativeProcess();
			nativeProcessStartupInfo = new NativeProcessStartupInfo();
			nativeProcessStartupInfo.executable = File.documentsDirectory.resolvePath("/usr/bin/osascript");

			var command:String = "tell application \"Terminal\" to activate do script \"\\\""+ macNDSDefaultLookupPath +"\\\" -kill\"";
			nativeProcessStartupInfo.arguments = Vector.<String>(["-e", command]);
			addNativeProcessEventListeners();
			nativeProcess.start(nativeProcessStartupInfo);
			running = true;
		}
	}
}