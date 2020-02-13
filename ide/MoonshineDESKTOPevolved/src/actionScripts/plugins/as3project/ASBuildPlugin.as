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
package actionScripts.plugins.as3project
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.utils.Dictionary;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	import mx.resources.ResourceManager;
	
	import actionScripts.events.ProjectEvent;
	import actionScripts.events.RefreshTreeEvent;
	import actionScripts.events.ShowSettingsEvent;
	import actionScripts.events.StatusBarEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.HelperModel;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.actionscript.as3project.vo.BuildOptions;
	import actionScripts.plugin.actionscript.mxmlc.MXMLCPluginEvent;
	import actionScripts.plugin.console.ConsoleOutputEvent;
	import actionScripts.plugin.core.compiler.ActionScriptBuildEvent;
	import actionScripts.plugin.templating.TemplatingHelper;
	import actionScripts.plugins.build.CompilerPluginBase;
	import actionScripts.plugins.swflauncher.SWFLauncherPlugin;
	import actionScripts.plugins.swflauncher.event.SWFLaunchEvent;
	import actionScripts.plugins.swflauncher.launchers.NativeExtensionExpander;
	import actionScripts.ui.editor.text.DebugHighlightManager;
	import actionScripts.utils.CommandLineUtil;
	import actionScripts.utils.EnvironmentSetupUtils;
	import actionScripts.utils.NoSDKNotifier;
	import actionScripts.utils.OSXBookmarkerNotifiers;
	import actionScripts.utils.SDKUtils;
	import actionScripts.utils.UtilsCore;
	import actionScripts.utils.findAndCopyApplicationDescriptor;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.SDKReferenceVO;
	import actionScripts.valueObjects.Settings;
	
	import components.popup.SelectOpenedProject;
	import components.views.project.TreeView;
	
	import flashx.textLayout.elements.LinkElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.formats.TextDecoration;

	import actionScripts.plugins.debugAdapter.events.DebugAdapterEvent;
	import actionScripts.valueObjects.MobileDeviceVO;
	
	public class ASBuildPlugin extends CompilerPluginBase
	{
		override public function get name():String			{ return "ActionScript Build Plugin"; }
		override public function get author():String		{ return "Miha Lunar & Moonshine Project Team"; }
		override public function get description():String	{ return ResourceManager.getInstance().getString('resources','plugin.desc.mxmlc'); }

		protected var runAfterBuild:Boolean;
		protected var debugAfterBuild:Boolean;
		protected var release:Boolean;
		private var cmdFile:File;
		private var fcsh:NativeProcess;
		private var exiting:Boolean = false;
		private var shellInfo:NativeProcessStartupInfo;
		private var isLibraryProject:Boolean;
		private var adtProcess:NativeProcess;
		private var adtProcessInfo:NativeProcessStartupInfo;
		
		private var lastTarget:File;
		private var targets:Dictionary;
		private var isProjectHasInvalidPaths:Boolean;
		
		private var currentSDK:File;
		
		/** Project currently under compilation */
		private var currentProject:ProjectVO;
		private var queue:Vector.<String> = new Vector.<String>();

		private var fschstr:String;
		private var SDKstr:String;
		private var selectProjectPopup:SelectOpenedProject;

		public function ASBuildPlugin()
		{
			if (Settings.os == "win")
			{
				cmdFile = new File("c:\\Windows\\System32\\cmd.exe");
			}
			else
			{
				cmdFile = new File("/bin/bash");
			}
		}
		
		override public function activate():void 
		{
			if (activated) return;
			
			super.activate();
			
			dispatcher.addEventListener(ActionScriptBuildEvent.BUILD_AND_RUN, buildAndRun);
			dispatcher.addEventListener(ActionScriptBuildEvent.BUILD_AND_DEBUG, buildAndRun);
			dispatcher.addEventListener(ActionScriptBuildEvent.BUILD, build);
			dispatcher.addEventListener(ActionScriptBuildEvent.BUILD_RELEASE, buildRelease);

			var tempObj:Object = new Object();
			tempObj.callback = buildCommand;
			tempObj.commandDesc = "Build the currently selected Flex project.";
			registerCommand('buildAS',tempObj);

			tempObj = new Object();
			tempObj.callback = runCommand;
			tempObj.commandDesc = "Build and run the currently selected Flex project.";
			registerCommand('runAS',tempObj);

			tempObj = new Object();
			tempObj.callback = releaseCommand;
			tempObj.commandDesc = "Build the currently selected project in release mode.";
			tempObj.style = "red";
			registerCommand('releaseAS',tempObj);

			reset();
		}
		
		override public function deactivate():void 
		{
			super.deactivate();
			
			dispatcher.removeEventListener(ActionScriptBuildEvent.BUILD_AND_RUN, buildAndRun);
			dispatcher.removeEventListener(ActionScriptBuildEvent.BUILD_AND_DEBUG, buildAndRun);
			dispatcher.removeEventListener(ActionScriptBuildEvent.BUILD, build);
			dispatcher.removeEventListener(ActionScriptBuildEvent.BUILD_RELEASE, buildRelease);
			
			reset();
			shellInfo = null;
		}

		private function buildCommand(args:Array):void
		{
			build(null, false);
		}
		
		private function runCommand(args:Array):void
		{
			build(null, true);
		}
		
		private function releaseCommand(args:Array):void
		{
			build(null, false, true);
		}
		
		private function reset():void 
		{
			stopShell();
			resourceCopiedIndex = 0;
			targets = new Dictionary();
		}

		private function buildAndRun(e:Event):void
		{
			if (!UtilsCore.hasJava()) return;

			// re-check in case of debug call and its already running
			if (e.type == ActionScriptBuildEvent.BUILD_AND_DEBUG && DebugHighlightManager.IS_DEBUGGER_CONNECTED)
			{
				Alert.show("You are already debugging an application. Do you wish to terminate the existing debugging session and start a new session?", "Debug Warning", Alert.YES|Alert.CANCEL, FlexGlobals.topLevelApplication as Sprite, reDebugConfirmClickHandler);	
			}
			else
				build(e, true);
			
			/*
			 * @local
			 */
			function reDebugConfirmClickHandler(event:CloseEvent):void
			{
				if (event.detail == Alert.YES)
				{
					dispatcher.dispatchEvent(new Event(ActionScriptBuildEvent.TERMINATE_EXECUTION));
					setTimeout(function():void
					{
						dispatcher.dispatchEvent(e);
					}, 500);
				}
			}
		}
		
		private function buildRelease(e:Event):void
		{
			if (!UtilsCore.hasJava()) return;

			SWFLauncherPlugin.RUN_AS_DEBUGGER = false;
			build(e, false, true);
		}
		
		private function sdkSelected(event:Event):void
		{
			sdkSelectionCancelled(null);
			// update swf version if a newer SDK now saved than previously saved one
			AS3ProjectVO(currentProject).swfOutput.swfVersion = SDKUtils.getSdkSwfMajorVersion();
			// continue with waiting build process again
			proceedWithBuild(currentProject);
		}
		
		private function sdkSelectionCancelled(event:Event):void
		{
			model.noSDKNotifier.removeEventListener(NoSDKNotifier.SDK_SAVED, sdkSelected);
			model.noSDKNotifier.removeEventListener(NoSDKNotifier.SDK_SAVE_CANCELLED, sdkSelectionCancelled);
		}
		
		private function build(e:Event, runAfterBuild:Boolean=false, release:Boolean=false):void 
		{
			if (!UtilsCore.hasJava()) return;

			if (e && e.type == ActionScriptBuildEvent.BUILD_AND_DEBUG)
			{
				this.debugAfterBuild = true;
				SWFLauncherPlugin.RUN_AS_DEBUGGER = true;
			}
			else
			{
				this.debugAfterBuild = false;
				SWFLauncherPlugin.RUN_AS_DEBUGGER = false;
			}
			
			this.isProjectHasInvalidPaths = false;
			this.runAfterBuild = runAfterBuild;
			this.release = release;
			buildStart();
		}
		
		private function buildStart():void
		{
			var filteredProjects:Array = model.projects.source.filter(function(project:ProjectVO, index:int, source:Array):Boolean
			{
				if(!(project is AS3ProjectVO))
				{
					return false;
				}
				var as3Project:AS3ProjectVO = AS3ProjectVO(project);
				return !as3Project.isRoyale || as3Project.buildOptions.targetPlatform == "SWF";
			});
			// check if there is multiple projects were opened in tree view
			if (filteredProjects.length > 1)
			{
				// check if user has selection/select any particular project or not
				if (model.mainView.isProjectViewAdded)
				{
					var tmpTreeView:TreeView = model.mainView.getTreeViewPanel();
					var projectReference:ProjectVO = tmpTreeView.getProjectBySelection();
					if (projectReference && filteredProjects.indexOf(projectReference) != -1)
					{
						checkForUnsavedEditor(projectReference);
						return;
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
			else if (filteredProjects.length != 0)
			{
				checkForUnsavedEditor(filteredProjects[0] as ProjectVO);
			}
			
			/*
			* @local
			*/
			function onProjectSelected(event:Event):void
			{
				checkForUnsavedEditor(selectProjectPopup.selectedProject);
				onProjectSelectionCancelled(null);
			}
			
			function onProjectSelectionCancelled(event:Event):void
			{
				selectProjectPopup.removeEventListener(SelectOpenedProject.PROJECT_SELECTED, onProjectSelected);
				selectProjectPopup.removeEventListener(SelectOpenedProject.PROJECT_SELECTION_CANCELLED, onProjectSelectionCancelled);
				selectProjectPopup = null;
			}
			
			/*
			* check for unsaved File
			*/
			function checkForUnsavedEditor(activeProject:ProjectVO):void
			{
				model.activeProject = activeProject;
				UtilsCore.closeAllRelativeEditors(activeProject, false, proceedWithBuild, false);
			}
		}
		
		private function proceedWithBuild(activeProject:ProjectVO=null):void
		{
			// Don't compile if there is no project. Don't warn since other compilers might take the job.
			if (!activeProject) activeProject = model.activeProject;
			if (!activeProject || !(activeProject is AS3ProjectVO)) return;
			
			reset();
			
			var as3Pvo:AS3ProjectVO = activeProject as AS3ProjectVO;
			isLibraryProject = as3Pvo.isLibraryProject;
			if (as3Pvo.targets.length == 0 && !as3Pvo.isLibraryProject)
			{
				error("No targets found for compilation.");
				return;
			}
			
			checkProjectForInvalidPaths(as3Pvo); 
			if (isProjectHasInvalidPaths)
			{
				return;
			}
			
			CONFIG::OSX
			{
				// before proceed, check file access dependencies
				if (!OSXBookmarkerNotifiers.checkAccessDependencies(new ArrayCollection([as3Pvo]), "Access Manager - Build Halt!")) 
				{
					Alert.show("Please fix the dependencies before build.", "Error!");
					return;
				}
			}
			
			UtilsCore.checkIfRoyaleApplication(as3Pvo);

			// Read file content to indentify the project type regular flex application or flexjs applicatino
			if (as3Pvo.isFlexJS)
			{
				if (as3Pvo.isRoyale)
				{
                    var tmpSDKLocation:FileLocation = UtilsCore.getCurrentSDK(as3Pvo as AS3ProjectVO);
					var sdkReference:SDKReferenceVO = SDKUtils.getSDKReference(tmpSDKLocation);
					if (sdkReference && sdkReference.isJSOnlySdk)
					{
						error("This SDK only supports JavaScript Builds. Change platform to 'JS' in project Settings -> Run.");
						return;
					}

					if (!sdkReference.hasPlayerglobal && !HelperModel.getInstance().moonshineBridge.playerglobalExists)
					{
						displayPlayerGlobalError(sdkReference);
						return;
					}
				}
			}
			else
			{
				//Regular application
				compileRegularFlexApplication(activeProject, release);
			}
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

		private function compileRegularFlexApplication(pvo:ProjectVO, release:Boolean=false):void
		{
			var compileStr:String;
			if (!fcsh || pvo.folderLocation.fileBridge.nativePath != shellInfo.workingDirectory.nativePath 
				|| usingInvalidSDK(pvo as AS3ProjectVO)) 
			{
				currentProject = pvo;
				var tempCurrentSdk:FileLocation = UtilsCore.getCurrentSDK(pvo as AS3ProjectVO);
				currentSDK = null;
				if (!tempCurrentSdk)
				{
					model.noSDKNotifier.notifyNoFlexSDK(false);
					model.noSDKNotifier.addEventListener(NoSDKNotifier.SDK_SAVED, sdkSelected);
					model.noSDKNotifier.addEventListener(NoSDKNotifier.SDK_SAVE_CANCELLED, sdkSelectionCancelled);
					error("No Flex SDK found. Setup one in Settings menu.");
					return;
				}

				currentSDK = tempCurrentSdk.fileBridge.getFile as File;
				
				// check if it is a library application
				if ((pvo as AS3ProjectVO).isLibraryProject)
				{
					compileFlexLibrary(pvo as AS3ProjectVO);
					return;
				}
				
				SDKstr = currentSDK.nativePath;
				
				// update build config file
				AS3ProjectVO(pvo).updateConfig();
				compileStr = compile(pvo as AS3ProjectVO, release);
				
				EnvironmentSetupUtils.getInstance().initCommandGenerationToSetLocalEnvironment(onEnvironmentPrepared, SDKstr, [compileStr]);
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
				shellInfo.workingDirectory = pvo.folderLocation.fileBridge.getFile as File;
				
				initShell();
				
				if (ConstantsCoreVO.IS_MACOS)
				{
					debug("SDK path: %s", currentSDK.nativePath);
					send(compileStr);
				}
			}
		}
		
		private function compileFlexLibrary(pvo:AS3ProjectVO):void
		{
			var compcFile:File = (Settings.os == "win") ? currentSDK.resolvePath("bin/compc.bat") : currentSDK.resolvePath("bin/compc");
			if (!compcFile.exists)
			{
				Alert.show("Invalid SDK - Please configure a Flex SDK instead.","Error!");
				error("Invalid SDK - Please configure a Flex SDK instead.");
				return;
			}
			
			fschstr = compcFile.nativePath;
			fschstr = UtilsCore.convertString(fschstr);
			
			SDKstr = currentSDK.nativePath;
			
			// update build config file
			pvo.updateConfig();
			
			var compilerArg:String = "\""+ fschstr +"\" -load-config+="+ pvo.folderLocation.fileBridge.getRelativePath(pvo.config.file);
			if (ConstantsCoreVO.IS_MACOS)
			{
				compilerArg = "export ".concat(
					'SETUP_SH_VMARGS="-Duser.language=en -Duser.region=en"', ";", compilerArg
				);
			}
			
			EnvironmentSetupUtils.getInstance().initCommandGenerationToSetLocalEnvironment(onEnvironmentPrepared, SDKstr, [compilerArg]);
			
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
				shellInfo.workingDirectory = pvo.folderLocation.fileBridge.getFile as File;
				
				initShell();
				
				if (ConstantsCoreVO.IS_MACOS)
				{
					debug("SDK path: %s", currentSDK.nativePath);
					send(compilerArg);
				}
			}
		}

		private function compile(pvo:AS3ProjectVO, release:Boolean=false):String 
		{
            clearOutput();
			dispatcher.dispatchEvent(new MXMLCPluginEvent(ActionScriptBuildEvent.PREBUILD, new FileLocation(currentSDK.nativePath)));
			warning("Compiling "+pvo.projectName);
			
			currentProject = pvo;
			if (pvo.targets.length == 0) 
			{
				error("No targets found for compilation.");
				return "";
			}
			var file:FileLocation = pvo.targets[0];
			if (targets[file] == undefined) 
			{
				lastTarget = file.fileBridge.getFile as File;

				var buildArgs:String = pvo.buildOptions.getArguments();
				if (pvo.air)
				{
					// option for manipulating swf launch through additional arg
					// in case of project user wants to run it in a mobile simulator by adding certain
					// commands in Additional Compiler Arguments, we need to make the swf launching
					// behaves as a mobile or air
					var noAir:Boolean = buildArgs.indexOf("+configname=air") == -1;
					if (noAir)
					{
						pvo.isMobile = UtilsCore.isMobile(pvo);
					}
					else
					{
						pvo.isMobile = !noAir ? true : false;
					}
				}

				if (pvo.nativeExtensions && pvo.nativeExtensions.length > 0)
				{
					var extensionArgs:String = "";
					var relativeExtensionFolderPath:String = pvo.folderLocation.fileBridge.getRelativePath(pvo.nativeExtensions[0], true);
					var tmpExtensionFiles:Array = pvo.nativeExtensions[0].fileBridge.getDirectoryListing();
					for (var i:int = 0; i < tmpExtensionFiles.length; i++)
					{
						if (tmpExtensionFiles[i].extension == "ane" && !tmpExtensionFiles[i].isDirectory) 
						{
							var extensionArg:String = " -external-library-path+="+ relativeExtensionFolderPath +"/"+ tmpExtensionFiles[i].name; 
							if (pvo.buildOptions.additional.indexOf(extensionArg) == -1) extensionArgs += extensionArg;
						}
						else
						{
							tmpExtensionFiles.splice(i, 1);
							i--;
						}
					}
					
					if (extensionArgs != "") 
					{
						if (pvo.air && pvo.buildOptions.isMobileRunOnSimulator) new NativeExtensionExpander(tmpExtensionFiles);
					}
				}

				var javaExec:String = UtilsCore.getExecutableJavaLocation().fileBridge.nativePath;
				var asConfigPath:String = File.applicationDirectory.resolvePath("elements/as3mxml-language-server/bin/asconfigc.jar").nativePath;
				var commandConfig:String = "\"" + javaExec + "\" -jar \"" + asConfigPath + "\" --sdk " + model.defaultSDK.fileBridge.nativePath + " ";
				var mxmlcStr:String = commandConfig
					+" --project " + pvo.asConfig.file.fileBridge.nativePath;
				
				print("Command: %s"+ mxmlcStr);
				return mxmlcStr;
			} 
			else 
			{
				var target:int = targets[file];
				return "compile "+target;
			}
		}
		
		private function send(msg:String):void 
		{
			debug("Sending to mxmlc: %s", msg);
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
			if (!debugAfterBuild)
			{
				dispatcher.dispatchEvent(new ActionScriptBuildEvent(ActionScriptBuildEvent.STOP_DEBUG, false));
			}

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
            if (!fcsh)
			{
				return;
			}

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
				var match:Array;
				var isSuccessBuild:Boolean;
				
				match = data.match(/fcsh: Target \d not found/);
				if (match)
				{
					error("Target not found. Try again.");
					targets = new Dictionary();
				}
				
				match = data.match(/fcsh: Assigned (\d) as the compile target id/);
				if (match && lastTarget) {
					var target:int = int(match[1]);
					targets[lastTarget] = target;
					
					debug("FSCH target: %s", target);
					
					lastTarget = null;
				}
				
				match = data.match(/.* bytes.*/);
				if (match)
				{
					isSuccessBuild = true;
                }
				else 
				{
					match = data.match(/.*successfully compiled and optimized.*/);
					if (match) isSuccessBuild = true;
				}
				
				if (isSuccessBuild) 
				{
					var currentSuccessfullProject:AS3ProjectVO = currentProject as AS3ProjectVO;

					dispatcher.dispatchEvent(new RefreshTreeEvent(currentSuccessfullProject.swfOutput.path.fileBridge.parent));

                    print("%s", data);
					
					if (!isLibraryProject)
					{
						if (currentSuccessfullProject.testMovie != AS3ProjectVO.TEST_MOVIE_CUSTOM &&
							currentSuccessfullProject.testMovie != AS3ProjectVO.TEST_MOVIE_AIR)
						{
							var swfFile:File = currentSuccessfullProject.swfOutput.path.fileBridge.getFile as File;
							var htmlWrapperFile:File = swfFile.parent.resolvePath(swfFile.name.split(".")[0] +".html");
							getHTMLTemplatesCopied(currentSuccessfullProject, htmlWrapperFile);
						}

						if (runAfterBuild || debugAfterBuild)
						{
							dispatcher.dispatchEvent(new SWFLaunchEvent(SWFLaunchEvent.EVENT_UNLAUNCH_SWF, null));
							if (currentSuccessfullProject.resourcePaths.length == 0)
							{
								if(currentSuccessfullProject.isMobile && !currentSuccessfullProject.buildOptions.isMobileRunOnSimulator)
								{
									warning("Start packaging application for Mobile.");
									packageAIR(debugAfterBuild);
								}
								else
								{
									launchDebuggingAfterBuild(debugAfterBuild);
									success("Launching application: %s", currentProject.projectName);
								}
							}
							else
                            {
                                copyingResources();
                            }
						}
						else if (AS3ProjectVO(currentProject).resourcePaths.length != 0)
						{
							copyingResources();
						}
						else
						{
                            projectBuildSuccessfully();
						}
					}
					else
					{
						projectBuildSuccessfully();
					}

					return;
				}

				if (data.charAt(data.length-1) == "\n")
				{
					data = data.substr(0, data.length-1);
                }
				print("%s", data);
			}
			
		}

		private function projectBuildSuccessfully():void
		{
            var currentSuccessfullProject:AS3ProjectVO = currentProject as AS3ProjectVO;
            success("Project Build Successfully.");
            if (!currentSuccessfullProject.isFlexJS && !currentSuccessfullProject.isRoyale)
            {
                reset();
            }
		}

		private function launchDebuggingAfterBuild(debug:Boolean):void
		{
            projectBuildSuccessfully();
            dispatcher.dispatchEvent(new ProjectEvent(ActionScriptBuildEvent.POSTBUILD, currentProject));

			var as3Project:AS3ProjectVO = AS3ProjectVO(currentProject);
			if(as3Project.isMobile && !as3Project.buildOptions.isMobileRunOnSimulator)
			{
				var isAndroid:Boolean = as3Project.buildOptions.targetPlatform == "Android";
				var descriptorName:String = as3Project.swfOutput.path.fileBridge.name.split(".")[0] + "-app.xml";
				var descriptorPath:String = as3Project.targets[0].fileBridge.parent.fileBridge.nativePath + File.separator + descriptorName;
				var descriptorFile:FileLocation = as3Project.folderLocation.fileBridge.resolvePath(descriptorPath);
				var descriptorXML:XML = new XML(descriptorFile.fileBridge.read());
				var xmlns:Namespace = new Namespace(descriptorXML.namespace());
				var appID:String = descriptorXML.xmlns::id;

				var bundle:String = as3Project.swfOutput.path.fileBridge.parent.resolvePath(as3Project.name + (isAndroid ? ".apk" : ".ipa")).fileBridge.nativePath;
				var attachArgs:Object =
				{
					"name": "Moonshine SWF Device Attach",
					"platform": isAndroid ? "android" : "ios",
					//connect to the device over USB
					"connect": true,
					//the port to connect over
					"port": 7936,
					//uninstall/launch this app ID
					"applicationID": appID,
					//install this bundle
					"bundle": bundle
				};
				dispatcher.dispatchEvent(new DebugAdapterEvent(DebugAdapterEvent.START_DEBUG_ADAPTER, as3Project, "swf", "attach", attachArgs));
			}
			else if(as3Project)
			{
				var launchArgs:Object =
				{
					"name": "Moonshine SWF Launch"
				};
				if(!debug)
				{
					launchArgs["noDebug"] = true;
				}
				if(as3Project)
				{
					var swfFile:File = as3Project.swfOutput.path.fileBridge.getFile as File;
					if(as3Project.testMovie === AS3ProjectVO.TEST_MOVIE_AIR)
					{
						//switch to the Adobe AIR application descriptor XML file
						launchArgs["program"] = findAndCopyApplicationDescriptor(swfFile, as3Project, swfFile.parent);
						if(as3Project.isMobile)
						{
							var mobileDevice:MobileDeviceVO = null;
							if (as3Project.buildOptions.isMobileHasSimulatedDevice.name && !as3Project.buildOptions.isMobileHasSimulatedDevice.key)
							{
								var deviceCollection:ArrayCollection = as3Project.buildOptions.targetPlatform == "iOS" ? ConstantsCoreVO.TEMPLATES_IOS_DEVICES : ConstantsCoreVO.TEMPLATES_ANDROID_DEVICES;
								for (var i:int=0; i < deviceCollection.length; i++)
								{
									if (as3Project.buildOptions.isMobileHasSimulatedDevice.name == deviceCollection[i].name)
									{
										mobileDevice = deviceCollection[i];
										break;
									}
								}
							}
							else if (!as3Project.buildOptions.isMobileHasSimulatedDevice.name)
							{
								mobileDevice = ConstantsCoreVO.TEMPLATES_ANDROID_DEVICES[0];
							}
							else 
							{
								mobileDevice = as3Project.buildOptions.isMobileHasSimulatedDevice;
							}

							launchArgs["profile"] = "mobileDevice";
							launchArgs["screensize"] = mobileDevice.key;
							launchArgs["screenDPI"] = parseInt(mobileDevice.dpi, 10);
							launchArgs["versionPlatform"] = mobileDevice.type;
						}
					}
					else
					{
						var swfProgram:String = as3Project.customHTMLPath;
						if(!swfProgram && as3Project.urlToLaunch)
						{
							//for some reason, relative paths might be saved with a starting slash
							var firstChar:String = as3Project.urlToLaunch.charAt(0);
							if(firstChar == "/" || firstChar == "\\")
							{
								var relativeFile:FileLocation = as3Project.projectFolder.file.resolvePath(as3Project.urlToLaunch.substr(1));
								if(relativeFile.fileBridge.exists)
								{
									swfProgram = relativeFile.fileBridge.nativePath;
								}
							}
							if(!swfProgram)
							{
								swfProgram = as3Project.urlToLaunch;
							}
						}
						if(!swfProgram)
						{
							swfProgram = swfFile.nativePath;
						}
						launchArgs["program"] = swfProgram;
					}
				}
				dispatcher.dispatchEvent(new DebugAdapterEvent(DebugAdapterEvent.START_DEBUG_ADAPTER, as3Project, "swf", "launch", launchArgs));
			}
		}
		
		public function packageAIR(debugBuild:Boolean):void
		{
			var project:AS3ProjectVO = AS3ProjectVO(currentProject)
			var isAndroid:Boolean = project.buildOptions.targetPlatform == "Android";
			
			// checks if the credentials are present
			if(!ensureCredentialsPresent(project))
			{
				error("Launch cancelled.");
				return;
			}
			
			var swfFile:File = project.swfOutput.path.fileBridge.getFile as File;
			var descriptorName:String = swfFile.name.split(".")[0] + "-app.xml";
			var descriptorPath:String = project.targets[0].fileBridge.parent.fileBridge.nativePath + File.separator + descriptorName;
			
			// copy the descriptor file to build directory
			findAndCopyApplicationDescriptor(swfFile, project, swfFile.parent);
			
			// We need the application ID; without pre-guessing any
			// lets read and find it
			var descriptorFile:FileLocation = project.folderLocation.fileBridge.resolvePath(descriptorPath);
			var descriptorXML:XML = new XML(descriptorFile.fileBridge.read());
			var xmlns:Namespace = new Namespace(descriptorXML.namespace());
			
			var adtPath:String = currentSDK.resolvePath("bin/adt").nativePath;

			var outputFolder:File = swfFile.parent;
			var adtPackagingOptions:Vector.<String> = new <String>[adtPath];
			if(isAndroid) 
			{
				var androidPackagingMode:String = null;
				if(debugBuild)
				{
					androidPackagingMode = "apk-debug";
				}
				else
				{
					androidPackagingMode = "apk";
				}

				adtPackagingOptions.push("-package", "-target", androidPackagingMode);
				if(debugBuild)
				{
					//-connect tells the app to connect over wifi
					//adtPackagingOptions.push("-connect");

					//-listen tells the app to wait for a connection over USB
					adtPackagingOptions.push("-listen");
					adtPackagingOptions.push("7936")

					//must use one of -connect or -listen, but not both!
				}
				adtPackagingOptions.push("-storetype", "pkcs12", "-keystore", project.buildOptions.certAndroid, "-storepass", project.buildOptions.certAndroidPassword, project.name + ".apk", descriptorName, swfFile.name);
			}
			else
			{
				var iOSPackagingMode:String = null;
				if(debugBuild)
				{
					if(project.buildOptions.iosPackagingMode == BuildOptions.IOS_PACKAGING_FAST)
					{
						//fast bypasses bytecode translation interprets the SWF
						iOSPackagingMode = "ipa-debug-interpreter";
					}
					else
					{
						//standard takes longer to package
						//debug builds aren't meant for the app store, though
						iOSPackagingMode = "ipa-debug";
					}
				}
				else //release
				{
					if(project.buildOptions.iosPackagingMode == BuildOptions.IOS_PACKAGING_FAST)
					{
						//fast bypasses bytecode translation interprets the SWF
						iOSPackagingMode = "ipa-test-interpreter";
					}
					else
					{
						//standard takes longer to package
						//release builds are suitable for the app store
						iOSPackagingMode = "ipa-app-store";
					}
				}
					
				adtPackagingOptions.push("-package", "-target", iOSPackagingMode);
				if(debugBuild)
				{
					//-connect tells the app to connect over wifi
					//adtPackagingOptions.push("-connect");

					//-listen tells the app to wait for a connection over USB
					adtPackagingOptions.push("-listen");
					adtPackagingOptions.push("7936")

					//must use one of -connect or -listen, but not both!

				}
				adtPackagingOptions.push("-storetype", "pkcs12", "-keystore", project.buildOptions.certIos, "-storepass", project.buildOptions.certIosPassword, "-provisioning-profile", project.buildOptions.certIosProvisioning, project.name + ".ipa", descriptorName, swfFile.name);
			}
			
			// extensions and resources
			if(project.nativeExtensions && project.nativeExtensions.length > 0)
			{
				adtPackagingOptions.push("-extdir", project.nativeExtensions[0].fileBridge.nativePath);
			}
			if(project.resourcePaths)
			{
				for each(var i:FileLocation in project.resourcePaths)
				{
					adtPackagingOptions.push(i.fileBridge.nativePath);
				}
			}

			var adtCommand:String = CommandLineUtil.joinOptions(adtPackagingOptions);
			debug("Sending to adt: %s", adtCommand);
			
			EnvironmentSetupUtils.getInstance().initCommandGenerationToSetLocalEnvironment(function(value:String):void
			{
				var processArgs:Vector.<String> = new <String>[];
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
				
				adtProcessInfo = new NativeProcessStartupInfo();
				adtProcessInfo.arguments = processArgs;
				adtProcessInfo.executable = cmdFile;
				adtProcessInfo.workingDirectory = outputFolder;
				
				adtProcess = new NativeProcess();
				adtProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, adtProcess_standardOutputDataHandler);
				adtProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, adtProcess_standardErrorDataHandler);
				adtProcess.addEventListener(NativeProcessExitEvent.EXIT, adtProcess_exitHandler);
				adtProcess.start(adtProcessInfo);
			}, SDKstr, [adtCommand]);
		}
		
		private function ensureCredentialsPresent(project:AS3ProjectVO):Boolean
		{
			var isAndroid:Boolean = project.buildOptions.targetPlatform == "Android";
			if(isAndroid && (project.buildOptions.certAndroid && project.buildOptions.certAndroid != "") && (project.buildOptions.certAndroidPassword && project.buildOptions.certAndroidPassword != ""))
			{
				return true;
			}
			else if(!isAndroid && (project.buildOptions.certIos && project.buildOptions.certIos != "") && (project.buildOptions.certIosPassword && project.buildOptions.certIosPassword != "") && (project.buildOptions.certIosProvisioning && project.buildOptions.certIosProvisioning != ""))
			{
				return true;
			}
			
			Alert.show("Missing signing options.", "Error!", Alert.OK, null, onProcessTerminatesDueToCredentials);
			return false;
			
			/*
			 * @local
			 */
			function onProcessTerminatesDueToCredentials(event:CloseEvent):void
			{
				dispatcher.dispatchEvent(
					new ShowSettingsEvent(project, "run")
				);
			}
		}

		private function adtProcess_standardOutputDataHandler(event:ProgressEvent):void
		{
			var process:NativeProcess = NativeProcess(event.currentTarget);
			var output:IDataInput = process.standardOutput;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			notice(data);
		}

		private function adtProcess_standardErrorDataHandler(event:ProgressEvent):void
		{
			var process:NativeProcess = NativeProcess(event.currentTarget);
			var output:IDataInput = process.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			error(data);
		}

		private function adtProcess_exitHandler(event:NativeProcessExitEvent):void
		{
			if(isNaN(event.exitCode))
			{
				error("Adobe AIR package build has been terminated.");
			}
			else if(event.exitCode != 0)
			{
				error("Adobe AIR package build has been terminated with exit code: " + event.exitCode);
			}
			else
			{
				if(runAfterBuild || debugAfterBuild)
				{
					launchDebuggingAfterBuild(debugAfterBuild);
					success("Launching application: %s", currentProject.projectName);
				}
				else
				{
					projectBuildSuccessfully();
				}
			}
		}
		
		private var resourceCopiedIndex:int;
		private function copyingResources():void
		{
            var pvo:AS3ProjectVO = currentProject as AS3ProjectVO;
			if (pvo.resourcePaths.length == 0)
			{
				projectBuildSuccessfully();
				return;
            }

			var destination:File = pvo.swfOutput.path.fileBridge.parent.fileBridge.getFile as File;
			var fl:FileLocation = pvo.resourcePaths[resourceCopiedIndex];
            warning("Copying resource: %s", fl.name);

			(fl.fileBridge.getFile as File).addEventListener(Event.COMPLETE, onResourcesCopyingComplete);
			(fl.fileBridge.getFile as File).addEventListener(IOErrorEvent.IO_ERROR, onResourcesCopyingFailed);
			(fl.fileBridge.getFile as File).copyToAsync(destination.resolvePath(fl.fileBridge.name), true);
		}
		
        private function onResourcesCopyingComplete(event:Event):void
        {
            event.currentTarget.removeEventListener(Event.COMPLETE, onResourcesCopyingComplete);
            event.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, onResourcesCopyingFailed);

            resourceCopiedIndex++;

            var pvo:AS3ProjectVO = currentProject as AS3ProjectVO;
            print("Copying %s complete", event.currentTarget.nativePath);

            if (resourceCopiedIndex < pvo.resourcePaths.length)
            {
                copyingResources();
            }
			else if (debugAfterBuild || runAfterBuild)
			{
                dispatcher.dispatchEvent(new RefreshTreeEvent(pvo.swfOutput.path.fileBridge.parent));
				if(pvo.isMobile && !pvo.buildOptions.isMobileRunOnSimulator)
				{
					packageAIR(debugAfterBuild);
					//don't call launchDebuggingAfterBuild() until after the .apk or .ipa is built
				}
				else
				{
					launchDebuggingAfterBuild(debugAfterBuild);
					success("Launching application: %s", currentProject.projectName);
				}
            }
            else
            {
				projectBuildSuccessfully();
                dispatcher.dispatchEvent(new RefreshTreeEvent((currentProject as AS3ProjectVO).swfOutput.path.fileBridge.parent));
            }
        }

		private function onResourcesCopyingFailed(event:IOErrorEvent):void
		{
            event.currentTarget.removeEventListener(Event.COMPLETE, onResourcesCopyingComplete);
            event.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, onResourcesCopyingFailed);

			error("Copying resources failed %s\n", event.text);
            error("Project Build failed.");
		}

		private function getHTMLTemplatesCopied(pvo:AS3ProjectVO, htmlFile:File):void
		{
			if (!htmlFile.exists)
			{
				var htmlTemplateFolder:FileLocation = pvo.folderLocation.resolvePath("html-template");
				var fileName:String = htmlFile.name.split(".")[0];
				if (htmlTemplateFolder.fileBridge.exists)
				{
					var th:TemplatingHelper = new TemplatingHelper();
					th.templatingData["$Wrapper"] = fileName;
					th.projectTemplate(htmlTemplateFolder, pvo.folderLocation.resolvePath("bin-debug"));
					dispatcher.dispatchEvent(new RefreshTreeEvent(pvo.folderLocation.resolvePath("bin-debug")));
				}
				else
				{
					Alert.show("Missing \"html-template\" folder.\nMoonshine is trying to open the "+ fileName +".swf file.\n(Note: This may not work in MacOS Sandbox.)", "Note!");
				}
			}
		}
		
		private function shellError(e:ProgressEvent):void 
		{
			if(fcsh)
			{
				var output:IDataInput = fcsh.standardError;
				var data:String = output.readUTFBytes(output.bytesAvailable);

                var syntaxMatch:Array = data.match(/(.*?)\((\d*)\): col: (\d*) (Error:|Syntax error:) (.+).+/);
				if (syntaxMatch)
				{
					error("%s\n", data);
					return;
				}

                var generalMatch:Array = data.match(/[^:]*:?\s*Error:\s(.*)/);
				if (!syntaxMatch && generalMatch)
				{
					error("%s\n", data);
					return;
				}

				//Build should be continued with there are only warnings
				var warningMatch:Array = data.match(new RegExp("Warning:", "i"));
				if (warningMatch)
				{
                    warning(data);
					return;
				}
				
				var javaToolsOptionsMatch:Array = data.match(new RegExp("JAVA_TOOL_OPTIONS", "i"));
				if (javaToolsOptionsMatch)
				{
					print(data);
					return;
				}

				print(data);
			}
		}
		
		private function shellExit(e:NativeProcessExitEvent):void 
		{
			warning("Compilation of %s finished.", currentProject.projectName);
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
	}
}