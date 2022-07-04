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
	import actionScripts.valueObjects.HelperConstants;

	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	
	import mx.controls.Alert;
	import mx.utils.UIDUtil;
	
	import actionScripts.events.ApplicationEvent;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.valueObjects.ComponentTypes;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.EnvironmentUtilsCusomSDKsVO;
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
		private var customSDKPaths:EnvironmentUtilsCusomSDKsVO;
		private var isDelayRunInProcess:Boolean;
		private var processQueus:Array = [];
		private var isSingleProcessRunning:Boolean;
		private var isNekoSymlinkGenerated:Boolean;
		
		public static function getInstance():EnvironmentSetupUtils
		{	
			if (!instance) instance = new EnvironmentSetupUtils();
			return instance;
		}
		
		public function EnvironmentSetupUtils()
		{
			GlobalEventDispatcher.getInstance().addEventListener(
				ApplicationEvent.DISPOSE_FOOTPRINT,
				onDisposeFootprints,
				false, 0, true
			);
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
		
		public function initCommandGenerationToSetLocalEnvironment(completion:Function, customSDKs:EnvironmentUtilsCusomSDKsVO=null, withCommands:Array=null):void
		{
			if (isSingleProcessRunning)
			{
				// we'll call the method in our way later
				processQueus.push(new MethodDescriptor(null, null, completion, customSDKs, withCommands));
				return;
			}
			
			executeCommandWithSetLocalEnvironment(completion, customSDKs, withCommands);
		}
		
		private function flush():void
		{
			externalCallCompletionHandler = null;
			executeWithCommands = null;
			windowsBatchFile = null;
			customSDKPaths = null;
			
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
			
			if (ConstantsCoreVO.IS_MACOS)
			{
				executeOSX();
			}
			else
			{
				executeWindows();
			}
		}
		
		private function executeCommandWithSetLocalEnvironment(completion:Function, customSDKs:EnvironmentUtilsCusomSDKsVO=null, withCommands:Array=null):void
		{
			isSingleProcessRunning = true;
			
			externalCallCompletionHandler = completion;
			executeWithCommands = withCommands;
			customSDKPaths = customSDKs;
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
			
			// to reduce file-writing process
			// re-run by the existing file if the
			// contents matched
			windowsBatchFile = getBatchFilePath();
			try
			{
				//this previously used FileUtils.writeToFileAsync(), but commands
				//would sometimes fail because the file would still be in use, even
				//after the FileStream dispatched Event.CLOSE
				FileUtils.writeToFile(windowsBatchFile, setCommand);
				onBatchFileWriteComplete();
			}
			catch(e:Error)
			{
				onBatchFileWriteError(e.toString());
				return;
			}
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
			var valueDYLD_LIBRARY_PATHs:Array = [];
			var isHaxeAvailable:Boolean;
			
			// PROJECT SDK
			defaultOrCustomSDKPath = hasCustomSDKRequest(EnvironmentUtilsCusomSDKsVO.SDK_FIELD);
			if (!defaultOrCustomSDKPath && UtilsCore.isDefaultSDKAvailable())
			{
				defaultOrCustomSDKPath = model.defaultSDK.fileBridge.nativePath;
			}
			
			defaultSDKreferenceVo = SDKUtils.getSDKFromSavedList(defaultOrCustomSDKPath);
			if (defaultSDKreferenceVo) defaultSDKtype = defaultSDKreferenceVo.type;
			if (defaultOrCustomSDKPath)
			{
				var flexRoyaleHomeType:String = (defaultSDKtype && defaultSDKtype == SDKTypes.ROYALE) ? "ROYALE_HOME" : "FLEX_HOME";
				setCommand += getSetExportWithoutQuote(flexRoyaleHomeType, defaultOrCustomSDKPath);
				setPathCommand += (ConstantsCoreVO.IS_MACOS ? "$"+ flexRoyaleHomeType +"/bin:" : "%"+ flexRoyaleHomeType +"%\\bin;");
				
				if (!defaultSDKtype || (defaultSDKtype && defaultSDKtype != SDKTypes.ROYALE))
				{
					var airHomeType:String = "AIR_SDK_HOME";
					setCommand += getSetExportWithoutQuote(airHomeType, defaultOrCustomSDKPath);
					setPathCommand += (ConstantsCoreVO.IS_MACOS ? "$"+ airHomeType +"/bin:" : "%"+ airHomeType +"%\\bin;");
				}
				
				isValidToExecute = true;
			}
			
			// JDK
			defaultOrCustomSDKPath = hasCustomSDKRequest(EnvironmentUtilsCusomSDKsVO.JDK_FIELD);
			if (!defaultOrCustomSDKPath && UtilsCore.isJavaForTypeaheadAvailable())
			{
				defaultOrCustomSDKPath = model.javaPathForTypeAhead.fileBridge.nativePath;
			}
			if (defaultOrCustomSDKPath)
			{
				setCommand += getSetExportWithoutQuote("JAVA_HOME", defaultOrCustomSDKPath);
				setPathCommand += (ConstantsCoreVO.IS_MACOS ? "$JAVA_HOME/bin:" : "%JAVA_HOME%\\bin;");
				isValidToExecute = true;
			}
			
			if (UtilsCore.isAntAvailable())
			{
				setCommand += getSetExportWithoutQuote("ANT_HOME", model.antHomePath.fileBridge.nativePath);
				setPathCommand += (ConstantsCoreVO.IS_MACOS ? "$ANT_HOME/bin:" : "%ANT_HOME%\\bin;");
				isValidToExecute = true;
			}
			if (UtilsCore.isMavenAvailable())
			{
				setCommand += getSetExportWithoutQuote("MAVEN_HOME", model.mavenPath);
				setPathCommand += (ConstantsCoreVO.IS_MACOS ? "$MAVEN_HOME/bin:" : "%MAVEN_HOME%\\bin;");
				isValidToExecute = true;
			}
			if (UtilsCore.isGradleAvailable())
			{
				setCommand += getSetExportWithoutQuote("GRADLE_HOME", model.gradlePath);
				setPathCommand += (ConstantsCoreVO.IS_MACOS ? "$GRADLE_HOME/bin:" : "%GRADLE_HOME%\\bin;");
				isValidToExecute = true;
			}
			if (UtilsCore.isGrailsAvailable())
			{
				setCommand += getSetExportWithoutQuote("GRAILS_HOME", model.grailsPath);
				setPathCommand += (ConstantsCoreVO.IS_MACOS ? "$GRAILS_HOME/bin:" : "%GRAILS_HOME%\\bin;");
				isValidToExecute = true;
			}
			if (UtilsCore.isHaxeAvailable())
			{
				setCommand += getSetExportWithoutQuote("HAXE_HOME", model.haxePath);
				setPathCommand += (ConstantsCoreVO.IS_MACOS ? "$HAXE_HOME:" : "%HAXE_HOME%;");
				isValidToExecute = true;
				isHaxeAvailable = true;
			}
			if (UtilsCore.isNekoAvailable())
			{
				setCommand += getSetExportWithoutQuote("NEKO_HOME", model.nekoPath);
				setPathCommand += (ConstantsCoreVO.IS_MACOS ? "$NEKO_HOME:" : "%NEKO_HOME%;");
				valueDYLD_LIBRARY_PATHs.push(model.nekoPath);
				isValidToExecute = true;
			}
			/*if (UtilsCore.isVagrantAvailable())
			{
				var vagrantPath:String = model.vagrantPath;
				if (model.fileCore.isPathExists([model.vagrantPath, "bin"].join(model.fileCore.separator)))
				{
					vagrantPath = [model.vagrantPath, "bin"].join(model.fileCore.separator);
				}

				setCommand += getSetExportWithoutQuote("VAGRANT_HOME", File.applicationStorageDirectory.nativePath);
				setPathCommand += (ConstantsCoreVO.IS_MACOS ? "$VAGRANT_HOME:" : "%VAGRANT_HOME%;");
				isValidToExecute = true;
			}*/
			if (UtilsCore.isVirtualBoxAvailable())
			{
				setCommand += getSetExportWithoutQuote("VIRTUALBOX_HOME", model.virtualBoxPath);
				setPathCommand += (ConstantsCoreVO.IS_MACOS ? "$VIRTUALBOX_HOME:" : "%VIRTUALBOX_HOME%;");
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
						setCommand += getSetExportWithoutQuote("GIT_HOME", gitRootPath);
						additionalCommandLines += "\"%GIT_HOME%\\bin\\git\" config --global http.sslCAInfo \"%GIT_HOME%\\mingw64\\ssl\\cert.pem\"\r\n";
						isValidToExecute = true;
					}
				}
			}
			if (UtilsCore.isNotesDominoAvailable())
			{
				valueDYLD_LIBRARY_PATHs.push(
						ConstantsCoreVO.IS_MACOS ? [model.notesPath,"Contents","MacOS"].join(File.separator) : (new File(model.notesPath)).parent.nativePath
				)
			}

			if (valueDYLD_LIBRARY_PATHs.length != 0)
			{
				setCommand += getSetExportWithoutQuote(
						"DYLD_LIBRARY_PATH",
						ConstantsCoreVO.IS_MACOS ? valueDYLD_LIBRARY_PATHs.join(":") : valueDYLD_LIBRARY_PATHs.join(";")
				);
				setPathCommand += (ConstantsCoreVO.IS_MACOS ? "$DYLD_LIBRARY_PATH:" : "%DYLD_LIBRARY_PATH%;");
				isValidToExecute = true;
			}

			// if nothing found in above three don't run
			if (!isValidToExecute) return null;
			
			if (ConstantsCoreVO.IS_MACOS)
			{
				setCommand += setPathCommand + "$PATH;";

				// adds only if Haxe is available and installed in Moonshine custom location
				if (isHaxeAvailable && !isNekoSymlinkGenerated &&
						model.haxePath.indexOf(HelperConstants.DEFAULT_INSTALLATION_PATH.nativePath) != -1)
				{
					setCommand += HelperConstants.HAXE_SYMLINK_COMMANDS.join(";") +";";
					isNekoSymlinkGenerated = true;
				}

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
		
		private function getSetExportWithQuote(field:String, path:String):String
		{
			if (ConstantsCoreVO.IS_MACOS)
			{
				return "export "+ field +"=\""+ path +"\";";
			}

			return "set "+ field +"=\""+ path +"\"\r\n";
		}

		private function getSetExportWithoutQuote(field:String, path:String):String
		{
			if (ConstantsCoreVO.IS_MACOS)
			{
				return getSetExportWithQuote(field, path);
			}

			return "set "+ field +"="+ path +"\r\n";
		}

		private function onBatchFileWriteComplete():void
		{
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
		
		private function getBatchFilePath():File
		{
			var tempDirectory:FileLocation = model.fileCore.resolveTemporaryDirectoryPath("moonshine/environmental");
			if (!tempDirectory.fileBridge.exists)
			{
				tempDirectory.fileBridge.createDirectory();
			}
			
			return tempDirectory.fileBridge.resolvePath(UIDUtil.createUID() +".cmd").fileBridge.getFile as File;
		}
		
		private function onBatchFileWriteError(value:String):void
		{
			Alert.show("Local environment setup failed[1]!\n"+ value, "Error!");
			isSingleProcessRunning = false;
			flush();
		}
		
		private function onDisposeFootprints(event:ApplicationEvent):void
		{
			var tempDirectory:FileLocation = model.fileCore.resolveTemporaryDirectoryPath("moonshine");
			if (!ConstantsCoreVO.IS_MACOS)
			{
				customInfo = new NativeProcessStartupInfo();
				customInfo.executable = new File("c:\\Windows\\System32\\cmd.exe");
				
				customInfo.arguments = Vector.<String>(["/c", "rmdir", "/q", "/s", tempDirectory.fileBridge.nativePath]);
				customProcess = new NativeProcess();
				customProcess.start(customInfo);
			}
			else
			{
				FileUtils.deleteDirectoryAsync(tempDirectory.fileBridge.getFile as File);
			}
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
		
		private function hasCustomSDKRequest(forPathField:String):String
		{
			if (customSDKPaths && 
				customSDKPaths[forPathField] && 
				FileUtils.isPathExists(customSDKPaths[forPathField]))
			{
				return customSDKPaths[forPathField];
			}
			
			return null;
		}
	}
}