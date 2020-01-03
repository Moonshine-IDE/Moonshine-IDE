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
package actionScripts.plugins.away3d
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.System;
	import flash.utils.IDataInput;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import actionScripts.events.AddTabEvent;
	import actionScripts.events.ProjectEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.IPlugin;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.settings.ISettingsProvider;
	import actionScripts.plugin.settings.SettingsView;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.ui.IContentWindow;
	import actionScripts.ui.tabview.CloseTabEvent;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.Settings;
	
	import components.containers.AwayBuilderView;
	
	public class Away3DPlugin extends PluginBase implements IPlugin, ISettingsProvider
	{
		public static const OPEN_AWAY3D_BUILDER:String = "OPEN_AWAY3D_BUILDER";
		
		private static const APP_EXT_COUNT					: int = 3;
		private static const APP_INTERNAL_PATH_TO_EXEC		: String = "/Contents/MacOS/";
		private static const APP_INTERNAL_PATH_TO_PLIST		: String = "/Contents/Info.plist";
		
		override public function get name():String { return "Away3D"; }
		override public function get author():String { return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String { return "The Away3D Moonshine Plugin."; }
		
		private var customProcess:NativeProcess;
		private var customInfo:NativeProcessStartupInfo;
		private var currentFile:File;
		private var abView:AwayBuilderView;
		
		private var finalExecutablePath:String;
		public function get executablePath():String
		{
			return finalExecutablePath;
		}
		public function set executablePath(value:String):void
		{
			var path:String = validatePath(value);
			finalExecutablePath = path ? path : value;
		}
		
		override public function activate():void
		{
			super.activate();
			
			dispatcher.addEventListener(OPEN_AWAY3D_BUILDER, openAway3DBuilder, false, 0, true);
			dispatcher.addEventListener(ProjectEvent.OPEN_PROJECT_AWAY3D, onAway3DProjectOpen, false, 0, true);
		}
		
		override public function deactivate():void
		{
			super.deactivate();
			
			dispatcher.removeEventListener(OPEN_AWAY3D_BUILDER, openAway3DBuilder);
			dispatcher.removeEventListener(ProjectEvent.OPEN_PROJECT_AWAY3D, onAway3DProjectOpen);
		}
		
		override public function resetSettings():void
		{
			currentFile = null;
		}
		
		public function getSettingsList():Vector.<ISetting>
		{
			return null;
		}
		
		private function openAway3DBuilder(event:Event):void
		{
			if (abView)
			{
				abView.currentFile = currentFile;
				model.activeEditor = abView;
				abView.loadAwayBuilderFile();
				return;
			}
			
			// lets remove the listener until builder loaded completely
			// else it'll create open file queue against every double-click 
			// from .awd files and inject them all at once to the builder
			// which will cause event injection problem to the builder
			dispatcher.removeEventListener(ProjectEvent.OPEN_PROJECT_AWAY3D, onAway3DProjectOpen);
			
			abView = new AwayBuilderView;
			abView.currentFile = currentFile;
			abView.addEventListener(CloseTabEvent.EVENT_TAB_CLOSED, onAwayBuilderTabClosed);
			abView.addEventListener(Event.COMPLETE, onAwayBuilderReady);
			dispatcher.dispatchEvent(new AddTabEvent(abView as IContentWindow));
		}
		
		private function onAwayBuilderReady(event:Event):void
		{
			abView.removeEventListener(Event.COMPLETE, onAwayBuilderReady);
			
			// add back the listener after a second else queued mouse-events 
			// may injected all along 
			var interval:uint = setTimeout(function():void
			{
				dispatcher.addEventListener(ProjectEvent.OPEN_PROJECT_AWAY3D, onAway3DProjectOpen, false, 0, true);
				clearTimeout(interval);
			}, 1000);
		}
		
		private function onAway3DSettingsUpdated(event:Event):void
		{
			if (executablePath)
			{
				runAwdFile(currentFile);
			}
			else
			{
				error("Application unavailable. Terminating.");
			}
		}
		
		private function onAway3DSettingsCanceled(event:Event):void
		{
			event.target.removeEventListener(SettingsView.EVENT_SAVE, onAway3DSettingsUpdated);
			event.target.removeEventListener(SettingsView.EVENT_CLOSE, onAway3DSettingsCanceled);
		}
		
		private function onAwayBuilderTabClosed(event:CloseTabEvent):void
		{
			abView.removeEventListener(CloseTabEvent.EVENT_TAB_CLOSED, onAwayBuilderTabClosed);
			abView = null;
		}
		
		private function onAway3DProjectOpen(event:ProjectEvent):void
		{
			currentFile = FileLocation(event.anObject).fileBridge.getFile as File;
			
			if (currentFile) 
			{
				if (!executablePath) openAway3DBuilder(null);
				else runAwdFile(currentFile);
			}
			else error("No Away3D file found.");
		}
		
		private function runAwdFile(withFile:File=null):void
		{
			var executableFile:File = (Settings.os == "win") ? new File("c:\\Windows\\System32\\cmd.exe") : new File("/bin/bash");
			var processArgs:Vector.<String> = new Vector.<String>;
			customInfo = new NativeProcessStartupInfo();
			
			if (Settings.os == "win") processArgs.push("/c");
			else processArgs.push("-c");
			processArgs.push("'"+ finalExecutablePath +"' '"+ withFile.nativePath +"'");
			
			customInfo.arguments = processArgs;
			customInfo.executable = executableFile;
			
			if (customProcess) startShell(false);
			startShell(true);
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
				customProcess.start(customInfo);
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
				else
				{
					debug("%s", data);
				}
				
				startShell(false);
			}
		}
		
		private function shellExit(e:NativeProcessExitEvent):void 
		{
			startShell(false);
		}
		
		private function shellData(e:ProgressEvent):void 
		{
			var output:IDataInput = customProcess.standardOutput;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			
			debug("%s", data);
		}
		
		/**
		 * Checks any given path (executable)
		 * existance in the application
		 *
		 * @required
		 * executable path
		 * @return
		 * Boolean
		 */
		private function validatePath( path:String ) : String {
			
			var finalExecPath : String;
			var splitPath : Array = path.split("/");
			
			// for the macOS platform
			if ( ConstantsCoreVO.IS_MACOS ) {
				
				// i.e. /applications/cord.app
				finalExecPath = (path.substr(path.length - APP_EXT_COUNT, APP_EXT_COUNT) != "app") ? path+".app" : path;
				if ( finalExecPath.charAt(0) != "/" ) finalExecPath = "/"+finalExecPath;
				
				/*
				* @note
				* we need some info.plist reading here,
				* as some of the app has different name/cases
				* for their executable file in Contents/MacOS folder
				* and some mac system may has case-sensitive setup.
				*/
				var file:File = new File(finalExecPath + APP_INTERNAL_PATH_TO_PLIST);
				if (file.exists)
				{
					var fs:FileStream = new FileStream();
					// following synchronous call as this method
					// requires to return a value in synchronous way
					fs.open(file, FileMode.READ);
					// following String mode read instead as XML
					// as the file values has no nested tag but as:
					// <key/>
					// <string/>
					// it could be hard to find a particular key's value
					// as there will be several such tags runs
					// one after another without having any
					// internal-relation between each other
					var executableFileName:String;
					var loopedCount:int;
					var plistXML:XML = XML(fs.readUTFBytes(fs.bytesAvailable));
					fs.close();
					
					// we don't want any unwanted namespace that problem in parsing
					var plistToString:String = plistXML.toXMLString();
					var xmlnsPattern:RegExp = new RegExp("xmlns[^\"]*\"[^\"]*\"", "gi");
					plistToString = plistToString.replace(xmlnsPattern, "");
					
					// removing all the whitespace/white-lines to form proper XML
					plistToString = plistToString.replace(/\s*\R/g, "\n");
					plistToString = plistToString.replace(/^\s*|[\t ]+$/gm, "");
					plistToString = plistToString.replace(/\n/g, "");
					plistXML = new XML(plistToString);
					
					for each (var j:XML in plistXML.dict.children())
					{
						if (j.contains(<key>CFBundleExecutable</key>))
						{
							// its mandatory as per plist arc that appropriate value should 
							// come after the 'key' declaration, so we assume
							// the next value is 'string' (value)
							executableFileName = plistXML.dict.children()[loopedCount+1];
							// if the plist is malformed with inappropriate ordering
							// then it won't take the plist as a valid source of 
							// information and executableFileName may have any value
							// which eventually will gets into (!File.exist) condition, next
							break;
						}
						
						loopedCount ++;
					}
					
					// release
					System.disposeXML(plistXML);
					
					// to overcome some silly mis-cnfiguration issue
					// one which came for Cyberlink where info.plist
					// mentioned with executable with wrong casing. 
					// to overcome such situation another round of
					// painful checking we've decided to take for
					// every other application validation
					var exeFolderPath:String = finalExecPath + APP_INTERNAL_PATH_TO_EXEC;
					finalExecPath += APP_INTERNAL_PATH_TO_EXEC + executableFileName;
					file = new File(finalExecPath);
					// if problem in case matching
					// in case-sensitive system
					if (!file.exists)
					{
						file = new File(exeFolderPath);
						var fileLists:Array = file.getDirectoryListing();
						for (var i:int; i < fileLists.length; i++)
						{
							if (finalExecPath.toLowerCase() == fileLists[i].nativePath.toLowerCase())
							{
								finalExecPath = fileLists[i].nativePath;
								break;
							}
						}
					}
				}
				
				// for Windows
			} else {
				
				finalExecPath = path;
			}
			
			// searching for the existing file
			file = new File(finalExecPath);
			if (file.exists)
			{
				file.canonicalize();
				return file.nativePath;
			}
			
			// unless
			return null;
		}
	}
}