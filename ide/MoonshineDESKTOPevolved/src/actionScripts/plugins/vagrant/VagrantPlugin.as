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
package actionScripts.plugins.vagrant
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.NativeProcessExitEvent;
	import flash.filesystem.File;
	
	import mx.collections.ArrayCollection;
	import mx.events.CloseEvent;
	
	import spark.components.Alert;
	
	import actionScripts.events.FilePluginEvent;
	import actionScripts.events.SettingsEvent;
	import actionScripts.events.StatusBarEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.console.ConsoleOutputEvent;
	import actionScripts.plugin.settings.ISettingsProvider;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.plugins.build.ConsoleBuildPluginBase;
	import actionScripts.plugins.externalEditors.importer.ExternalEditorsImporter;
	import actionScripts.plugins.externalEditors.utils.ExternalEditorsSharedObjectUtil;
	import actionScripts.plugins.vagrant.utils.VagrantUtil;
	import actionScripts.ui.renderers.FTETreeItemRenderer;
	import actionScripts.utils.FileUtils;
	import actionScripts.utils.MethodDescriptor;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ConstantsCoreVO;

	public class VagrantPlugin extends ConsoleBuildPluginBase implements ISettingsProvider
	{
		public static var NAMESPACE:String = "actionScripts.plugins.vagrant::VagrantPlugin";

		override public function get name():String			{ return "Vagrant"; }
		override public function get author():String		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL + " Project Team"; }
		override public function get description():String	{ return "Access to Vagrant support from Moonshine-IDE"; }
		
		private var pathSetting:PathSetting;
		private var defaultVagrantPath:String;
		private var defaultVirtualBoxPath:String;
		private var vagrantConsole:VagrantConsolePlugin;
		private var haltMethod:MethodDescriptor;
		private var destroyMethod:MethodDescriptor;
		private var vagrantFileLocation:FileLocation;

		public function get vagrantPath():String
		{
			return model ? model.vagrantPath : null;
		}
		public function set vagrantPath(value:String):void
		{
			if (model.vagrantPath != value)
			{
				model.vagrantPath = value;
			}
		}

		public function get virtualBoxPath():String
		{
			return model ? model.virtualBoxPath : null;
		}
		public function set virtualBoxPath(value:String):void
		{
			if (model.virtualBoxPath != value)
			{
				model.virtualBoxPath = value;
			}
		}

		override public function activate():void
		{
			super.activate();
			updateEventListeners();

			if (!ConstantsCoreVO.IS_MACOS || !ConstantsCoreVO.IS_APP_STORE_VERSION)
			{
				// because most users install Vagrant to a standard installation
				// directory, we can try to use it as the default, if it exists.
				// if the user saves a different path (or clears the path) in
				// the settings, these default values will be safely ignored.
				// --vagrant--
				var defaultLocation:File = new File(ConstantsCoreVO.IS_MACOS ? "/usr/local/bin" : "C:\\HashiCorp\\Vagrant");
				defaultVagrantPath = defaultLocation.exists ? defaultLocation.nativePath : null;
				if (defaultVagrantPath && !model.vagrantPath)
				{
					model.vagrantPath = defaultVagrantPath;
				}
				// --virtualBox--
				defaultLocation = new File(ConstantsCoreVO.IS_MACOS ? "/usr/local/bin" : FileUtils.getValidOrPossibleWindowsInstallation("Oracle/VirtualBox"));
				defaultVirtualBoxPath = defaultLocation.exists ? defaultLocation.nativePath : null;
				if (defaultVirtualBoxPath && !model.virtualBoxPath)
				{
					model.virtualBoxPath = defaultVirtualBoxPath;
				}
			}
		}
		
		override public function deactivate():void
		{
			super.deactivate();
			removeMenuListeners();
			onConsoleDeactivated(null);
		}

		override public function resetSettings():void
		{
			vagrantPath = null;
		}
		
		override public function onSettingsClose():void
		{
			if (pathSetting)
			{
				pathSetting = null;
			}
		}

		override protected function outputMsg(msg:*):void
		{
			dispatcher.dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_OUTPUT_VAGRANT, msg));
		}
		
        public function getSettingsList():Vector.<ISetting>
        {
			onSettingsClose();
			pathSetting = new PathSetting(this, 'vagrantPath', 'Vagrant Home', true, vagrantPath, false, false, defaultVagrantPath);

			return Vector.<ISetting>([
				pathSetting,
				new PathSetting(this, 'virtualBoxPath', 'VirtualBox Home (Optional)', true, virtualBoxPath, false, false, defaultVirtualBoxPath)
			]);
        }

		private function updateEventListeners():void
		{
			var eventName:String;
			for each (var option:String in VagrantUtil.VAGRANT_MENU_OPTIONS)
			{
				eventName = "eventVagrant"+ option;
				dispatcher.addEventListener(eventName, onVagrantOptionSelect, false, 0, true);
			}

			dispatcher.addEventListener(FTETreeItemRenderer.CONFIGURE_VAGRANT, onConfigureVagrant, false, 0, true);
		}

		private function removeMenuListeners():void
		{
			var eventName:String;
			for each (var option:String in VagrantUtil.VAGRANT_MENU_OPTIONS)
			{
				eventName = "eventVagrant"+ option;
				dispatcher.removeEventListener(eventName, onVagrantOptionSelect);
			}

			dispatcher.removeEventListener(FTETreeItemRenderer.CONFIGURE_VAGRANT, onConfigureVagrant);
		}

		private function onConfigureVagrant(event:Event):void
		{
			dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, NAMESPACE));
		}

		private function onVagrantOptionSelect(event:FilePluginEvent):void
		{
			startVagrantConsole();

			var optionSelected:String = event.type.replace("eventVagrant", "");
			switch (optionSelected)
			{
				case VagrantUtil.VAGRANT_UP:
					vagrantUp(event.file);
					break;
				case VagrantUtil.VAGRANT_HALT:
					vagrantHalt(event.file);
					break;
				case VagrantUtil.VAGRANT_RELOAD:
					vagrantReload(event.file);
					break;
				case VagrantUtil.VAGRANT_SSH:
					vagrantSSH(event.file);
					break;
				case VagrantUtil.VAGRANT_DESTROY:
					vagrantDestroyConfirm(event.file);
					break;
			}
		}

		private function startVagrantConsole():void
		{
			if (!vagrantConsole)
			{
				vagrantConsole = new VagrantConsolePlugin();
				vagrantConsole.addEventListener(VagrantConsolePlugin.EVENT_PLUGIN_DEACTIVATED, onConsoleDeactivated, false, 0, true);
			}
			else
			{
				vagrantConsole.show();
			}
		}

		private function onConsoleDeactivated(event:Event):void
		{
			if (vagrantConsole)
			{
				vagrantConsole.removeEventListener(VagrantConsolePlugin.EVENT_PLUGIN_DEACTIVATED, onConsoleDeactivated);
				vagrantConsole = null;
			}
		}

		private function vagrantUp(file:FileLocation):void
		{
			if (running)
			{
				Alert.show("A Vagrant process is already running. Halt the running process before starting new.", "Error!");
				return;
			}

			var binPath:String = UtilsCore.getVagrantBinPath();
			var command:String;
			if (ConstantsCoreVO.IS_MACOS)
			{
				command = '"'+ binPath +'" up 2>&1 | tee vagrant_up.log';
			}
			else
			{
				var powerShellPath:String = UtilsCore.getPowerShellExecutablePath();
				if (powerShellPath)
				{
					command = '"'+ powerShellPath +'" "'+ binPath +' up 2>&1 | tee vagrant_up.log"';	
				}
				else
				{
					error("Failed to locate PowerShell during execution.");
					return;
				}
			}
			
			warning("%s", command);
			success("Log file location: "+ file.fileBridge.parent.fileBridge.nativePath + file.fileBridge.separator +"vagrant_up.log");
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, "Vagrant Up", "Running "));
			dispatcher.addEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onTerminateRunningVagrant, false, 0, true);
			
			this.start(
				new <String>[command], file.fileBridge.parent
			);
		}

		public function vagrantHalt(file:FileLocation):void
		{
			if (running)
			{
				dispatcher.removeEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onTerminateRunningVagrant);

				stop(true);
				haltMethod = new MethodDescriptor(this, "vagrantHalt", file);
				return;
			}

			var command:String = '"'+ UtilsCore.getVagrantBinPath() +'" halt';
			warning("%s", command);
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, "Vagrant Halt", "Running ", false));

			this.start(
					new <String>[command], file.fileBridge.parent
			);
		}

		public function vagrantReload(file:FileLocation):void
		{
			if (running)
			{
				stop(true);
				haltMethod = new MethodDescriptor(this, "vagrantReload", file);
				return;
			}

			var binPath:String = UtilsCore.getVagrantBinPath();
			var command:String;
			if (ConstantsCoreVO.IS_MACOS)
			{
				command = '"'+ binPath +'" reload 2>&1 | tee vagrant_reload.log';
			}
			else
			{
				var powerShellPath:String = UtilsCore.getPowerShellExecutablePath();
				if (powerShellPath)
				{
					command = '"'+ powerShellPath +'" "'+ binPath +' reload 2>&1 | tee vagrant_reload.log"';	
				}
				else
				{
					error("Failed to locate PowerShell during execution.");
					return;
				}
			}

			warning("%s", command);
			success("Log file location: "+ file.fileBridge.parent.fileBridge.nativePath + file.fileBridge.separator +"vagrant_reload.log");
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, "Vagrant Reload", "Running "));
			dispatcher.addEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onTerminateRunningVagrant, false, 0, true);

			this.start(
					new <String>[command], file.fileBridge.parent
			);
		}

		private function onTerminateRunningVagrant(event:StatusBarEvent):void
		{
			if (running)
			{
				dispatcher.removeEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onTerminateRunningVagrant);
				stop(true);
			}
		}

		private function vagrantSSH(file:FileLocation):void
		{
			if (ConstantsCoreVO.IS_MACOS)
			{
				VagrantUtil.runVagrantSSHAt(file.fileBridge.parent.fileBridge.nativePath);
			}
			else
			{
				this.start(
					new <String>['start cmd /k cd "'+ file.fileBridge.parent.fileBridge.nativePath +'"&&cls&&"'+ UtilsCore.getVagrantBinPath() +'" ssh'],
					file.fileBridge.parent
				);
			}
		}

		public function vagrantDestroy(file:FileLocation):void
		{
			var command:String = '"'+ UtilsCore.getVagrantBinPath() +'" destroy -f';
			warning("%s", command);
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, "Vagrant Destroy", "Running ", true));
			dispatcher.addEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onTerminateRunningVagrant, false, 0, true);

			this.start(
					new <String>[command], file.fileBridge.parent
			);
		}

		private function vagrantDestroyConfirm(file:FileLocation):void
		{
			vagrantFileLocation = file;
			Alert.show(
					"Are you sure you want to destroy the Vagrant instance for:\n\n"+ file.fileBridge.parent.fileBridge.nativePath +"\n\n" +
					"The virtual machine will be permanently destroyed, and will need to be recreated for future tests.\n\nThe Vagrant template will *not* be removed.",
					"Warning!",
					Alert.YES | Alert.CANCEL,
					null,
					onDestroyConfirm, null, Alert.CANCEL
			);
		}
		
		private function onDestroyConfirm(eventObj:CloseEvent):void
		{
			// Check to see if the OK button was pressed.
			if (eventObj.detail == Alert.YES)
			{
				if (running)
				{
					stop(true);
					haltMethod = new MethodDescriptor(this, "vagrantHalt", vagrantFileLocation);
					destroyMethod = new MethodDescriptor(this, "vagrantDestroy", vagrantFileLocation);
				}
				else
				{
					vagrantHalt(vagrantFileLocation);
					destroyMethod = new MethodDescriptor(this, "vagrantDestroy", vagrantFileLocation);
				}
			}
		}

		override protected function onNativeProcessExit(event:NativeProcessExitEvent):void
		{
			super.onNativeProcessExit(event);
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));

			// run any queued process
			if (haltMethod)
			{
				haltMethod.callMethod();
				haltMethod = null;
				return;
			}
			if (destroyMethod)
			{
				destroyMethod.callMethod();
				destroyMethod = null;
			}

			vagrantFileLocation = null;
		}
	}
}