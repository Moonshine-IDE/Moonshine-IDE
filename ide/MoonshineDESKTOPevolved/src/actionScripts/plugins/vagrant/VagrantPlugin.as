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
	import actionScripts.events.FilePluginEvent;
	import actionScripts.events.StatusBarEvent;
	import actionScripts.plugin.console.ConsoleOutputEvent;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.plugins.vagrant.utils.VagrantUtil;
	import actionScripts.utils.MethodDescriptor;

	import flash.events.Event;

	import flash.events.NativeProcessExitEvent;

	import flash.filesystem.File;

	import mx.collections.ArrayCollection;

	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.settings.ISettingsProvider;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugins.build.ConsoleBuildPluginBase;
	import actionScripts.plugins.externalEditors.importer.ExternalEditorsImporter;
	import actionScripts.plugins.externalEditors.utils.ExternalEditorsSharedObjectUtil;
	import actionScripts.valueObjects.ConstantsCoreVO;

	import spark.components.Alert;

	public class VagrantPlugin extends ConsoleBuildPluginBase implements ISettingsProvider
	{
		public static var NAMESPACE:String = "actionScripts.plugins.vagrant::VagrantPlugin";
		
		public static var editors:ArrayCollection; 
		
		override public function get name():String			{ return "Vagrant"; }
		override public function get author():String		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL + " Project Team"; }
		override public function get description():String	{ return "Access to Vagrant support from Moonshine-IDE"; }
		
		public var updateSitePath:String;

		private var pathSetting:PathSetting;
		private var defaultVagrantPath:String;
		private var vagrantConsole:VagrantConsolePlugin;
		private var queuedMethod:MethodDescriptor;

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
				var vagrantFile:File = new File(ConstantsCoreVO.IS_MACOS ? "/usr/local/bin" : "C:\\HashiCorp\\Vagrant");
				defaultVagrantPath = vagrantFile.exists ? vagrantFile.nativePath : null;
				if (defaultVagrantPath && !model.vagrantPath)
				{
					model.vagrantPath = defaultVagrantPath;
				}
			}
		}
		
		override public function deactivate():void
		{
			super.deactivate();
			onConsoleDeactivated(null);
		}

		override public function resetSettings():void
		{
			ExternalEditorsSharedObjectUtil.resetExternalEditorsInSO();
			editors = ExternalEditorsImporter.getDefaultEditors();
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
				pathSetting
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

			var command:String;
			if (ConstantsCoreVO.IS_MACOS)
			{
				command = "vagrant plugin install vagrant-vbguest;vagrant up 2>&1 | tee vagrant_up.log";
			}
			warning("%s", command);
			success("Log file location: "+ file.fileBridge.parent.fileBridge.nativePath + file.fileBridge.separator +"vagrant_up.log");
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, "Vagrant Up", "Running ", false));
			
			this.start(
				new <String>[command], file.fileBridge.parent
			);
		}

		public function vagrantHalt(file:FileLocation):void
		{
			if (running)
			{
				stop(true);
				queuedMethod = new MethodDescriptor(this, "vagrantHalt", file);
				return;
			}

			var command:String;
			if (ConstantsCoreVO.IS_MACOS)
			{
				command = "vagrant halt";
			}
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
				queuedMethod = new MethodDescriptor(this, "vagrantReload", file);
				return;
			}

			var command:String;
			if (ConstantsCoreVO.IS_MACOS)
			{
				command = "vagrant reload 2>&1 | tee vagrant_reload.log";
			}
			warning("%s", command);
			success("Log file location: "+ file.fileBridge.parent.fileBridge.nativePath + file.fileBridge.separator +"vagrant_reload.log");
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, "Vagrant Reload", "Running ", false));

			this.start(
					new <String>[command], file.fileBridge.parent
			);
		}

		private function vagrantSSH(file:FileLocation):void
		{
			return;

			if (running)
			{
				stop(true);
				queuedMethod = new MethodDescriptor(this, "vagrantReload", file);
				return;
			}

			var command:String;
			if (ConstantsCoreVO.IS_MACOS)
			{
				command = "vagrant reload 2>&1 | tee vagrant_reload.log";
			}
			warning("%s", command);
			success("Log file location: "+ file.fileBridge.parent.fileBridge.nativePath + file.fileBridge.separator +"vagrant_reload.log");
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, "Vagrant Reload", "Running ", false));

			this.start(
					new <String>[command], file.fileBridge.parent
			);
		}

		override protected function onNativeProcessExit(event:NativeProcessExitEvent):void
		{
			super.onNativeProcessExit(event);
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));

			// run any queued process
			if (queuedMethod)
			{
				queuedMethod.callMethod();
				queuedMethod = null;
			}
		}
	}
}