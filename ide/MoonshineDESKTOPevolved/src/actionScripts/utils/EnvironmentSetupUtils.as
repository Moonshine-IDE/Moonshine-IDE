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
package actionScripts.utils
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.controls.Alert;
	
	import actionScripts.locator.IDEModel;
	import actionScripts.plugins.git.model.MethodDescriptor;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.SDKReferenceVO;
	import actionScripts.valueObjects.SDKTypes;
	
	public class EnvironmentSetupUtils
	{
		private static var instance:EnvironmentSetupUtils;
		
		private var model:IDEModel = IDEModel.getInstance();
		private var customProcess:NativeProcess;
		private var customInfo:NativeProcessStartupInfo;
		private var isErrorClose:Boolean;
		private var windowsBatchFile:File;
		private var externalCallCompletionHandler:Function;
		private var executeWithCommands:Array;
		private var customSDKPath:String;
		private var isDelayRunInProcess:Boolean;
		private var processQueus:Array = [];
		private var isSingleProcessRunning:Boolean;
		
		public static function getInstance():EnvironmentSetupUtils
		{	
			if (!instance) instance = new EnvironmentSetupUtils();
			return instance;
		}
		
		public function updateToCurrentEnvironmentVariable():void
		{
			if (isSingleProcessRunning)
			{
				processQueus.push("executeSetCommand");
				return;
			}
			
			executeSetCommand();
		}
		
		public function initCommandGenerationToSetLocalEnvironment(completion:Function, customSDK:String=null, withCommands:Array=null):void
		{
			if (isSingleProcessRunning)
			{
				// we'll call the method in our way later
				processQueus.push(new MethodDescriptor(null, null, completion, customSDK, withCommands));
				return;
			}
			
			executeCommandWithSetLocalEnvironment(completion, customSDK, withCommands);
		}
		
		private function flush():void
		{
			externalCallCompletionHandler = null;
			executeWithCommands = null;
			windowsBatchFile = null;
			customSDKPath = null;
			
			if (processQueus.length != 0)
			{
				var tmpElement:Object = processQueus.shift();
				if (tmpElement is String)
				{
					executeSetCommand();
				}
				else if (tmpElement is MethodDescriptor)
				{
					// we're not going to use methodDescriptor.callMethod()
					// as the said method will require the calling method
					// to be public; here we call the private one
					executeCommandWithSetLocalEnvironment.apply(null, (tmpElement as MethodDescriptor).parameters);
				}
			}
		}
		
		private function executeSetCommand():void
		{
			isSingleProcessRunning = true;
			
			if (ConstantsCoreVO.IS_MACOS) executeOSX();
			else executeWindows();
		}
		
		private function executeCommandWithSetLocalEnvironment(completion:Function, customSDK:String=null, withCommands:Array=null):void
		{
			isSingleProcessRunning = true;
			
			externalCallCompletionHandler = completion;
			executeWithCommands = withCommands;
			customSDKPath = customSDK;
			executeSetCommand();
		}
		
		private function executeWindows():void
		{
			var setCommand:String = getPlatformCommand();
			
			// do not proceed if no path to set
			if (!setCommand)
			{
				if (externalCallCompletionHandler != null) externalCallCompletionHandler(null);
				flush();
				return;
			}
			
			windowsBatchFile = File.applicationStorageDirectory.resolvePath("setLocalEnvironment.cmd");
			FileUtils.writeToFileAsync(windowsBatchFile, setCommand, onBatchFileWriteComplete, onBatchFileWriteError);
		}
		
		private function executeOSX():void
		{
			var setCommand:String = getPlatformCommand();
			
			// do not proceed if no path to set
			if (!setCommand)
			{
				if (externalCallCompletionHandler != null) externalCallCompletionHandler(null);
				
				isSingleProcessRunning = false;
				flush();
				return;
			}
			
			if (externalCallCompletionHandler != null)
			{
				// in case of macOS - instead of retuning any
				// bash script file path return the full command
				// to execute by caller's own nativeProcess process
				externalCallCompletionHandler(setCommand);
				isSingleProcessRunning = false;
				flush();
			}
			else
			{
				onCommandLineExecutionWith(setCommand);
			}
		}
		
		private function getPlatformCommand():String
		{
			var setCommand:String = ConstantsCoreVO.IS_MACOS ? "" : "@echo off\r\n";
			var isValidToExecute:Boolean;
			var setPathCommand:String = ConstantsCoreVO.IS_MACOS ? "export PATH=" : "set PATH=";
			var defaultOrCustomSDKPath:String;
			var additionalCommandLines:String = "";
			var defaultSDKtype:String;
			var defaultSDKreferenceVo:SDKReferenceVO;
			
			if (customSDKPath && FileUtils.isPathExists(customSDKPath))
			{
				defaultOrCustomSDKPath = customSDKPath;
			}
			else if (UtilsCore.isDefaultSDKAvailable())
			{
				defaultOrCustomSDKPath = model.defaultSDK.fileBridge.nativePath;
			}
			
			defaultSDKreferenceVo = SDKUtils.getSDKFromSavedList(defaultOrCustomSDKPath);
			if (defaultSDKreferenceVo) defaultSDKtype = defaultSDKreferenceVo.type;
			
			if (UtilsCore.isJavaForTypeaheadAvailable())
			{
				setCommand += getSetExportCommand("JAVA_HOME", model.javaPathForTypeAhead.fileBridge.nativePath);
				setPathCommand += (ConstantsCoreVO.IS_MACOS ? "$JAVA_HOME/bin:" : "%JAVA_HOME%\\bin;");
				isValidToExecute = true;
			}
			if (UtilsCore.isAntAvailable())
			{
				setCommand += getSetExportCommand("ANT_HOME", model.antHomePath.fileBridge.nativePath);
				setPathCommand += (ConstantsCoreVO.IS_MACOS ? "$ANT_HOME/bin:" : "%ANT_HOME%\\bin;");
				isValidToExecute = true;
			}
			if (UtilsCore.isMavenAvailable())
			{
				setCommand += getSetExportCommand("MAVEN_HOME", model.mavenPath);
				setPathCommand += (ConstantsCoreVO.IS_MACOS ? "$MAVEN_HOME/bin:" : "%MAVEN_HOME%\\bin;");
				isValidToExecute = true;
			}
			if (UtilsCore.isGradleAvailable())
			{
				setCommand += getSetExportCommand("GRADLE_HOME", model.gradlePath);
				setPathCommand += (ConstantsCoreVO.IS_MACOS ? "$GRADLE_HOME/bin:" : "%GRADLE_HOME%\\bin;");
				isValidToExecute = true;
			}
			if (UtilsCore.isGrailsAvailable())
			{
				setCommand += getSetExportCommand("GRAILS_HOME", model.grailsPath);
				setPathCommand += (ConstantsCoreVO.IS_MACOS ? "$GRAILS_HOME/bin:" : "%GRAILS_HOME%\\bin;");
				isValidToExecute = true;
			}
			if (UtilsCore.isHaxeAvailable())
			{
				setCommand += getSetExportCommand("HAXE_HOME", model.haxePath);
				setPathCommand += (ConstantsCoreVO.IS_MACOS ? "$HAXE_HOME:" : "%HAXE_HOME%;");
				isValidToExecute = true;
			}
			if (UtilsCore.isNekoAvailable())
			{
				setCommand += getSetExportCommand("NEKO_HOME", model.nekoPath);
				setPathCommand += (ConstantsCoreVO.IS_MACOS ? "$NEKO_HOME:" : "%NEKO_HOME%;");
				isValidToExecute = true;
			}
			if (!ConstantsCoreVO.IS_MACOS && UtilsCore.isGitPresent())
			{
				// moonshine stores gir path with 'bin\git.exe' format 
				// we need to find probable sdk root instead
				// next add command to set caFile 
				var substrIndex:int = model.gitPath.indexOf(File.separator + "bin" + File.separator + "git.exe");
				if (substrIndex != -1)
				{
					var gitRootPath:String = model.gitPath.substring(0, substrIndex);
					if (FileUtils.isPathExists(gitRootPath + "\\mingw64\\ssl\\cert.pem"))
					{
						setCommand += getSetExportCommand("GIT_HOME", gitRootPath);
						additionalCommandLines += "%GIT_HOME%\\bin\\git config --global http.sslCAInfo %GIT_HOME%\\mingw64\\ssl\\cert.pem\r\n";
						isValidToExecute = true;
					}
				}
			}
			if (defaultOrCustomSDKPath)
			{
				var flexRoyaleHomeType:String = (defaultSDKtype && defaultSDKtype == SDKTypes.ROYALE) ? "ROYALE_HOME" : "FLEX_HOME";
				setCommand += getSetExportCommand(flexRoyaleHomeType, defaultOrCustomSDKPath);
				setPathCommand += (ConstantsCoreVO.IS_MACOS ? "$"+ flexRoyaleHomeType +"/bin:" : "%"+ flexRoyaleHomeType +"%\\bin;");
				
				if (!defaultSDKtype || (defaultSDKtype && defaultSDKtype != SDKTypes.ROYALE))
				{
					var airHomeType:String = "AIR_SDK_HOME";
					setCommand += getSetExportCommand(airHomeType, defaultOrCustomSDKPath);
					setPathCommand += (ConstantsCoreVO.IS_MACOS ? "$"+ airHomeType +"/bin:" : "%"+ airHomeType +"%\\bin;");
				}
				
				isValidToExecute = true;
			}
			
			// if nothing found in above three don't run
			if (!isValidToExecute) return null;
			
			if (ConstantsCoreVO.IS_MACOS)
			{
				setCommand += setPathCommand + "$PATH;";
				if (additionalCommandLines != "") setCommand += additionalCommandLines;
				if (executeWithCommands) setCommand += executeWithCommands.join(";");
			}
			else
			{
				// need to set PATH under application shell
				setCommand += setPathCommand + "%PATH%\r\n";
				if (additionalCommandLines != "") setCommand += additionalCommandLines;
				if (executeWithCommands) setCommand += executeWithCommands.join("\r\n");
			}
			
			return setCommand;
		}
		
		private function getSetExportCommand(field:String, path:String):String
		{
			if (ConstantsCoreVO.IS_MACOS) return "export "+ field +"='"+ path +"';";
			return "set "+ field +"="+ path +"\r\n";
		}
		
		private function onBatchFileWriteComplete():void
		{
			// following timeout is to overcome process-holding error
			// in vagarant as reported by Joel at
			// https://github.com/prominic/Moonshine-IDE/issues/449#issuecomment-473418675
			var timeoutValue:uint = setTimeout(function():void
			{
				clearTimeout(timeoutValue);
				if (externalCallCompletionHandler != null)
				{
					// returns batch file path to be 
					// executed by the caller's nativeProcess process
					if (windowsBatchFile) externalCallCompletionHandler(windowsBatchFile.nativePath);

					isSingleProcessRunning = false;
					flush();
				}
				else if (windowsBatchFile)
				{
					onCommandLineExecutionWith(windowsBatchFile.nativePath);
				}
			}, 1000);
		}
		
		private function onCommandLineExecutionWith(command:String):void
		{
			customInfo = new NativeProcessStartupInfo();
			customInfo.executable = ConstantsCoreVO.IS_MACOS ? 
				File.documentsDirectory.resolvePath("/bin/bash") : new File("c:\\Windows\\System32\\cmd.exe");
			
			customInfo.arguments = Vector.<String>([ConstantsCoreVO.IS_MACOS ? "-c" : "/c", command]);
			customProcess = new NativeProcess();
			startShell(true);
			customProcess.start(customInfo);
		}
		
		private function onBatchFileWriteError(value:String):void
		{
			Alert.show("Local environment setup failed[1]!\n"+ value, "Error!");
			isSingleProcessRunning = false;
			flush();
		}
		
		private function startShell(start:Boolean):void 
		{
			if (start)
			{
				isErrorClose = false;
				customProcess = new NativeProcess();
				customProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);
				customProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
				customProcess.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, shellError);
				customProcess.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, shellError);
				customProcess.addEventListener(NativeProcessExitEvent.EXIT, shellExit);
			}
			else
			{
				if (!customProcess) return;
				if (customProcess.running) customProcess.exit();
				customProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);
				customProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
				customProcess.removeEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, shellError);
				customProcess.removeEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, shellError);
				customProcess.removeEventListener(NativeProcessExitEvent.EXIT, shellExit);
				customProcess = null;
				isErrorClose = false;
				
				isSingleProcessRunning = false;
				flush();
			}
		}
		
		private function shellError(event:ProgressEvent):void 
		{
			if (customProcess)
			{
				/*var output:IDataInput = customProcess.standardError;
				var data:String = output.readUTFBytes(output.bytesAvailable).toLowerCase();
				
				Alert.show("Local environment setup failed[2]!\n"+ data);*/
				startShell(false);
			}
		}
		
		private function shellExit(event:NativeProcessExitEvent):void 
		{
			if (customProcess) 
			{
				startShell(false);
			}
		}
		
		private function shellData(event:ProgressEvent):void 
		{
			/*var output:IDataInput = (customProcess.standardOutput.bytesAvailable != 0) ? customProcess.standardOutput : customProcess.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			Alert.show(data, "shell Data");*/
		}
	}
}