////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugins.as3project.mxmlc
{
	import com.adobe.utils.StringUtil;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.OutputProgressEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;
	import mx.resources.ResourceManager;
	
	import actionScripts.events.RefreshTreeEvent;
	import actionScripts.events.StatusBarEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.HelperModel;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.actionscript.mxmlc.MXMLCPluginEvent;
	import actionScripts.plugin.console.ConsoleEvent;
	import actionScripts.plugin.console.ConsoleOutputEvent;
	import actionScripts.plugin.core.compiler.ActionScriptBuildEvent;
	import actionScripts.plugin.core.compiler.JavaScriptBuildEvent;
	import actionScripts.plugin.settings.ISettingsProvider;
	import actionScripts.plugin.settings.vo.BooleanSetting;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.plugins.build.CompilerPluginBase;
	import actionScripts.plugins.debugAdapter.events.DebugAdapterEvent;
	import actionScripts.plugins.httpServer.events.HttpServerEvent;
	import actionScripts.plugins.swflauncher.event.SWFLaunchEvent;
	import actionScripts.utils.EnvironmentSetupUtils;
	import actionScripts.utils.NoSDKNotifier;
	import actionScripts.utils.OSXBookmarkerNotifiers;
	import actionScripts.utils.SDKUtils;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.EnvironmentUtilsCusomSDKsVO;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.SDKReferenceVO;
	import actionScripts.valueObjects.Settings;
	import actionScripts.valueObjects.WebBrowserVO;
	
	import components.popup.SelectOpenedProject;
	
	import flashx.textLayout.elements.LinkElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.formats.TextDecoration;
	import flash.utils.clearTimeout;
	import actionScripts.ui.project.ProjectTreeView;

    public class MXMLCJavaScriptPlugin extends MXMLCPluginBase implements ISettingsProvider
	{
		private static const DEBUG_SERVER_PORT:int = 3000;

		override public function get name():String			{ return "MXMLC Java Script Compiler Plugin"; }
		override public function get author():String		{ return "Miha Lunar & Moonshine Project Team"; }
		override public function get description():String	{ return ResourceManager.getInstance().getString('resources','plugin.desc.mxmlcjs'); }
		
		public var incrementalCompile:Boolean = true;

		private var fcshPath:String = "js/bin/mxmlc";
		private var cmdFile:File;
		private var _defaultFlexSDK:String;

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

		private var currentSDK:File;
		
		/** Project currently under compilation */
		private var currentProject:ProjectVO;
		private var queue:Vector.<String> = new Vector.<String>();

		private var fschstr:String;
		private var SDKstr:String;
		private var selectProjectPopup:SelectOpenedProject;
		protected var runAfterBuild:Boolean;
		protected var debugAfterBuild:Boolean;
		protected var release:Boolean;

		private var successMessage:String;
		private var isProjectHasInvalidPaths:Boolean;

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
			tempObj.commandDesc = "Build and run the currently selected Apache Royale® project.";
			registerCommand('runjs',tempObj);
			
			tempObj = new Object();
			tempObj.callback = buildCommand;
			tempObj.commandDesc = "Build the currently selected Apache Royale® project.";
			registerCommand('buildjs',tempObj);
			
			
			dispatcher.addEventListener(JavaScriptBuildEvent.BUILD_AND_RUN, buildAndRun);
			dispatcher.addEventListener(JavaScriptBuildEvent.BUILD_AND_DEBUG, buildAndDebug);
			dispatcher.addEventListener(JavaScriptBuildEvent.BUILD, buildDebug);
			dispatcher.addEventListener(JavaScriptBuildEvent.BUILD_RELEASE, buildRelease);
			dispatcher.addEventListener(JavaScriptBuildEvent.CLEAN, clean);
			reset();
		}
		
		override public function deactivate():void 
		{
			super.deactivate();

			dispatcher.removeEventListener(JavaScriptBuildEvent.BUILD_AND_RUN, buildAndRun);
			dispatcher.removeEventListener(JavaScriptBuildEvent.BUILD_AND_DEBUG, buildAndDebug);
			dispatcher.removeEventListener(JavaScriptBuildEvent.BUILD, buildDebug);
			dispatcher.removeEventListener(JavaScriptBuildEvent.BUILD_RELEASE, buildRelease);

			reset();
			shellInfo = null;
		}
		
		override protected function onProjectPathsValidated(paths:Array):void
		{
			if (paths)
			{
				isProjectHasInvalidPaths = true;
				error("Following path(s) are invalid or does not exists:\n"+ paths.join("\n"));
			}
		}
		
		public function getSettingsList():Vector.<ISetting>
		{
			return Vector.<ISetting>([
				new PathSetting(this,'defaultFlexSDK', 'Default Apache Flex®, Apache Royale® or Feathers SDK', true,null,true),
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
			stopShell();
			successMessage = null;
		}
		
		private function buildAndRun(e:Event):void
		{
			release = false;
			build(e, false, true);
		}

		private function buildAndDebug(e:Event):void
		{
			build(e, false, true, true)
		}
		
		private function buildDebug(e:Event):void
		{
			build(e);
		}
		
		private function buildRelease(e:Event):void
		{
			build(e, true);
		}

		private function clean(e:Event):void
		{
			var as3Project:AS3ProjectVO = model.activeProject as AS3ProjectVO;
			if (!as3Project)
			{
				return;
			}

            dispatcher.dispatchEvent(new ConsoleEvent(ConsoleEvent.SHOW_CONSOLE));

			var outputFile:FileLocation;
			var swfPath:FileLocation;
			var swfFolderPath:FileLocation;
			var folderCount:int = 0;
			var currentTargets:Array = [];

			if (as3Project.swfOutput.path)
			{
				outputFile = as3Project.swfOutput.path;
				swfFolderPath = outputFile.fileBridge.parent;
			}

			if (swfFolderPath.fileBridge.exists)
			{
				var directoryItems:Array = swfFolderPath.fileBridge.getDirectoryListing();
				for each (var directory:Object in directoryItems)
				{
					folderCount++;
					currentTargets.push(swfFolderPath);

					directory.addEventListener(IOErrorEvent.IO_ERROR, onCleanProjectIOException);
					directory.addEventListener(Event.COMPLETE, onProjectFolderComplete);

					if (directory.isDirectory)
					{
						directory.deleteDirectoryAsync(true);
					}
					else
					{
						directory.deleteFileAsync();
					}
				}
			}

			if (as3Project.isFlexJS || as3Project.isRoyale)
			{
				var binFolder:FileLocation = as3Project.folderLocation.resolvePath(as3Project.jsOutputPath).resolvePath("bin");
				if (!binFolder.fileBridge.exists)
				{
					binFolder = as3Project.folderLocation.fileBridge.resolvePath("bin");
				}

				if (binFolder.fileBridge.exists)
				{
					var timeoutValue:uint = setTimeout(function():void
					{
						var jsDebugFolder:FileLocation = binFolder.resolvePath("js-debug");
						var jsDebugFolderExists:Boolean = jsDebugFolder.fileBridge.exists;
						if (jsDebugFolderExists)
						{
							folderCount++;
							currentTargets.push(jsDebugFolder);
						}

						var jsReleaseFolder:FileLocation = binFolder.resolvePath("js-release");
						var jsReleaseFolderExists:Boolean = jsReleaseFolder.fileBridge.exists;
						if (jsReleaseFolderExists)
						{
							folderCount++;
							currentTargets.push(jsReleaseFolder);
						}

						if (jsDebugFolderExists)
						{
							jsDebugFolder.fileBridge.getFile.addEventListener(IOErrorEvent.IO_ERROR, onCleanProjectIOException);
							jsDebugFolder.fileBridge.getFile.addEventListener(Event.COMPLETE, onProjectFolderComplete);
							jsDebugFolder.fileBridge.deleteDirectoryAsync(true);
						}

						if (jsReleaseFolderExists)
						{
							jsReleaseFolder.fileBridge.getFile.addEventListener(IOErrorEvent.IO_ERROR, onCleanProjectIOException);
							jsReleaseFolder.fileBridge.getFile.addEventListener(Event.COMPLETE, onProjectFolderComplete);
							jsReleaseFolder.fileBridge.deleteDirectoryAsync(true);
						}

						if (folderCount == 0)
						{
							success("JavaScript project files cleaned successfully: " + as3Project.name);
						}

						clearTimeout(timeoutValue);
					}, 300);
				}
				else if ((!swfPath || !swfPath.fileBridge.exists) && !binFolder.fileBridge.exists)
				{
					success("Project files cleaned successfully: " + as3Project.name);
				}
			}

			function onProjectFolderComplete(event:Event):void
			{
				event.target.removeEventListener(Event.COMPLETE, onProjectFolderComplete);
				event.target.removeEventListener(IOErrorEvent.IO_ERROR, onCleanProjectIOException);

				if (currentTargets)
				{
					folderCount--;
					if (folderCount <= 0)
					{
						for (var i:int = 0; i < currentTargets.length; i++)
						{
							dispatcher.dispatchEvent(new RefreshTreeEvent(currentTargets[i], true));
						}

						success("Project files cleaned successfully: " + as3Project.name);
						currentTargets = null;
						folderCount = 0;
					}
				}
			}

			function onCleanProjectIOException(event:IOErrorEvent):void
			{
				event.target.removeEventListener(IOErrorEvent.IO_ERROR, onCleanProjectIOException);
				error("Cannot delete file or folder: " + event.target.nativePath + "\nError: " + event.text);
			}
		}
		
		private function build(e:Event, release:Boolean=false, runAfterBuild:Boolean=false, debugAfterBuild:Boolean=false):void
		{
			this.isProjectHasInvalidPaths = false;
			this.release = release;
			this.runAfterBuild = runAfterBuild;
			this.debugAfterBuild = debugAfterBuild;
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
			var filteredProjects:Array = model.projects.source.filter(function(project:ProjectVO, index:int, source:Array):Boolean
			{
				if(!(project is AS3ProjectVO))
				{
					return false;
				}
				var as3Project:AS3ProjectVO = AS3ProjectVO(project);
				return as3Project.isRoyale && as3Project.buildOptions.targetPlatform == "JS";
			});
			if (filteredProjects.length > 1)
			{
				// check if user has selection/select any particular project or not
				if (model.mainView.isProjectViewAdded)
				{
					var tmpTreeView:ProjectTreeView = model.mainView.getTreeViewPanel();
					if(tmpTreeView) //might be null if closed by user
					{
						var projectReference:ProjectVO = tmpTreeView.getProjectBySelection();
						if (projectReference && filteredProjects.indexOf(projectReference) != -1)
						{
							checkForUnsavedEdior(projectReference);
							return;
						}
					}
				}
				
				// if above is false
				selectProjectPopup = new SelectOpenedProject();
				selectProjectPopup.projects = new ArrayCollection(filteredProjects);
				PopUpManager.addPopUp(selectProjectPopup, FlexGlobals.topLevelApplication as DisplayObject, false);
				PopUpManager.centerPopUp(selectProjectPopup);
				selectProjectPopup.addEventListener(SelectOpenedProject.PROJECT_SELECTED, onProjectSelected);
				selectProjectPopup.addEventListener(SelectOpenedProject.PROJECT_SELECTION_CANCELLED, onProjectSelectionCancelled);				
			}
			else if(filteredProjects.length != 0)
			{
				checkForUnsavedEdior(filteredProjects[0] as ProjectVO);	
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
				selectProjectPopup.removeEventListener(SelectOpenedProject.PROJECT_SELECTED, onProjectSelected);
				selectProjectPopup.removeEventListener(SelectOpenedProject.PROJECT_SELECTION_CANCELLED, onProjectSelectionCancelled);
				selectProjectPopup = null;
			}
		}
		private function checkForUnsavedEdior(activeProject:ProjectVO):void
		{
			model.activeProject = activeProject;
			UtilsCore.closeAllRelativeEditors(activeProject, false, proceedWithBuild, false);
			//UtilsCore.checkForUnsavedEdior(activeProject,proceedWithBuild);
		}
		
		private function proceedWithBuild(activeProject:ProjectVO=null):void 
		{
			// Don't compile if there is no project. Don't warn since other compilers might take the job.
			if (!activeProject) activeProject = model.activeProject;
			if (!activeProject || !(activeProject is AS3ProjectVO)) return;
			if (AS3ProjectVO(activeProject).isLibraryProject)
			{
				Alert.show("Use 'Build' instead to build library project.", "Error!");
				return;
			}
			
			checkProjectForInvalidPaths(activeProject); 
			if (isProjectHasInvalidPaths)
			{
				return;
			}
			
			reset();

            dispatcher.dispatchEvent(new ConsoleEvent(ConsoleEvent.SHOW_CONSOLE));
			
			CONFIG::OSX
			{
				// before proceed, check file access dependencies
				if (!OSXBookmarkerNotifiers.checkAccessDependencies(new ArrayCollection([activeProject as AS3ProjectVO]), "Access Manager - Build Halt!")) 
				{
					Alert.show("Please fix the dependencies before build.", "Error!");
					return;
				}
			}
			
			var compileStr:String;
			
			if (!fcsh || activeProject.folderLocation.fileBridge.nativePath != shellInfo.workingDirectory.nativePath 
				|| usingInvalidSDK(activeProject as AS3ProjectVO)) 
			{
				currentProject = activeProject;
				var tempCurrentSDK:FileLocation = UtilsCore.getCurrentSDK(activeProject as AS3ProjectVO);
				var sdkReference:SDKReferenceVO = SDKUtils.getSDKReference(tempCurrentSDK);

				currentSDK = null;
				if (!tempCurrentSDK)
				{
					model.noSDKNotifier.notifyNoFlexSDK(false);
					model.noSDKNotifier.addEventListener(NoSDKNotifier.SDK_SAVED, sdkSelected);
					model.noSDKNotifier.addEventListener(NoSDKNotifier.SDK_SAVE_CANCELLED, sdkSelectionCancelled);
					error("No Apache Royale® SDK found. Setup one in Settings menu.");
					return;
				}

				currentSDK = tempCurrentSDK.fileBridge.getFile as File;
				var fschFile:File = currentSDK.resolvePath(fcshPath);
				if (!fschFile.exists)
				{
					Alert.show("Invalid SDK - Please configure a Apache Royale® SDK instead","Error!");
					error("Invalid SDK - Please configure a Apache Royale® SDK instead");
					return;
				}

				if (!sdkReference.hasPlayerglobal && !HelperModel.getInstance().moonshineBridge.playerglobalExists && !sdkReference.isJSOnlySdk)
				{
					displayPlayerGlobalError(sdkReference);
					return;
				}

				var targetFile:FileLocation = compile(activeProject as AS3ProjectVO);
				if(!targetFile || !targetFile.fileBridge.exists)
				{
					error("Main application file or target file does not exists.");
					return;
				}
				
				var as3Pvo:AS3ProjectVO = activeProject as AS3ProjectVO;
				
				UtilsCore.checkIfRoyaleApplication(as3Pvo);
				if (as3Pvo.isFlexJS || as3Pvo.isRoyale)
				{
					// FlexJS Application
					shellInfo = new NativeProcessStartupInfo();
					fschstr = fschFile.nativePath;
					//fschstr = UtilsCore.convertString(fschstr);
					SDKstr = currentSDK.nativePath;
					//SDKstr = UtilsCore.convertString(SDKstr);
					
					// update build config file
					as3Pvo.updateConfig();

					compileStr = getBuildArgs(as3Pvo);
					
					var envCustomSDK:EnvironmentUtilsCusomSDKsVO = new EnvironmentUtilsCusomSDKsVO();
					envCustomSDK.sdkPath = SDKstr;
					EnvironmentSetupUtils.getInstance().initCommandGenerationToSetLocalEnvironment(onEnvironmentPrepared, envCustomSDK, [compileStr]);
				}
				else
				{
					//Regular application need proper message
					Alert.show("Invalid SDK - Please configure a Flex SDK instead","Error!");
					error("Invalid SDK - Please configure a Flex SDK instead");
					return;
				}
			}
			
			/*
			* @local
			*/
			function onEnvironmentPrepared(value:String):void
			{
				var processArgs:Vector.<String> = new Vector.<String>;
				shellInfo = new NativeProcessStartupInfo();
				if (Settings.os == "win")
				{
					processArgs.push("/c");
					processArgs.push(value);
				}
				else
				{
					processArgs.push("-c");
					processArgs.push(value);
				}
				
				//var workingDirectory:File = currentSDK.resolvePath("bin/");
				shellInfo.arguments = processArgs;
				shellInfo.executable = cmdFile;
				shellInfo.workingDirectory = activeProject.folderLocation.fileBridge.getFile as File;
				
				initShell();
				
				if (ConstantsCoreVO.IS_MACOS)
				{
					debug("SDK path: %s", currentSDK.nativePath);
					send(compileStr);
				}
			}
		}

		private function getBuildArgs(project:AS3ProjectVO):String
		{
			var compileStr:String = "";
			
            // determine if the sdk version is lower than 0.8.0 or not
            var isFlexJSAfter7:Boolean = UtilsCore.isNewerVersionSDKThan(7, currentSDK.nativePath);

			var sdkPathHomeArg:String;
			var enLanguageArg:String = "SETUP_SH_VMARGS=\"-Duser.language=en -Duser.region=en\"";
			var compilerPathHomeArg:String = "FALCON_HOME=".concat('"', SDKstr, '"');
			var compilerArg:String = "&& ".concat('"', fschstr, '"');
			var configArg:String = " -load-config+=".concat('"', project.folderLocation.fileBridge.getRelativePath(project.config.file), '"');
			var additionalBuildArgs:String = project.buildOptions.getArguments();
			additionalBuildArgs = " " + additionalBuildArgs.replace("-optimize=false", "");
				
			var dbg:String;
			if (release)
			{
				dbg = " -debug=false";
			}
			else
			{
				dbg = " -debug=true";
			}
			if (additionalBuildArgs.indexOf(" -debug=") > -1)
			{
				dbg = "";
			}

			var jsCompilationArg:String = "";
			if (isFlexJSAfter7)
			{
                jsCompilationArg = " -compiler.targets=JSFlex";
				
                if (project.isRoyale)
                {
                    jsCompilationArg = " -compiler.targets=JSRoyale";
					sdkPathHomeArg = "ROYALE_HOME=".concat('"', SDKstr, '"');
					compilerPathHomeArg = "";
                }

				jsCompilationArg += " -js-output=".concat('"', project.jsOutputPath, '"');
			}

            if(Settings.os == "win")
            {
				compileStr = compileStr.concat(
					sdkPathHomeArg ? ("set "+ sdkPathHomeArg)+"&& " : '', "set ", compilerPathHomeArg, compilerArg, configArg, dbg, additionalBuildArgs, jsCompilationArg
				);
            }
            else
            {
				var royaleLibPath:String = "royalelib=".concat('"', SDKstr, File.separator, "frameworks", '"');
				compileStr = compileStr.concat(
						sdkPathHomeArg ? ("export " + " " + royaleLibPath + " "  + sdkPathHomeArg)+" && " : '', "export ", royaleLibPath, " ", enLanguageArg, " && export ", compilerPathHomeArg, compilerArg, configArg, dbg, additionalBuildArgs, jsCompilationArg
				);
            }

			return compileStr;
		}

		private function clearConsoleBeforeRun():void
		{
			if (ConstantsCoreVO.IS_CONSOLE_CLEARED_ONCE) clearOutput();
			ConstantsCoreVO.IS_CONSOLE_CLEARED_ONCE = true;
		}

		private var file:File;
		private var fs:FileStream;
		
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
				file = File.applicationDirectory.resolvePath("macOScripts/TestMXMLCall.scpt");
				shellInfo = new NativeProcessStartupInfo();
				var arg:Vector.<String>;
				
				shellInfo.executable = File.documentsDirectory.resolvePath( "/usr/bin/osascript" );
				arg = new Vector.<String>();
				arg.push( file.nativePath );
				
				// triggers the process
				shellInfo.arguments = arg;
				
				initShell();
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
			if (customSDK && (currentSDK.nativePath != customSDK.nativePath))
			{
				return true;
			}
			
			return false;
		}
		
		private function compile(pvo:AS3ProjectVO):FileLocation 
		{
			clearConsoleBeforeRun();
			dispatcher.dispatchEvent(new MXMLCPluginEvent(ActionScriptBuildEvent.PREBUILD, new FileLocation(currentSDK.nativePath)));
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
			if (fcsh)
			{
				fcsh.exit();
				exiting = true;
				reset();
			}
			else
			{
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
			
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED,
					currentProject.projectName,
					runAfterBuild ? "Launching " : "Building "));
			dispatcher.addEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onTerminateBuildRequest);
			flush();
		}

        private function stopShell():void
        {
            if (!fcsh) return;
            if (fcsh.running)
			{
				fcsh.exit();
            }
        }

		private function cleanUpShell():void
		{
			if (!fcsh) return;

			fcsh.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);
			fcsh.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
			fcsh.removeEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR,shellError);
			fcsh.removeEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR,shellError);
			fcsh.removeEventListener(NativeProcessExitEvent.EXIT, shellExit);
			fcsh = null;
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

				printBuildProgress(data);
			}
		}
		
		private function onSuccesfullBuildCompleted(event:Event):void
		{
            if (event)
			{
				event.target.removeEventListener(Event.COMPLETE, onSuccesfullBuildCompleted);
            }

			var as3Project:AS3ProjectVO = AS3ProjectVO(currentProject);
            dispatcher.dispatchEvent(new RefreshTreeEvent(new FileLocation(as3Project.jsOutputPath).resolvePath("bin")));
			copyingResources();
        }

		private function getWebRoot(project:AS3ProjectVO):FileLocation
		{
            return new FileLocation(project.jsOutputPath).resolvePath("bin" + File.separator + "js-debug");
		}

        private function startDebugAdapter(project:AS3ProjectVO, debug:Boolean):void
        {
			var url:String = getUrlToLaunch(project);
			notice("Opening to URL: "+ url); 

			var debugAdapterType:String = null;
			for(var i:int = 0; i < ConstantsCoreVO.TEMPLATES_WEB_BROWSERS.length; i++)
			{
				var webBrowser:WebBrowserVO = WebBrowserVO(ConstantsCoreVO.TEMPLATES_WEB_BROWSERS.getItemAt(i));
				if(webBrowser.name == project.runWebBrowser)
				{
					debugAdapterType = webBrowser.debugAdapterType;
				}
			}
			if(debugAdapterType == null)
			{
				debugAdapterType = "chrome";
			}

            var debugCommand:String = "launch";
            var launchArgs:Object = {};
            if(!debug)
            {
                launchArgs["noDebug"] = true;
            }
			launchArgs["name"] = "Moonshine Royale JS Launch";
			launchArgs["url"] = url;
			launchArgs["webRoot"] = getWebRoot(project).fileBridge.nativePath;
			var sourceRelativePath:String = project.projectFolder.file.fileBridge.getRelativePath(project.sourceFolder);
			//for some reason, Firefox doesn't like ../ in the source map paths,
			//at least not on macOS, so this is a workaround that maps the
			//mangled source path url back to the right path
			launchArgs["pathMappings"] = [
				{ url: getHost(project) + "/" + sourceRelativePath + "/", path: project.sourceFolder.fileBridge.nativePath + "/" }
			];
            dispatcher.dispatchEvent(new DebugAdapterEvent(DebugAdapterEvent.START_DEBUG_ADAPTER,
                project, debugAdapterType, debugCommand, launchArgs));
        }

		private function launchApplication():void
		{
			var as3Project:AS3ProjectVO = currentProject as AS3ProjectVO;

			if(!debugAfterBuild && (!UtilsCore.isNodeAvailable() || ConstantsCoreVO.IS_APP_STORE_VERSION))
			{
				//the HTTP server and the debug adapter both require Node.js.
				//it's not ideal, but if Node.js is not available and the user
				//did not request debugging, we can launch the local HTML file
				//in their browser.
				launchApplicationWithoutDebugAdapter();
				return;
			}

			var canStart:Boolean = true;
			if(needsLocalServer(as3Project))
			{
				var httpWorkingDir:FileLocation = getWebRoot(as3Project);
				var httpServerEvent:HttpServerEvent = new HttpServerEvent(HttpServerEvent.START_HTTP_SERVER, httpWorkingDir, DEBUG_SERVER_PORT);
					dispatcher.dispatchEvent(httpServerEvent);
				canStart = !httpServerEvent.isDefaultPrevented();
			}

			if(canStart)
			{
				//debug adapter can launch/run without debugging
				startDebugAdapter(as3Project, debugAfterBuild);
			}
			currentProject = null;
		}
		

		private function launchApplicationWithoutDebugAdapter():void
		{
			var pvo:AS3ProjectVO = currentProject as AS3ProjectVO;
			var swfFile:File = currentProject.folderLocation.resolvePath(pvo.swfOutput.path.fileBridge.nativePath).fileBridge.getFile as File;

			if (pvo.testMovie == AS3ProjectVO.TEST_MOVIE_CUSTOM) 
			{
				var customSplit:Vector.<String> = Vector.<String>(pvo.testMovieCommand.split(";"));
				var customFile:String = customSplit[0];
				var customArgs:String = customSplit.slice(1).join(" ").replace("$(ProjectName)", pvo.projectName).replace("$(CompilerPath)", currentSDK.nativePath);

                print(customFile + " " + customArgs, pvo.folderLocation.fileBridge.nativePath);
			}
			else if (pvo.testMovie == AS3ProjectVO.TEST_MOVIE_AIR)
			{
                warning("Launching application " + pvo.name + ".");
				// Let SWFLauncher deal with playin' the swf
				dispatcher.dispatchEvent(
					new SWFLaunchEvent(SWFLaunchEvent.EVENT_LAUNCH_SWF, swfFile, pvo, currentSDK)
				);
			} 
			else 
			{
                warning("Launching application " + pvo.name + ".");

				var launchEvent:SWFLaunchEvent = new SWFLaunchEvent(SWFLaunchEvent.EVENT_LAUNCH_SWF, null, pvo);
				if (pvo.customHTMLPath && StringUtil.trim(pvo.customHTMLPath).length != 0)
				{
					//this is a fallback, and should not use getUrlToLaunch()
					launchEvent.url = pvo.customHTMLPath;
				}
				else
				{
					//this is a fallback, and should not use getUrlToLaunch()
					launchEvent.file = new FileLocation(pvo.urlToLaunch).fileBridge.getFile as File;
				}

				dispatcher.dispatchEvent(launchEvent);
			}
			currentProject = null;
		}
		
		private var resourceCopiedIndex:int;
		private var resourceDestinationCopiedIndex:int;
		private var maxResourceForCopy:int;

		private function copyingResources():void
		{
            var pvo:AS3ProjectVO = currentProject as AS3ProjectVO;
			if (pvo.resourcePaths.length == 0)
			{
				notifySuccessfullBuildAfterResourceCopy();
				return;
			}

			if (resourceCopiedIndex == pvo.resourcePaths.length)
			{
				resourceCopiedIndex = 0;
				notifySuccessfullBuildAfterResourceCopy();
				return;
			}

			var resources:FileLocation = pvo.resourcePaths[resourceCopiedIndex];

			warning("Start copying resource: %s", resources.name);

            var buildResultFile:File = currentProject.folderLocation.resolvePath(pvo.getRoyaleDebugPath()).fileBridge.getFile as File;
			var debugDestination:File = buildResultFile.parent;
			var releaseDestination:File = currentProject.folderLocation.resolvePath(
					pvo.jsOutputPath.concat(currentProject.folderLocation.fileBridge.separator.concat("bin",
											currentProject.folderLocation.fileBridge.separator, "js-release"))).fileBridge.getFile as File;

			maxResourceForCopy = !releaseDestination.exists ? 1 : 2;
			resourceDestinationCopiedIndex = 0;

			if (debugDestination.exists)
			{
				copyResourcesTo(new File(resources.fileBridge.nativePath), debugDestination);
			}

			if (releaseDestination.exists)
			{
				copyResourcesTo(new File(resources.fileBridge.nativePath), releaseDestination);
			}

			resourceCopiedIndex++;
		}

		private function copyResourcesTo(resources:File, destination:File):void
		{
			print("Copying resources to %s", destination.nativePath);

			resources.addEventListener(Event.COMPLETE, onResourcesCopyingComplete);
			resources.addEventListener(IOErrorEvent.IO_ERROR, onResourcesCopyingFailed);

			resources.copyToAsync(destination.resolvePath(resources.name), true);
		}

        private function onResourcesCopyingComplete(event:Event):void
		{
            event.currentTarget.removeEventListener(Event.COMPLETE, onResourcesCopyingComplete);
            event.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, onResourcesCopyingFailed);

			resourceDestinationCopiedIndex++;
			if (resourceDestinationCopiedIndex == maxResourceForCopy)
			{
				copyingResources();
			}
		}

        private function onResourcesCopyingFailed(event:IOErrorEvent):void
        {
            event.currentTarget.removeEventListener(Event.COMPLETE, onResourcesCopyingComplete);
            event.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, onResourcesCopyingFailed);

            error("Copying resources failed %s\n", event.text);
            error("Project Build failed.");

			resourceDestinationCopiedIndex = 0;
			resourceCopiedIndex = 0;
        }

		private function needsLocalServer(pvo:AS3ProjectVO):Boolean
		{
			if(ConstantsCoreVO.IS_APP_STORE_VERSION)
			{
				//starting the http server doesn't work
				return false;
			}
			return !(pvo.customHTMLPath && StringUtil.trim(pvo.customHTMLPath).length != 0);
		}

		private function getHost(pvo:AS3ProjectVO):String
		{
			return "http://localhost:" + DEBUG_SERVER_PORT;
		}

		private function getUrlToLaunch(pvo:AS3ProjectVO):String
		{
			var url:String = getHost(pvo);
			if(pvo.customHTMLPath && StringUtil.trim(pvo.customHTMLPath).length != 0)
			{
				url = pvo.customHTMLPath;
			}
			else if(pvo.urlToLaunch)
			{
				if(needsLocalServer(pvo))
				{
					var relativeURL:String = getWebRoot(pvo).fileBridge.getRelativePath(new FileLocation(pvo.urlToLaunch));
					if(relativeURL)
					{
						url += "/" + relativeURL;
					}
				}
				else
				{
					url = new FileLocation(pvo.urlToLaunch).fileBridge.url;
				}
			}

			return url;
		}

		private function notifySuccessfullBuildAfterResourceCopy():void
		{
			var pvo:AS3ProjectVO = currentProject as AS3ProjectVO;
			if(runAfterBuild || debugAfterBuild)
			{
				dispatcher.dispatchEvent(new RefreshTreeEvent(new FileLocation(pvo.jsOutputPath).resolvePath("bin")));
				success("Project %s build successfully.", pvo.name);
				launchApplication();
			}
			else
			{
				success("Project %s build successfully.", pvo.name);
				dispatcher.dispatchEvent(new RefreshTreeEvent(new FileLocation(pvo.jsOutputPath).resolvePath("bin")));
			}
		}

		private function shellError(e:ProgressEvent):void 
		{
			if(fcsh)
			{
				successMessage = null;
				var output:IDataInput = fcsh.standardError;
				var data:String = output.readUTFBytes(output.bytesAvailable);

				printBuildProgress(data);
			}
		}
		
		private function shellExit(e:NativeProcessExitEvent):void 
		{
			reset();
			cleanUpShell();

			if (exiting)
			{
				exiting = false;
				startShell();
			}

			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
			dispatcher.removeEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onTerminateBuildRequest);
		}

		private function printBuildProgress(data:String):void
		{
            var syntaxMatch:Array = data.match(/(.*?)\((\d*)\): col: (\d*) (Error:|Syntax error:) (.+).+/);
            if (syntaxMatch)
            {
                error("%s\n", data);
                return;
            }

            var generalMatch:Array = data.match(new RegExp("[^:]*:?\s*Error:\s(.*)", "i"));
            if (!syntaxMatch && generalMatch)
            {
                error("%s\n", data);
                return;
            }

            var warningMatch:Array = data.match(new RegExp("WARNING:", "i"));
            if (warningMatch && !generalMatch && !syntaxMatch)
            {
                warning(data);
                return;
            }

            var match:Array = data.match(/successfully compiled and optimized|has been successfully compiled/);
            if (match)
            {
                print("%s", data);
                setTimeout(function():void {
					onSuccesfullBuildCompleted(null);
                }, 100);
                return;
            }

            if (data.charAt(data.length-1) == "\n")
            {
                data = data.substr(0, data.length-1);
            }

            print("%s", data);
		}

		private function displayPlayerGlobalError(sdkReference:SDKReferenceVO):void
		{
			var separator:String = model.fileCore.separator;
			var playerVersion:String = sdkReference.getPlayerGlobalVersion();
			var p:ParagraphElement = new ParagraphElement();
			var spanText:SpanElement = new SpanElement();
			var link:LinkElement = new LinkElement();

			if (!playerVersion)
			{
				playerVersion = "{version}";
			}

			p.color = 0xFA8072;
			spanText.text = ":\n: This SDK does not contains playerglobal.swc in frameworks".concat(
					separator, "libs", separator, "player", separator, playerVersion, separator, "playerglobal.swc", ".",
					" Download playerglobal ");
			link.href = "https://helpx.adobe.com/flash-player/kb/archived-flash-player-versions.html";
			link.linkNormalFormat = {color:0xc165b8, textDecoration:TextDecoration.UNDERLINE};

			var spanLink:SpanElement = new SpanElement();
			spanLink.text = "here";
			link.addChild(spanLink);

			p.addChild(spanText);
			p.addChild(link);

			dispatcher.dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_OUTPUT, p));
		}
	}
}