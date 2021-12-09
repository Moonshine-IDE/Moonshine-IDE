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
package actionScripts.plugins.swflauncher
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.IDataInput;
	
	import mx.collections.ArrayCollection;
	
	import actionScripts.events.FilePluginEvent;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.core.compiler.ActionScriptBuildEvent;
	import actionScripts.plugin.settings.event.RequestSettingEvent;
	import actionScripts.plugins.as3project.mxmlc.MXMLCPlugin;
	import actionScripts.plugins.swflauncher.event.SWFLaunchEvent;
	import actionScripts.utils.FindAndCopyApplicationDescriptor;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.MobileDeviceVO;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.Settings;
	import flash.errors.IllegalOperationError;
	import actionScripts.events.DebugActionEvent;
	
	public class SWFLauncherPlugin extends PluginBase
	{	
		public static var RUN_AS_DEBUGGER: Boolean = false;
		
		override public function get name():String			{ return "SWF Launcher Plugin"; }
		override public function get author():String		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String	{ return "Opens .swf files externally. Handles AIR launching via ADL."; }
		
		private var customProcess:NativeProcess;
		private var currentAIRNamespaceVersion:String;
		
		override public function activate():void 
		{
			super.activate();
			dispatcher.addEventListener(SWFLaunchEvent.EVENT_LAUNCH_SWF, launchSwf);
			dispatcher.addEventListener(SWFLaunchEvent.EVENT_UNLAUNCH_SWF, unLaunchSwf);
			dispatcher.addEventListener(FilePluginEvent.EVENT_FILE_OPEN, handleOpenFile);
		}
		
		override public function deactivate():void 
		{
			super.deactivate();
			dispatcher.removeEventListener(SWFLaunchEvent.EVENT_LAUNCH_SWF, launchSwf);
			dispatcher.removeEventListener(FilePluginEvent.EVENT_FILE_OPEN, handleOpenFile);
			dispatcher.removeEventListener(SWFLaunchEvent.EVENT_UNLAUNCH_SWF, unLaunchSwf);
		}
		
		protected function handleOpenFile(event:FilePluginEvent):void
		{
			if (event.file.fileBridge.extension == "swf")
			{
				// Stop Moonshine from trying to open this file
				event.preventDefault();
				// Fake event
				launchSwf(new SWFLaunchEvent(SWFLaunchEvent.EVENT_LAUNCH_SWF, event.file.fileBridge.getFile as File));
			}
		}
		
		protected function launchSwf(event:SWFLaunchEvent):void
		{
			// Find project if we can (otherwise we can't open AIR swfs)
			if (!event.project) event.project = findProjectForFile(event.file);

			// Do we have an AIR project on our hands?
			if (event.project is AS3ProjectVO
				&& AS3ProjectVO(event.project).testMovie == AS3ProjectVO.TEST_MOVIE_AIR)
			{
				launchAIR(event.file, AS3ProjectVO(event.project), event.sdk);
			}
			else
			{
				// Open with default app
				launchExternal(event.url || event.file);
			}

			warning("Application " + event.project.name + " started.");
		}
		
		// when user has already one session ins progress and tries to build/run the application again- close current session and start new one
		protected function unLaunchSwf(event:SWFLaunchEvent):void
		{
			if(customProcess)
			{
				customProcess.exit(true);//Forcefully close running SWF
				addRemoveShellListeners(false);
				customProcess = null;
			}
		}
		
		protected function findProjectForFile(file:File):ProjectVO
		{
			for each (var project:ProjectVO in model.projects)
			{
				// See if we're part of this project
				if (file.nativePath.indexOf(project.folderLocation.fileBridge.nativePath) == 0)
				{
					return project;
				}
			}
			return null;
		}
		
		protected function launchAIR(file:File, project:AS3ProjectVO, sdk:File):void
		{
			if(customProcess)
			{
				customProcess.exit(true);
				addRemoveShellListeners(false);
				customProcess= null;
			}
			
			// Need project opened to run
			if (!project) return;
			
			// Can't open files without an SDK set
			if (!sdk && !project.buildOptions.customSDK)
			{
				// Try to fetch default value from MXMLC plugin
				var event:RequestSettingEvent = new RequestSettingEvent(MXMLCPlugin, 'defaultFlexSDK');
				dispatcher.dispatchEvent(event);
				// None found, abort
				if (event.value == "" || event.value == null) return;
				
				// Default SDK found, let's use that
				sdk = new File(event.value.toString());
			}
			
			var currentSDK:File = (project.buildOptions.customSDK) ? project.buildOptions.customSDK.fileBridge.getFile as File : sdk;
			var appXML:String = FindAndCopyApplicationDescriptor(file, project, file.parent);
			
			// In case of mobile project and device-run, lets divert
			if (project.isMobile && !project.buildOptions.isMobileRunOnSimulator)
			{
				throw new IllegalOperationError("SWFLauncherPlugin cannot launch Adobe AIR application on a mobile device.");
			}
			
			var customInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			
			var executableFile:File;
			if( Settings.os == "win")
            {
                executableFile = currentSDK.resolvePath("bin/adl.exe");
            }
			else
            {
                executableFile = currentSDK.resolvePath("bin/adl");
            }

			//var executableFile: File = new File("C:\\Program Files\\Adobe\\Adobe Flash Builder 4.6\\sdks\\4.14\\bin\\adl.exe");
			customInfo.executable = executableFile;
			var processArgs:Vector.<String> = new Vector.<String>;               

			if (project.isMobile)
			{
				var device:MobileDeviceVO;
				if (project.buildOptions.isMobileHasSimulatedDevice.name && !project.buildOptions.isMobileHasSimulatedDevice.key)
				{
					var deviceCollection:ArrayCollection = project.buildOptions.targetPlatform == "iOS" ? ConstantsCoreVO.TEMPLATES_IOS_DEVICES : ConstantsCoreVO.TEMPLATES_ANDROID_DEVICES;
					for (var i:int=0; i < deviceCollection.length; i++)
					{
						if (project.buildOptions.isMobileHasSimulatedDevice.name == deviceCollection[i].name)
						{
							device = deviceCollection[i];
							break;
						}
					}
				}
				else if (!project.buildOptions.isMobileHasSimulatedDevice.name)
					device = ConstantsCoreVO.TEMPLATES_ANDROID_DEVICES[0];
				else 
					device = project.buildOptions.isMobileHasSimulatedDevice;
				
				// @note
				// https://feathersui.com/help/faq/display-density.html
				
				processArgs.push("-screensize");
				processArgs.push(device.key); // NexusOne
				if (device.dpi != "")
				{
					processArgs.push("-XscreenDPI");
					processArgs.push(device.dpi);
				}
				processArgs.push("-XversionPlatform");
				processArgs.push(device.type);
				processArgs.push("-profile");
				processArgs.push("mobileDevice");
			}
			else
			{
				processArgs.push("-profile");
				processArgs.push("extendedDesktop");
			}
			
			if (project.nativeExtensions && project.nativeExtensions.length > 0)
			{
				var relativeExtensionFolderPath:String = project.folderLocation.fileBridge.getRelativePath(project.nativeExtensions[0], true);
				processArgs.push("-extdir");
				processArgs.push(relativeExtensionFolderPath +"/");
			}
			processArgs.push(appXML);
			//processArgs.push(rootPath);
			
			customInfo.arguments = processArgs;
			
			customInfo.workingDirectory = new File(project.folderLocation.fileBridge.nativePath);
			customProcess = new NativeProcess();
			addRemoveShellListeners(true);
			customProcess.start(customInfo);
		}
		
		private function addRemoveShellListeners(add:Boolean):void 
		{
			if (add)
			{
				customProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);
				customProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
				customProcess.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, shellError);
				customProcess.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, shellError);
				customProcess.addEventListener(NativeProcessExitEvent.EXIT, shellExit);
			}
			else
			{
				customProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);
				customProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
				customProcess.removeEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, shellError);
				customProcess.removeEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, shellError);
				customProcess.removeEventListener(NativeProcessExitEvent.EXIT, shellExit);
			}
		}
		
		private function shellError(e:ProgressEvent):void 
		{
			if(customProcess)
			{
				var output:IDataInput = customProcess.standardError;
				var data:String = output.readUTFBytes(output.bytesAvailable);

                var syntaxMatch:Array = data.match(/(.*?)\((\d*)\): col: (\d*) Error: (.*).*/);
				if (syntaxMatch)
				{
                    error("%s\n", data);
				}

                var generalMatch:Array = data.match(/[^:]*:?\s*Error:\s(.*)/);
				if (!syntaxMatch && generalMatch)
				{
					error("%s", data);
				}
                else if (data.match(/[^:]*:?\s*warning:\s(.*)/))
                {
                    warning("%s", data);
                }
				else if (!RUN_AS_DEBUGGER)
				{
					debug("%s", data);
				}
			}
		}
		
		private function shellExit(e:NativeProcessExitEvent):void 
		{
			if(customProcess)
				dispatcher.dispatchEvent(new DebugActionEvent(DebugActionEvent.DEBUG_STOP));
		}
		
		private function shellData(e:ProgressEvent):void 
		{
			var output:IDataInput = customProcess.standardOutput;
			var data:String = output.readUTFBytes(output.bytesAvailable);

			if (data.match(/initial content not found/))
			{
				warning("SWF source not found in application descriptor.");
				dispatcher.dispatchEvent(new ActionScriptBuildEvent(ActionScriptBuildEvent.EXIT_FDB,false));
			}
			else if (data.match(/error while loading initial content/))
			{
				error('Error while loading SWF source.\nInvalid application descriptor: Unknown namespace: '+ currentAIRNamespaceVersion);
				dispatcher.dispatchEvent(new ActionScriptBuildEvent(ActionScriptBuildEvent.EXIT_FDB,false));
			}
			else
			{
				print("%s", data);
			}
		}
		protected function launchExternal(file:Object):void
		{
			var request: URLRequest = new URLRequest((file is File) ? file.url : (file as String));
			try 
			{
				navigateToURL(request, '_blank'); // second argument is target
			}
			catch (e:Error)
			{
				error(e.getStackTrace() + " Error");
			}
		}
	}
}