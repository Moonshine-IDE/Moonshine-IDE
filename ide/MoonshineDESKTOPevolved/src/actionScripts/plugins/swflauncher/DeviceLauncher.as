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
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.ShowSettingsEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.actionscript.as3project.vo.BuildOptions;
	import actionScripts.plugin.console.ConsoleOutputter;
	import actionScripts.plugin.core.compiler.CompilerEventBase;
	import actionScripts.valueObjects.Settings;

	public class DeviceLauncher extends ConsoleOutputter
	{
		private var customProcess:NativeProcess;
		private var customInfo:NativeProcessStartupInfo;
		private var queue:Vector.<Object> = new Vector.<Object>();
		private var connectedDevices:Vector.<String>;
		private var isAndroid:Boolean;
		private var isRunAsDebugger:Boolean;
		
		public function DeviceLauncher()
		{
		}
		
		public function runOnDevice(project:AS3ProjectVO, sdk:File, swf:File, descriptorPath:String, runAsDebugger:Boolean=false):void
		{
			isAndroid = (project.buildOptions.targetPlatform == "Android");
			isRunAsDebugger = runAsDebugger;
			
			// checks if the credentials are present
			if (!ensureCredentialsPresent(project)) return;
			
			// We need the application ID; without pre-guessing any
			// lets read and find it
			var descriptorFile:FileLocation = project.folderLocation.fileBridge.resolvePath(descriptorPath);
			var descriptorXML:XML = new XML(descriptorFile.fileBridge.read());
			var xmlns:Namespace = new Namespace(descriptorXML.namespace());
			var appID:String = descriptorXML.xmlns::id;
			
			var descriptorPathModified:Array = descriptorPath.split(File.separator);
			
			// STEP 1
			var executableFile:File = (Settings.os == "win") ? new File("c:\\Windows\\System32\\cmd.exe") : new File("/bin/bash");
			
			customInfo = new NativeProcessStartupInfo();
			customInfo.executable = sdk.resolvePath("bin/adt");
			customInfo.workingDirectory = swf.parent;
			
			queue = new Vector.<Object>();
			
			//addToQueue({com:(Settings.os == "win" ? "set " : "export ") + "FLEX_HOME="+ sdk.nativePath, showInConsole:false});
			addToQueue({com:"-devices&&-platform&&"+ (isAndroid ? "android" : "ios"), showInConsole:false});
			
			var adtPackagingCom:String;
			if (isAndroid) 
			{
				adtPackagingCom = '-package -target '+ (runAsDebugger ? 'apk-debug' : 'apk') +' -storetype pkcs12 -keystore "'+ project.buildOptions.certAndroid +'" '+ project.name +'.apk' +' '+ descriptorPathModified[descriptorPathModified.length-1] +' '+ swf.name;
			}
			else
			{
				var packagingMode:String = (runAsDebugger) ? "ipa-debug-interpreter" : ((project.buildOptions.iosPackagingMode == BuildOptions.IOS_PACKAGING_STANDARD) ? "ipa-test" : "ipa-test-interpreter");
				adtPackagingCom = '-package&&-target&&'+ packagingMode +'&&-storetype&&pkcs12&&-keystore&&'+ project.buildOptions.certIos +'&&-storepass&&'+ isAndroid ? project.buildOptions.certAndroidPassword : project.buildOptions.certIosPassword +'&&-provisioning-profile&&'+ project.buildOptions.certIosProvisioning +'&&'+ project.name +'.ipa' +'&&'+ descriptorPathModified[descriptorPathModified.length-1] +'&&'+ swf.name;
			}
			
			// extensions and resources
			if (project.nativeExtensions && project.nativeExtensions.length > 0) adtPackagingCom+= ' -extdir "'+ project.nativeExtensions[0].fileBridge.nativePath +'"';
			if (project.resourcePaths)
			{
				for each (var i:FileLocation in project.resourcePaths)
				{
					adtPackagingCom += ' "'+ i.fileBridge.nativePath +'"';
				}
			}
			
			addToQueue({com:adtPackagingCom, showInConsole:true});
			//addToQueue({com:isAndroid ? project.buildOptions.certAndroidPassword : project.buildOptions.certIosPassword, showInConsole:false});
			addToQueue({com:"-installApp&&-platform&&"+ (isAndroid ? "android" : "ios") +"&&-device&&2&&-package&&"+ project.name +(isAndroid ? ".apk" : ".ipa"), showInConsole:true});
			addToQueue({com:"-launchApp&&-platform&&"+ (isAndroid ? "android" : "ios") +"&&-appid&&"+ appID, showInConsole:true});
			
			if (customProcess) startShell(false);
			startShell(true);
			flush();
		}
		
		private function ensureCredentialsPresent(project:AS3ProjectVO):Boolean
		{
			if (isAndroid && (project.buildOptions.certAndroid && project.buildOptions.certAndroid != "") && (project.buildOptions.certAndroidPassword && project.buildOptions.certAndroidPassword != ""))
			{
				return true;
			}
			else if (!isAndroid && (project.buildOptions.certIos && project.buildOptions.certIos != "") && (project.buildOptions.certIosPassword && project.buildOptions.certIosPassword != "") && (project.buildOptions.certIosProvisioning && project.buildOptions.certIosProvisioning != ""))
			{
				return true;
			}
			
			Alert.show("Insufficient information. Process terminates.", "Error!", Alert.OK, null, onProcessTerminatesDueToCredentials);
			return false;
			
			/*
			 * @local
			 */
			function onProcessTerminatesDueToCredentials(event:CloseEvent):void
			{
				GlobalEventDispatcher.getInstance().dispatchEvent(
					new ShowSettingsEvent(project, "run")
				);
			}
		}
		
		private function addToQueue(value:Object):void
		{
			queue.push(value);
		}
		
		private function flush():void
		{
			if (queue.length == 0) 
			{
				startShell(false);
				return;
			}
			
			if (customProcess && customProcess.running)
			{
				//customProcess.exit();
				return;
			}
			
			if (queue[0].showInConsole) debug("Sending to adt: %s", queue[0].com);
			
			customInfo.arguments = new Vector.<String>();
			var tmpArr:Array = queue[0].com.split("&&");
			for (var i:String in tmpArr)
			{
				customInfo.arguments.push(tmpArr[i]);
			}
			
			queue.shift();
			customProcess.start(customInfo);
			
			/*var input:IDataOutput = customProcess.standardInput;
			input.writeUTFBytes(queue[0].com +"\n");
			queue.shift();*/
		}
		
		private function startShell(start:Boolean):void 
		{
			if (start)
			{
				customProcess = new NativeProcess();
				customProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);
				customProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
				customProcess.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, shellError);
				customProcess.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, shellError);
				customProcess.addEventListener(NativeProcessExitEvent.EXIT, shellExit);
				//customProcess.start(customInfo);
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
			}
		}
		
		private var isErrorClose:Boolean;
		
		private function shellError(e:ProgressEvent):void 
		{
			if (customProcess)
			{
				var output:IDataInput = customProcess.standardError;
				var data:String = output.readUTFBytes(output.bytesAvailable);
				
				var syntaxMatch:Array;
				var generalMatch:Array;
				var initMatch:Array;
				
				syntaxMatch = data.match(/(.*?)\((\d*)\): col: (\d*) Error: (.*).*/);
				if (syntaxMatch) {
					var pathStr:String = syntaxMatch[1];
					var lineNum:int = syntaxMatch[2];
					var colNum:int = syntaxMatch[3];
					var errorStr:String = syntaxMatch[4];
				}
				
				generalMatch = data.match(/(.*?): Error: (.*).*/);
				if (!syntaxMatch && generalMatch)
				{ 
					pathStr = generalMatch[1];
					errorStr  = generalMatch[2];
					pathStr = pathStr.substr(pathStr.lastIndexOf("/")+1);
					debug("%s", data);
				}
				else if (!isRunAsDebugger)
				{
					debug("%s", data);
				}
				
				isErrorClose = true;
				startShell(false)
			}
		}
		
		private function shellExit(e:NativeProcessExitEvent):void 
		{
			if (customProcess) 
			{
				//GlobalEventDispatcher.getInstance().dispatchEvent(new CompilerEventBase(CompilerEventBase.STOP_DEBUG,false));
				if (!isErrorClose) flush();
			}
		}
		
		private function shellData(e:ProgressEvent):void 
		{
			var output:IDataInput = customProcess.standardOutput;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			trace(" ||||||| \n"+ data);
			var match:Array;
			
			match = data.toLowerCase().match(/set flex_home/);
			if (match)
			{
				//flush();
				return;
			}
			
			match = data.toLowerCase().match(/list of attached devices/);
			if (match)
			{
				/*List of attached devices
				
				
				List of attached devices:
				Handle	DeviceClass	DeviceUUID					DeviceName
				1	iPad    	6de82fb316b5bc0dc5534e6725678fe88bdfccc8	Santanu’s iPad*/
				//flush();
				return;
				var devicesLines:Array = data.split("\r\n");
				devicesLines.shift();
				connectedDevices = new Vector.<String>();
				for (var i:String in devicesLines)
				{
					if (devicesLines[i] != "")
					{
						connectedDevices.push(devicesLines[i].split("\t")[0]);
					}
					else
					{
						break;
					}
				}
				
				// probable termination if no device found connected
				if (connectedDevices.length == 0)
				{
					Alert.show("Please make sure your device is connected.", "Error!");
					startShell(false);
					return;
				}
				
				//flush();
				return;
			}
			
			data = data.toLowerCase();
			
			match = data.match(/password/);
			if (match)
			{
				//flush();
				return;
			}
			
			match = data.match(/the application has been packaged with a shared runtime/);
			if (match) 
			{
				print("NOTE: The application has been packaged with a shared runtime.");
				//flush();
				return;
			}
			
			isErrorClose = false;
			//flush();
		}
	}
}