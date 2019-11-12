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
	import actionScripts.locator.HelperModel;
	import actionScripts.plugin.console.ConsoleOutputEvent;
	import actionScripts.utils.SDKUtils;
	import actionScripts.valueObjects.SDKReferenceVO;

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

	import flashx.textLayout.elements.LinkElement;

	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.formats.TextDecoration;

	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;
	import mx.resources.ResourceManager;
	
	import actionScripts.events.RefreshTreeEvent;
	import actionScripts.events.StatusBarEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.actionscript.mxmlc.MXMLCPluginEvent;
	import actionScripts.plugin.core.compiler.ActionScriptBuildEvent;
	import actionScripts.plugin.project.ProjectType;
	import actionScripts.plugin.settings.ISettingsProvider;
	import actionScripts.plugin.settings.vo.BooleanSetting;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.plugins.build.CompilerPluginBase;
	import actionScripts.plugins.swflauncher.event.SWFLaunchEvent;
	import actionScripts.utils.EnvironmentSetupUtils;
	import actionScripts.utils.NoSDKNotifier;
	import actionScripts.utils.OSXBookmarkerNotifiers;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.Settings;
	
	import components.popup.SelectOpenedFlexProject;
	import components.views.project.TreeView;

    public class MXMLCJavaScriptPlugin extends CompilerPluginBase implements ISettingsProvider
	{
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
		private var selectProjectPopup:SelectOpenedFlexProject;
		protected var runAfterBuild:Boolean;

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
			
			
			dispatcher.addEventListener(ActionScriptBuildEvent.BUILD_AND_RUN_JAVASCRIPT, buildAndRun);
			dispatcher.addEventListener(ActionScriptBuildEvent.BUILD_AS_JAVASCRIPT, build);
			reset();
		}
		
		override public function deactivate():void 
		{
			super.deactivate();
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
			resourceCopiedIndex = 0;
		}
		
		private function buildAndRun(e:Event):void
		{
			build(e,true);	
		}
		
		private function build(e:Event, runAfterBuild:Boolean=false):void
		{
			this.isProjectHasInvalidPaths = false;
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
					var projectReference:ProjectVO = tmpTreeView.getProjectBySelection();
					if (projectReference)
					{
						checkForUnsavedEdior(projectReference);
						return;
					}
				}
				
				// if above is false
				selectProjectPopup = new SelectOpenedFlexProject();
				selectProjectPopup.projectType = ProjectType.AS3PROJ_AS_AIR;
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
				
				UtilsCore.checkIfRoyaleApplication(as3Pvo);
				if (as3Pvo.isFlexJS || as3Pvo.isRoyale)
				{
					// FlexJS Application
					shellInfo = new NativeProcessStartupInfo();
					fschstr = fschFile.nativePath;
					fschstr = UtilsCore.convertString(fschstr);
					SDKstr = currentSDK.nativePath;
					SDKstr = UtilsCore.convertString(SDKstr);
					
					// update build config file
					as3Pvo.updateConfig();

					compileStr = getBuildArgs(as3Pvo);
					EnvironmentSetupUtils.getInstance().initCommandGenerationToSetLocalEnvironment(onEnvironmentPrepared, SDKstr, [compileStr]);
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
			var compilerPathHomeArg:String = "FALCON_HOME=\"" + SDKstr +"\"";
			var compilerArg:String = "&& \"" + fschstr +"\"";
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
					sdkPathHomeArg = "ROYALE_HOME=\"" + SDKstr +"\"";
					compilerPathHomeArg = "ROYALE_COMPILER_HOME=\"" + SDKstr +"\"";
                }

				jsCompilationArg += " -js-output=\"".concat(project.jsOutputPath) +"\"";
			}

            if(Settings.os == "win")
            {
				compileStr = compileStr.concat(
					sdkPathHomeArg ? ("set "+ sdkPathHomeArg)+"&& " : '', "set ", compilerPathHomeArg, compilerArg, configArg, additionalBuildArgs, jsCompilationArg
				);
            }
            else
            {
				var royaleLibPath:String = "royalelib=".concat('"', SDKstr, File.separator, "frameworks", '"');
				compileStr = compileStr.concat(
						sdkPathHomeArg ? ("export " + " " + royaleLibPath + " "  + sdkPathHomeArg)+" && " : '', "export ", royaleLibPath, " ", enLanguageArg, " && export ", compilerPathHomeArg, compilerArg, configArg, additionalBuildArgs, jsCompilationArg
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
				fcsh.exit(true);
            }
            fcsh.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);
            fcsh.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
            fcsh.removeEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR,shellError);
            fcsh.removeEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR,shellError);
            fcsh.removeEventListener(NativeProcessExitEvent.EXIT, shellExit);
            fcsh = null;

            dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
            dispatcher.removeEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onTerminateBuildRequest);
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

            dispatcher.dispatchEvent(new RefreshTreeEvent((currentProject as AS3ProjectVO).folderLocation.resolvePath("bin")));
            if(runAfterBuild)
            {
                launchApplication();
            }
            else
            {
                copyingResources();
            }
        }

		private function launchApplication():void
		{
			var pvo:AS3ProjectVO = currentProject as AS3ProjectVO;
			var swfFile:File = currentProject.folderLocation.resolvePath(pvo.swfOutput.path.fileBridge.nativePath).fileBridge.getFile as File;
			
			// before test movie lets copy the resource folder(s)
			// to debug folder if any
			if (pvo.resourcePaths.length != 0 && resourceCopiedIndex == 0)
			{
				copyingResources();
				return;
			}

            success("Project Build Successfully.");

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
					launchEvent.url = pvo.customHTMLPath;
				}
				else
				{
					launchEvent.file = new FileLocation(pvo.urlToLaunch).fileBridge.getFile as File;
				}

				dispatcher.dispatchEvent(launchEvent);
			}
			currentProject = null;
		}
		
		private var resourceCopiedIndex:int;
		private function copyingResources():void
		{
            var pvo:AS3ProjectVO = currentProject as AS3ProjectVO;

            if (pvo.resourcePaths.length == 0)
			{
                success("Project Build Successfully.");
				return;
			}

            var buildResultFile:File = currentProject.folderLocation.resolvePath(pvo.getRoyaleDebugPath()).fileBridge.getFile as File;
			var debugDestination:File = buildResultFile.parent;
			var fl:FileLocation = pvo.resourcePaths[resourceCopiedIndex];

            warning("Copying resource: %s", fl.name);

			(fl.fileBridge.getFile as File).addEventListener(Event.COMPLETE, onResourcesCopyingComplete);
            (fl.fileBridge.getFile as File).addEventListener(IOErrorEvent.IO_ERROR, onResourcesCopyingFailed);
			// copying to bin/bin-debug
			(fl.fileBridge.getFile as File).copyToAsync(debugDestination.resolvePath(fl.fileBridge.name), true);
		}

        private function onResourcesCopyingComplete(event:Event):void
		{
            event.currentTarget.removeEventListener(Event.COMPLETE, onResourcesCopyingComplete);
            event.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, onResourcesCopyingFailed);

            var pvo:AS3ProjectVO = currentProject as AS3ProjectVO;
            print("Copying %s complete", event.currentTarget.nativePath);

            resourceCopiedIndex++;
            if (resourceCopiedIndex < pvo.resourcePaths.length)
			{
				copyingResources();
            }
            else if (runAfterBuild)
            {
                dispatcher.dispatchEvent(new RefreshTreeEvent(new FileLocation(pvo.jsOutputPath).resolvePath("bin")));
                launchApplication();
            }
            else
            {
                success("Project Build Successfully.");
                dispatcher.dispatchEvent(new RefreshTreeEvent(new FileLocation(pvo.jsOutputPath).resolvePath("bin")));
            }
		}

        private function onResourcesCopyingFailed(event:IOErrorEvent):void
        {
            event.currentTarget.removeEventListener(Event.COMPLETE, onResourcesCopyingComplete);
            event.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, onResourcesCopyingFailed);

            error("Copying resources failed %s\n", event.text);
            error("Project Build failed.");
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
			if (exiting)
			{
				exiting = false;
				startShell();
			}
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