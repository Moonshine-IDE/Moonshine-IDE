////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
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
// Author: Prominic.NET, Inc.
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugins.as3project.mxmlc
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.OutputProgressEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.Dictionary;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;
	import mx.resources.ResourceManager;
	
	import actionScripts.events.RefreshTreeEvent;
	import actionScripts.events.StatusBarEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.IPlugin;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.actionscript.mxmlc.CommandLine;
	import actionScripts.plugin.actionscript.mxmlc.MXMLCPluginEvent;
	import actionScripts.plugin.console.MarkupTextLineModel;
	import actionScripts.plugin.core.compiler.CompilerEventBase;
	import actionScripts.plugin.settings.ISettingsProvider;
	import actionScripts.plugin.settings.vo.BooleanSetting;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.plugins.swflauncher.event.SWFLaunchEvent;
	import actionScripts.ui.editor.text.TextLineModel;
	import actionScripts.utils.HtmlFormatter;
	import actionScripts.utils.NoSDKNotifier;
	import actionScripts.utils.OSXBookmarkerNotifiers;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.ProjectReferenceVO;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.Settings;
	
	import components.popup.SelectOpenedFlexProject;
	import components.views.project.TreeView;

    import mx.utils.StringUtil;

    public class MXMLCJavaScriptPlugin extends PluginBase implements IPlugin, ISettingsProvider
	{
		override public function get name():String			{ return "MXMLC Java Script Compiler Plugin"; }
		override public function get author():String		{ return "Miha Lunar & Moonshine Project Team"; }
		override public function get description():String	{ return ResourceManager.getInstance().getString('resources','plugin.desc.mxmlcjs'); }
		
		public var incrementalCompile:Boolean = true;
			
		private static const ASCRIPTLINESGBAUTH 				: XML = <root><![CDATA[
							#!/bin/bash
							on run argv
							do shell script "/bin/blah > /dev/null 2>&1 &"
							set userHomePath to POSIX path of (path to home folder)
							do shell script "'/usr/local/apache-flexjs/apache-flexjs-sdk-0.6.0/js/bin/mxmlc'"
						end run]]></root>

		//do shell script "xattr -d com.apple.quarantine /Users/<userName>/ApacheFlexSDK/FlexJS_0.6_AIR.21.0/js/bin/compc"
			
		private static var isQuarantined:Boolean;
		
		private var fcshPath:String = "js/bin/mxmlc";
		private var cmdFile:File;
		private var _defaultFlexSDK:String;
		
		public function get flexSDK():File
		{
			return currentSDK;
		}
		
		public function get defaultFlexSDK():String
		{
			return _defaultFlexSDK;
		}
		public function set defaultFlexSDK(value:String):void
		{
			_defaultFlexSDK = value;
			model.defaultSDK = _defaultFlexSDK ? new FileLocation(_defaultFlexSDK) : null;
			if (model.defaultSDK) model.noSDKNotifier.dispatchEvent(new Event(NoSDKNotifier.SDK_SAVED));
		}
		
		private var fcsh:NativeProcess;
		private var exiting:Boolean = false;
		private var shellInfo:NativeProcessStartupInfo;
		
		private var lastTarget:File;
		private var targets:Dictionary;
		
		private var currentSDK:File = flexSDK;
		
		/** Project currently under compilation */
		private var currentProject:ProjectVO;
		private var queue:Vector.<String> = new Vector.<String>();
		private var errors:String = "";
		
		private var cmdLine:CommandLine;
		private var fschstr:String;
		private var SDKstr:String;
		private var selectProjectPopup:SelectOpenedFlexProject;
		protected var runAfterBuild:Boolean;
		
		public function MXMLCJavaScriptPlugin() 
		{
			if (Settings.os == "win")
			{
				fcshPath += ".bat";
				cmdFile = new File("c:\\Windows\\System32\\cmd.exe");
			}
			else
			{
				//For MacOS
				cmdFile = new File("/bin/bash");
			}
			
		}
		
		override public function activate():void 
		{
			super.activate();
			
			var tempObj:Object  = new Object();
			tempObj.callback = runCommand;
			tempObj.commandDesc = "Build and run the currently selected FlexJS project.";
			registerCommand('runjs',tempObj);
			
			tempObj = new Object();
			tempObj.callback = buildCommand;
			tempObj.commandDesc = "Build the currently selected FlexJS project.";
			registerCommand('buildjs',tempObj);
			
			
			dispatcher.addEventListener(CompilerEventBase.BUILD_AND_RUN_JAVASCRIPT, buildAndRun);
			dispatcher.addEventListener(CompilerEventBase.BUILD_AS_JAVASCRIPT, build);
			cmdLine = new CommandLine();
			reset();
		}
		
		override public function deactivate():void 
		{
			super.deactivate();
			reset();
			shellInfo = null;
			cmdLine = null;
		}
		
		public function getSettingsList():Vector.<ISetting>
		{
			return Vector.<ISetting>([
				new PathSetting(this,'defaultFlexSDK', 'Default Apache Flex® or FlexJS® SDK', true,null,true),
				new BooleanSetting(this,'incrementalCompile', 'Incremental Compilation')
			])
		}
		
		private function runCommand(args:Array):void
		{
			build(null, true);
		}
		
		private function buildCommand(args:Array):void
		{
			build(null, false);
		}
		
		private function reset():void 
		{
			if(fcsh)
				fcsh.exit(true);
			fcsh = null;
			
			targets = new Dictionary();
		}
		
		private function buildAndRun(e:Event):void
		{
			build(e,true);	
		}
		
		private function build(e:Event, runAfterBuild:Boolean=false):void
		{
			this.runAfterBuild = runAfterBuild;
			checkProjectCount();
		}
		
		private function sdkSelected(event:Event):void
		{
			sdkSelectionCancelled(null);
			proceedWithBuild(currentProject);
		}
		
		private function sdkSelectionCancelled(event:Event):void
		{
			model.noSDKNotifier.removeEventListener(NoSDKNotifier.SDK_SAVED, sdkSelected);
			model.noSDKNotifier.removeEventListener(NoSDKNotifier.SDK_SAVE_CANCELLED, sdkSelectionCancelled);
		}
		
		private function checkProjectCount():void
		{
			if (model.projects.length > 1)
			{
				// check if user has selection/select any particular project or not
				if (model.mainView.isProjectViewAdded)
				{
					var tmpTreeView:TreeView = model.mainView.getTreeViewPanel();
					var projectReference:AS3ProjectVO = tmpTreeView.getProjectBySelection();
					if (projectReference)
					{
						checkForUnsavedEdior(projectReference as ProjectVO);
						return;
					}
				}
				
				// if above is false
				selectProjectPopup = new SelectOpenedFlexProject();
				selectProjectPopup.type = SelectOpenedFlexProject.TYPE_FLEXJS;
				PopUpManager.addPopUp(selectProjectPopup, FlexGlobals.topLevelApplication as DisplayObject, false);
				PopUpManager.centerPopUp(selectProjectPopup);
				selectProjectPopup.addEventListener(SelectOpenedFlexProject.PROJECT_SELECTED, onProjectSelected);
				selectProjectPopup.addEventListener(SelectOpenedFlexProject.PROJECT_SELECTION_CANCELLED, onProjectSelectionCancelled);				
			}
			else
			{
				checkForUnsavedEdior(model.projects[0] as ProjectVO);	
			}
			
			/*
			* @local
			*/
			function onProjectSelected(event:Event):void
			{
				checkForUnsavedEdior(selectProjectPopup.selectedProject);
				onProjectSelectionCancelled(null);
			}
			
			function onProjectSelectionCancelled(event:Event):void
			{
				selectProjectPopup.removeEventListener(SelectOpenedFlexProject.PROJECT_SELECTED, onProjectSelected);
				selectProjectPopup.removeEventListener(SelectOpenedFlexProject.PROJECT_SELECTION_CANCELLED, onProjectSelectionCancelled);
				selectProjectPopup = null;
			}
		}
		private function checkForUnsavedEdior(activeProject:ProjectVO):void
		{
			UtilsCore.checkForUnsavedEdior(activeProject,proceedWithBuild);
		}
		
		private function proceedWithBuild(activeProject:ProjectVO):void 
		{
			CONFIG::OSX
			{
				// before proceed, check file access dependencies
				if (!OSXBookmarkerNotifiers.checkAccessDependencies(new ArrayCollection([activeProject as AS3ProjectVO]), "Access Manager - Build Halt!")) 
				{
					Alert.show("Please fix the dependencies before build.", "Error!");
					return;
				}
			}
			
			// Don't compile if there is no project. Don't warn since other compilers might take the job.
			if (!activeProject) return;
			if (!(activeProject is AS3ProjectVO)) return;
			
			if (!fcsh || activeProject.folderLocation.fileBridge.nativePath != shellInfo.workingDirectory.nativePath 
				|| usingInvalidSDK(activeProject as AS3ProjectVO)) 
			{
				currentProject = activeProject;
				var tmpSDKLocation:Object = UtilsCore.getCurrentSDK(activeProject as AS3ProjectVO); 
				currentSDK = tmpSDKLocation ? tmpSDKLocation as File : null;
				if (!currentSDK)
				{
					model.noSDKNotifier.notifyNoFlexSDK(false);
					model.noSDKNotifier.addEventListener(NoSDKNotifier.SDK_SAVED, sdkSelected);
					model.noSDKNotifier.addEventListener(NoSDKNotifier.SDK_SAVE_CANCELLED, sdkSelectionCancelled);
					error("No FlexJS SDK found. Setup one in Settings menu.");
					return;
				}

				var fschFile:File = currentSDK.resolvePath(fcshPath);
				if (!fschFile.exists)
				{
					Alert.show("Invalid SDK - Please configure a FlexJS SDK instead","Error!");
					error("Invalid SDK - Please configure a FlexJS SDK instead");
					return;
				}
				
				var targetFile:FileLocation = compile(activeProject as AS3ProjectVO);
				if(!targetFile)
				{
					return;
				}
				if(!targetFile.fileBridge.exists)
				{
					error("Couldn't find target file");
					return;
				}
				
				var as3Pvo:AS3ProjectVO = activeProject as AS3ProjectVO;
				
				UtilsCore.checkIfFlexJSApplication(as3Pvo);
				if (as3Pvo.isFlexJS)
				{
					// FlexJS Application
					var processArgs:Vector.<String> = new Vector.<String>;
					shellInfo = new NativeProcessStartupInfo();
					fschstr = fschFile.nativePath;
					fschstr = UtilsCore.convertString(fschstr);
					SDKstr = currentSDK.nativePath;
					SDKstr = UtilsCore.convertString(SDKstr);
					
					// update build config file
					as3Pvo.updateConfig();

					processArgs = getBuildArgs(as3Pvo);

					shellInfo.arguments = processArgs;
					shellInfo.executable = cmdFile;
					shellInfo.workingDirectory = activeProject.folderLocation.fileBridge.getFile as File;
					initShell();
				}
				else
				{
					//Regular application need proper message
					Alert.show("Invalid SDK - Please configure a Flex SDK instead","Error!");
					error("Invalid SDK - Please configure a Flex SDK instead");
					return;
				}
			}
			
			debug("SDK path: %s", currentSDK.nativePath);
		}

		private function getBuildArgs(project:AS3ProjectVO):Vector.<String>
		{
            // determine if the sdk version is lower than 0.8.0 or not
            var isFlexJSAfter7:Boolean = UtilsCore.isNewerVersionSDKThan(7, currentSDK.nativePath);
            var processArgs:Vector.<String> = new Vector.<String>();

			var sdkPathHomeArg:String = "FLEX_HOME=" + SDKstr;
			var compilerPathHomeArg:String = "FALCON_HOME=" + SDKstr;
			var compilerArg:String = "&& " + fschstr;
			var configArg:String = " -load-config+=" + project.folderLocation.fileBridge.getRelativePath(project.config.file);
			var additionalBuildArgs:String = project.buildOptions.getArguments();
			additionalBuildArgs = " " + additionalBuildArgs.replace("-optimize=false", "");

			var jsCompilationArg:String = "";
			if (isFlexJSAfter7)
			{
                jsCompilationArg = " -compiler.targets=JSFlex";
				
                if (project.isRoyale)
                {
                    jsCompilationArg = " -compiler.targets=JSRoyale";
					sdkPathHomeArg = "ROYALE_HOME=" + SDKstr;
					compilerPathHomeArg = "ROYALE_COMPILER_HOME=" + SDKstr;
                }
			}

            if(Settings.os == "win")
            {
                processArgs.push("/c");
                processArgs.push("set ".concat(
						sdkPathHomeArg, "&& set ", compilerPathHomeArg, compilerArg, configArg, additionalBuildArgs, jsCompilationArg
				));
            }
            else
            {
                processArgs.push("-c");
                processArgs.push("export ".concat(
                        sdkPathHomeArg, " && export ", compilerPathHomeArg, compilerArg, configArg, additionalBuildArgs, jsCompilationArg
                ));
            }

			return processArgs;
		}

		private function clearConsoleBeforeRun():void
		{
			if (ConstantsCoreVO.IS_CONSOLE_CLEARED_ONCE) clearOutput();
			ConstantsCoreVO.IS_CONSOLE_CLEARED_ONCE = true;
		}
		
		private function quarantineExecutables(value:AS3ProjectVO, filePathToQuarantine:String):void
		{
			/*var processArgs:Vector.<String> = new Vector.<String>;
			shellInfo = new NativeProcessStartupInfo();
			
			// @call 1
			processArgs.push( "-c" );
			processArgs.push( "chmod +x "+ filePathToQuarantine);
			shellInfo.arguments = processArgs;
			shellInfo.executable = cmdFile;
			
			debug("Quarantine path: %s", filePathToQuarantine);
			initShell();
			isQuarantined = true;
			
			setTimeout(proceedWithBuild, 1000, value);*/
			
			isQuarantined = true;
			holdProject = value;
			var tmpScript : String = ASCRIPTLINESGBAUTH;
			
			// starts writing .scpt file
			file = File.applicationStorageDirectory.resolvePath( "spawn/linker2.scpt" );
			if (file.exists)
			{
				onGBAWriteFileCompleted(null);
				return;
			}
			
			
			fs = new FileStream();
			fs.addEventListener(IOErrorEvent.IO_ERROR, handleFSError );
			fs.addEventListener(Event.CLOSE, onFileStreamCompletes );
			fs.addEventListener(OutputProgressEvent.OUTPUT_PROGRESS, onGBAWriteFileCompleted );
			fs.openAsync(file, FileMode.WRITE);
			fs.writeUTFBytes( tmpScript );
		}
		
		private var file:File;
		private var fs:FileStream;
		private var holdProject:AS3ProjectVO;
		
		/**
		 * In the process of copying GBAuth file systems
		 * from AIR 2.0 old location to AIR 16.0
		 * new location, starts the NativeProcess
		 */
		private function onGBAWriteFileCompleted( event:OutputProgressEvent ) : void
		{
			// only when writing completes
			if (!event || event.bytesPending == 0)
			{
				if (event) 
				{
					event.target.close();
					onFileStreamCompletes(null);
				}
				
				// declare necessary arguments
				file = File.applicationDirectory.resolvePath("appScripts/TestMXMLCall.scpt");
				shellInfo = new NativeProcessStartupInfo();
				var arg:Vector.<String>;
				
				shellInfo.executable = File.documentsDirectory.resolvePath( "/usr/bin/osascript" );
				arg = new Vector.<String>();
				arg.push( file.nativePath );
				
				// triggers the process
				shellInfo.arguments = arg;
				
				initShell();
				//setTimeout(proceedWithBuild, 2000, holdProject);
			}
		}
		
		/**
		 * On file stream error
		 */
		protected function handleFSError( event:IOErrorEvent ) : void 
		{	
			Alert.show(event.text);
			fs.removeEventListener( IOErrorEvent.IO_ERROR, handleFSError );
			fs.removeEventListener( Event.CLOSE, onFileStreamCompletes );
			fs.removeEventListener( OutputProgressEvent.OUTPUT_PROGRESS, onGBAWriteFileCompleted );
		}
		
		/**
		 * When stream closed/completes
		 */
		protected function onFileStreamCompletes( event:Event ) : void
		{	
			fs.removeEventListener( IOErrorEvent.IO_ERROR, handleFSError );
			fs.removeEventListener( Event.CLOSE, onFileStreamCompletes );
			fs.removeEventListener( OutputProgressEvent.OUTPUT_PROGRESS, onGBAWriteFileCompleted );
		}
		
		/**
		 * @return True if the current SDK matches the project SDK, false otherwise
		 */
		private function usingInvalidSDK(pvo:AS3ProjectVO):Boolean 
		{
			var customSDK:File = pvo.buildOptions.customSDK.fileBridge.getFile as File;
			if ((customSDK && (currentSDK.nativePath != customSDK.nativePath))
				|| (!customSDK && currentSDK.nativePath != flexSDK.nativePath)) 
			{
				return true;
			}
			
			return false;
		}
		
		private function compile(pvo:AS3ProjectVO):FileLocation 
		{
			clearConsoleBeforeRun();
			dispatcher.dispatchEvent(new MXMLCPluginEvent(CompilerEventBase.PREBUILD, new FileLocation(currentSDK.nativePath)));
			print("Compiling "+pvo.projectName);
			
			currentProject = pvo;
			if (pvo.targets.length == 0) 
			{
				error("No targets found for compilation.");
				return null;
			}
			var file:FileLocation = pvo.targets[0];
			if(file.fileBridge.exists)
			{
				return file;
			}
			return null;
		}
		
		private function send(msg:String):void 
		{
			debug("Sending to mxmlx: %s", msg);
			if (!fcsh) {
				queue.push(msg);
			} else {
				var input:IDataOutput = fcsh.standardInput;
				input.writeUTFBytes(msg+"\n");
			}
		}
		
		private function flush():void 
		{
			if (queue.length == 0) return;
			if (fcsh) {
				for (var i:int = 0; i < queue.length; i++) {
					send(queue[i]);
				}
				queue.length = 0;
			}
		}
		
		private function initShell():void 
		{
			if (fcsh) {
				fcsh.exit();
				exiting = true;
				reset();
			} else {
				startShell();
			}
		}
		
		private function startShell():void 
		{
			// stop running debug process for run/build if debug process in running
			fcsh = new NativeProcess();
			fcsh.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);
			fcsh.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
			fcsh.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR,shellError);
			fcsh.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR,shellError);
			fcsh.addEventListener(NativeProcessExitEvent.EXIT, shellExit);
			fcsh.start(shellInfo);
			
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, currentProject.projectName, runAfterBuild ? "Launching " : "Building "));
			dispatcher.addEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onTerminateBuildRequest);
			flush();
		}
		
		private function onTerminateBuildRequest(event:StatusBarEvent):void
		{
			if (fcsh && fcsh.running)
			{
				fcsh.exit(true);
			}
		}
		
		private function shellData(e:ProgressEvent):void 
		{
			if(fcsh)
			{
				var output:IDataInput = fcsh.standardOutput;
				var data:String = output.readUTFBytes(output.bytesAvailable);
				
				var match:Array;
				match = data.match(/successfully compiled and optimized/);
				if (match) 
				{
					// @ note
					// @ devsena
					// while working on MOON#311 (create new project with existing source)
					// I noticed that FlexJS compiler produce it's 'bin' folder to first
					// folder of the source path. Thus if a source file exists at
					// <projectRoot>/src/subA/subB/JSApplication.mxml, the 'bin' folder produces at
					// <projectRoot>/src. I also noticed if the source folder name do not starts with 'src'
					// this problem also arise. Ideally the 'bin' folder was supposed to create at
					// <projectRoot>. 
					// Following folder move will fix this problem
					
					// source location
					var sourcePath:String = currentProject.folderLocation.fileBridge.getRelativePath((currentProject as AS3ProjectVO).classpaths[0]);
					var sourcePathSplit:Array = sourcePath.split("/");
					var sourceFolder:FileLocation = (currentProject as AS3ProjectVO).classpaths[0].fileBridge.parent;
					if (sourcePathSplit[0] != "src" || sourceFolder.fileBridge.nativePath != (currentProject as AS3ProjectVO).folderLocation.fileBridge.nativePath)
					{
						sourceFolder = currentProject.folderLocation.fileBridge.resolvePath(sourcePathSplit[0] + "/bin");
						if (sourceFolder.fileBridge.exists)
						{
							sourceFolder.fileBridge.getFile.addEventListener(Event.COMPLETE, onBinFolderMoveComplete);
							sourceFolder.fileBridge.moveToAsync((currentProject as AS3ProjectVO).folderLocation.resolvePath("bin"), true);
						}
						else
						{
							sourceFolder = currentProject.folderLocation.fileBridge.resolvePath("bin");
							if (sourceFolder.fileBridge.exists) onBinFolderMoveComplete(null);
						}
					}
					else
						onBinFolderMoveComplete(null);
					
					/*
					 *@local
					 */
					function onBinFolderMoveComplete(event:Event):void
					{
						if (event) event.target.removeEventListener(Event.COMPLETE, onBinFolderMoveComplete);
						
						print("Project Build Successfully");
						dispatcher.dispatchEvent(new RefreshTreeEvent((currentProject as AS3ProjectVO).folderLocation.resolvePath("bin")));
					    if(runAfterBuild)
					    {
							testMovie();
					    }
						else if (AS3ProjectVO(currentProject).resourcePaths.length != 0)
						{
							var swfFile:File = currentProject.folderLocation.resolvePath(AS3ProjectVO.FLEXJS_DEBUG_PATH).fileBridge.getFile as File;
							resourceCopiedIndex = 0;
							getResourceCopied(currentProject as AS3ProjectVO, swfFile);
						}
						reset();	
					}
				}
				
				
				if (errors != "") 
				{
					compilerError(errors);
					targets = new Dictionary();
					errors = "";
				}
				
				
				if (data.charAt(data.length-1) == "\n") data = data.substr(0, data.length-1);
				
				debug("%s", data);
			}
		}
		
		
		private function testMovie():void 
		{
			var pvo:AS3ProjectVO = currentProject as AS3ProjectVO;
			var swfFile:File = currentProject.folderLocation.resolvePath(AS3ProjectVO.FLEXJS_DEBUG_PATH).fileBridge.getFile as File;
			
			// before test movie lets copy the resource folder(s)
			// to debug folder if any
			if (pvo.resourcePaths.length != 0 && resourceCopiedIndex == 0)
			{
				getResourceCopied(pvo, swfFile);
				return;
			}
			else
			{
				resourceCopiedIndex = 0;
			}
			
			if (pvo.testMovie == AS3ProjectVO.TEST_MOVIE_CUSTOM) 
			{
				var customSplit:Vector.<String> = Vector.<String>(pvo.testMovieCommand.split(";"));
				var customFile:String = customSplit[0];
				var customArgs:String = customSplit.slice(1).join(" ").replace("$(ProjectName)", pvo.projectName).replace("$(CompilerPath)", currentSDK.nativePath);
				
				cmdLine.write(customFile+" "+customArgs, pvo.folderLocation);
			}
			else if (pvo.testMovie == AS3ProjectVO.TEST_MOVIE_AIR)
			{
				// Let SWFLauncher deal with playin' the swf
				dispatcher.dispatchEvent(
					new SWFLaunchEvent(SWFLaunchEvent.EVENT_LAUNCH_SWF, swfFile, pvo, currentSDK)
				);
			} 
			else 
			{
				if (!pvo.htmlPath) pvo.getHTMLPath;
				// Let SWFLauncher deal with playin' the swf
				dispatcher.dispatchEvent(
					new SWFLaunchEvent(SWFLaunchEvent.EVENT_LAUNCH_SWF, pvo.htmlPath.fileBridge.getFile as File, pvo)
				);
			}
			currentProject = null;
			//deactivate();
		}
		
		private var resourceCopiedIndex:int;
		private function getResourceCopied(pvo:AS3ProjectVO, swfFile:File):void
		{
			var debugDestination:File = swfFile.parent;
			var fl:FileLocation = pvo.resourcePaths[resourceCopiedIndex];
			(fl.fileBridge.getFile as File).addEventListener(Event.COMPLETE, onFileCopiedHandler, false, 0, true);
			
			// copying to bin/bin-debug
			(fl.fileBridge.getFile as File).copyToAsync(debugDestination.resolvePath(fl.fileBridge.name), true);
			
			/*
			 * @local
			 */
			function onFileCopiedHandler(event:Event):void
			{
				resourceCopiedIndex++;
				event.target.removeEventListener(Event.COMPLETE, onFileCopiedHandler);
				
				// copying to bin/bin-release
				var releaseDestination:File = pvo.folderLocation.resolvePath(AS3ProjectVO.FLEXJS_RELEASE_PATH).fileBridge.getFile as File;
				(fl.fileBridge.getFile as File).copyToAsync(releaseDestination.resolvePath(fl.fileBridge.name), true);
				
				if (resourceCopiedIndex < pvo.resourcePaths.length) getResourceCopied(pvo, swfFile);
				else if (runAfterBuild) 
				{
					dispatcher.dispatchEvent(new RefreshTreeEvent(pvo.folderLocation.resolvePath("bin")));
					testMovie();
				}
				else
				{
					dispatcher.dispatchEvent(new RefreshTreeEvent(pvo.folderLocation.resolvePath("bin")));
				}
			}
		}
		
		private function shellError(e:ProgressEvent):void 
		{
			if(fcsh)
			{
				var output:IDataInput = fcsh.standardError;
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
					pathStr = pathStr.substr(pathStr.lastIndexOf("/")+1);
					errors += HtmlFormatter.sprintf("%s<weak>:</weak>%s \t %s\n",
						pathStr, lineNum, errorStr); 
				}
				
				generalMatch = data.match(/(.*?): Error: (.*).*/);
				if (!syntaxMatch && generalMatch)
				{ 
					pathStr = generalMatch[1];
					errorStr  = generalMatch[2];
					pathStr = pathStr.substr(pathStr.lastIndexOf("/")+1);
					
					errors += HtmlFormatter.sprintf("%s: %s", pathStr, errorStr);
				}
				
				debug("%s", data);
				print(data);
			}
			targets = new Dictionary();
		}
		
		private function shellExit(e:NativeProcessExitEvent):void 
		{
			//debug("MXMLC exit code: %s", e.exitCode);
			reset();
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
			dispatcher.removeEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onTerminateBuildRequest);
			if (exiting) {
				exiting = false;
				startShell();
			}
		}
		
		protected function compilerWarning(...msg):void 
		{
			var text:String = msg.join(" ");
			var textLines:Array = text.split("\n");
			var lines:Vector.<TextLineModel> = Vector.<TextLineModel>([]);
			for (var i:int = 0; i < textLines.length; i++)
			{
				if (textLines[i] == "") continue;
				text = "<warning> ⚠  </warning>" + textLines[i]; 
				var lineModel:TextLineModel = new MarkupTextLineModel(text);
				lines.push(lineModel);
			}
			outputMsg(lines);
		}
		
		protected function compilerError(...msg):void 
		{
			var text:String = msg.join(" ");
			var textLines:Array = text.split("\n");
			var lines:Vector.<TextLineModel> = Vector.<TextLineModel>([]);
			for (var i:int = 0; i < textLines.length; i++)
			{
				if (textLines[i] == "") continue;
				text = "<error> ⚡  </error>" + textLines[i]; 
				var lineModel:TextLineModel = new MarkupTextLineModel(text);
				lines.push(lineModel);
			}
			outputMsg(lines);
			targets = new Dictionary();
		}
		
	}
}