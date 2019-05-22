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
package actionScripts.plugins.ant
{
    import flash.desktop.NativeProcess;
    import flash.desktop.NativeProcessStartupInfo;
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.NativeProcessExitEvent;
    import flash.events.ProgressEvent;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.utils.ByteArray;
    import flash.utils.IDataInput;
    
    import mx.collections.ArrayCollection;
    import mx.controls.Alert;
    import mx.core.FlexGlobals;
    import mx.core.IFlexDisplayObject;
    import mx.events.CloseEvent;
    import mx.managers.PopUpManager;
    
    import actionScripts.events.AddTabEvent;
    import actionScripts.events.NewFileEvent;
    import actionScripts.events.RefreshTreeEvent;
    import actionScripts.events.RunANTScriptEvent;
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.IPlugin;
    import actionScripts.plugin.PluginBase;
    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
    import actionScripts.plugin.settings.ISettingsProvider;
    import actionScripts.plugin.settings.vo.AbstractSetting;
    import actionScripts.plugin.settings.vo.ISetting;
    import actionScripts.plugin.settings.vo.PathSetting;
    import actionScripts.plugins.ant.events.AntBuildEvent;
    import actionScripts.ui.IContentWindow;
    import actionScripts.ui.editor.text.TextLineModel;
    import actionScripts.ui.tabview.CloseTabEvent;
    import actionScripts.utils.EnvironmentSetupUtils;
    import actionScripts.utils.HelperUtils;
    import actionScripts.utils.HtmlFormatter;
    import actionScripts.utils.UtilsCore;
    import actionScripts.valueObjects.ComponentTypes;
    import actionScripts.valueObjects.ComponentVO;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import actionScripts.valueObjects.Settings;
    
    import components.popup.SelectAntFile;
    import components.popup.SelectOpenedFlexProject;

    public class AntBuildPlugin extends PluginBase implements IPlugin, ISettingsProvider
    {
        public static const EVENT_ANTBUILD:String = "antbuildEvent";
        public static const SELECTED_PROJECT_ANTBUILD:String = "selectedProjectAntBuild";

        override public function get name():String
        {
            return "Ant Build Setup";
        }

        override public function get author():String
        {
            return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team";
        }

        override public function get description():String
        {
            return "Apache Ant® Build Plugin. Esc exits.";
        }

        private var cmdFile:File;
        private var shellInfo:NativeProcessStartupInfo;
        private var nativeProcess:NativeProcess;
        private var errors:String = "";
        private var exiting:Boolean = false;
        private var antPath:String = "ant";
        private var workingDir:FileLocation;
        private var selectProjectPopup:SelectOpenedFlexProject;
        private var selectAntPopup:SelectAntFile;
        private var antFiles:ArrayCollection = new ArrayCollection();
        private var currentSDK:FileLocation;
        private var antBuildScreen:IFlexDisplayObject;
        private var isASuccessBuild:Boolean;
        private var selectedProject:AS3ProjectVO;
		private var pathSetting:PathSetting;

        private var _antHomePath:String;
        private var _buildWithAnt:Boolean;

        public function AntBuildPlugin()
        {
            if (Settings.os == "win")
            {
                // in windows
                antPath += ".bat";
                cmdFile = new File("c:\\Windows\\System32\\cmd.exe");
            }
            else
            {
                // in mac
                cmdFile = new File("/bin/bash");
            }
        }

        public function get antHomePath():String
        {
            if ((_antHomePath == "" || !_antHomePath) && ConstantsCoreVO.IS_HELPER_DOWNLOADED_ANT_PRESENT)
            {
                antHomePath = ConstantsCoreVO.IS_HELPER_DOWNLOADED_ANT_PRESENT.nativePath;
            }

            return _antHomePath;
        }

        public function set antHomePath(value:String):void
        {
            _antHomePath = value;
            if (_antHomePath == "")
            {
                model.antHomePath = null;
            }
            else
            {
                model.antHomePath = new FileLocation(value);
				EnvironmentSetupUtils.getInstance().updateToCurrentEnvironmentVariable();
            }
        }

        override public function activate():void
        {
            super.activate();

            dispatcher.addEventListener(RunANTScriptEvent.ANT_BUILD, runAntScriptHandler);
            dispatcher.addEventListener(NewFileEvent.EVENT_ANT_BIN_URL_SET, onAntURLSet);
            dispatcher.addEventListener(SELECTED_PROJECT_ANTBUILD, antBuildForSelectedProject);
            dispatcher.addEventListener(EVENT_ANTBUILD, antBuildFileHandler);

            reset();
        }

        public function getSettingsList():Vector.<ISetting>
        {
			onSettingsClose();
			pathSetting = new PathSetting(this, 'antHomePath', 'Ant Home', true, antHomePath);
			pathSetting.addEventListener(AbstractSetting.PATH_SELECTED, onSDKPathSelected, false, 0, true);
			
            return Vector.<ISetting>([
                pathSetting
            ]);
        }
		
		override public function onSettingsClose():void
		{
			if (pathSetting)
			{
				pathSetting.removeEventListener(AbstractSetting.PATH_SELECTED, onSDKPathSelected);
				pathSetting = null;
			}
		}

        override public function deactivate():void
        {
            super.deactivate();
            reset();
        }

        override public function resetSettings():void
        {
            model.antScriptFile = null;
            antHomePath = "";
        }

        private function reset():void
        {
            stopShell();
            shellInfo = null;
            isASuccessBuild = false;
            selectedProject = null;
            model.antScriptFile = null;
        }
		
		private function onSDKPathSelected(event:Event):void
		{
			if (!pathSetting.stringValue) return;
			var tmpComponent:ComponentVO = HelperUtils.getComponentByType(ComponentTypes.TYPE_ANT);
			if (tmpComponent)
			{
				var isValidSDKPath:Boolean = HelperUtils.isValidSDKDirectoryBy(ComponentTypes.TYPE_ANT, pathSetting.stringValue, tmpComponent.pathValidation);
				if (!isValidSDKPath)
				{
					pathSetting.setMessage("Invalid path: Directory must contain "+ tmpComponent.pathValidation +".", AbstractSetting.MESSAGE_CRITICAL);
				}
				else
				{
					pathSetting.setMessage(null);
				}
			}
		}

        private function onAntURLSet(event:NewFileEvent):void
        {
            antHomePath = event.filePath;
        }

        // Call from Ant->Ant build Menu
        private function antBuildFileHandler(event:Event):void
        {
            _buildWithAnt = false;
            antBuildHandler();
        }

        //Call from Project explorer
        private function runAntScriptHandler(event:Event):void
        {
            if (!model.antScriptFile.fileBridge.checkFileExistenceAndReport()) return;

            _buildWithAnt = true;
            selectedProject = model.activeProject as AS3ProjectVO;

            antBuildHandler();
        }

        protected function antBuildHandler():void
        {
            // To check if custom sdk is set or not
            if (_buildWithAnt)
            {
                if (selectedProject)
                {
                    currentSDK = getCurrentSDK(selectedProject);
                }
            }
            else
            {
                currentSDK = model.defaultSDK;
            }
            //If Flex_HOME or ANT_HOME is missing
            if (!currentSDK || !UtilsCore.isAntAvailable())
            {
                for each (var tab:IContentWindow in model.editors)
                {
                    if (tab["className"] == "AntBuildScreen")
                    {
                        model.activeEditor = tab;
                        if (currentSDK)
                            (antBuildScreen as AntBuildScreen).customSDKAvailable = true;
                        (antBuildScreen as AntBuildScreen).refreshValue();
                        return;
                    }
                }
                antBuildScreen = model.flexCore.getNewAntBuild();
                antBuildScreen.addEventListener(AntBuildEvent.ANT_BUILD, antBuildSelected);

                if (currentSDK)
                {
                    (antBuildScreen as AntBuildScreen).customSDKAvailable = true;
                }

                dispatcher.dispatchEvent(new AddTabEvent(antBuildScreen as IContentWindow));
            }
            else
            {
                antBuildSelected(null);// Start Ant Process
            }
        }

        // For projec Menu
        private function antBuildForSelectedProject(event:Event):void
        {
            _buildWithAnt = true;

            if (model.mainView.isProjectViewAdded)
            {
                selectedProject = model.activeProject as AS3ProjectVO;
                //If any project from treeview is selected
                if (selectedProject)
                {
                    checkForAntFile(selectedProject);
                }
                else
                {
                    //Popup of project list if there is not any selected project in Project explorer
                    selectProjectPopup = new SelectOpenedFlexProject();
                    PopUpManager.addPopUp(selectProjectPopup, FlexGlobals.topLevelApplication as DisplayObject, false);
                    PopUpManager.centerPopUp(selectProjectPopup);
                    selectProjectPopup.addEventListener(SelectOpenedFlexProject.PROJECT_SELECTED, onProjectSelected);
                    selectProjectPopup.addEventListener(SelectOpenedFlexProject.PROJECT_SELECTION_CANCELLED, onProjectSelectionCancelled);
                }
            }
        }


        private function onProjectSelected(event:Event):void
        {
            this.selectedProject = event.currentTarget.selectedProject;

            checkForAntFile(selectProjectPopup.selectedProject as AS3ProjectVO);
            onProjectSelectionCancelled(null);
        }

        private function onProjectSelectionCancelled(event:Event):void
        {
            selectProjectPopup.removeEventListener(SelectOpenedFlexProject.PROJECT_SELECTED, onProjectSelected);
            selectProjectPopup.removeEventListener(SelectOpenedFlexProject.PROJECT_SELECTION_CANCELLED, onProjectSelectionCancelled);
            selectProjectPopup = null;
        }

        private function onAntFileSelected(event:Event):void
        {
            //Start build which is selected from Popup
            model.antScriptFile = selectAntPopup.selectedAntFile;
            antBuildHandler();
        }

        private function onAntFileSelectionCancelled(event:Event):void
        {
            selectAntPopup.removeEventListener(SelectAntFile.ANTFILE_SELECTED, onAntFileSelected);
            selectAntPopup.removeEventListener(SelectAntFile.ANTFILE_SELECTION_CANCELLED, onAntFileSelectionCancelled);
            selectAntPopup = null;
        }

        private function checkForAntFile(selectedAntProject:AS3ProjectVO):void
        {
            // Check if Ant file is set for project or not
            var buildFlag:Boolean = false;
            var AntFlag:Boolean = false;
            antFiles = new ArrayCollection();
            if (!selectedAntProject.antBuildPath)
            {
                // Find build folder within the selected folder
                //find for build.xml file with <project> tag
                for (var i:int = 0; i < selectedAntProject.projectFolder.children.length; i++)
                {
                    if (selectedAntProject.projectFolder.children[i].name == "build")
                    {
                        buildFlag = true;
                        for (var j:int = 0; j < selectedAntProject.projectFolder.children[i].children.length; j++)
                        {
                            if (selectedAntProject.projectFolder.children[i].children[j].file.fileBridge.extension == "xml")
                            {
                                var str:String = selectedAntProject.projectFolder.children[i].children[j].file.fileBridge.read().toString();
                                if ((str.search("<project ") != -1) || (str.search("<project>") != -1))
                                {
                                    // Add xml files in AC.
                                    AntFlag = true;
                                    antFiles.addItem(selectedAntProject.projectFolder.children[i].children[j].file);
                                }
                            }
                        }
                    }
                }
            }
            else
            {
                var antFile:FileLocation = selectedAntProject.folderLocation.resolvePath(selectedAntProject.antBuildPath);
                if (antFile.fileBridge.exists)
                {
                    model.antScriptFile = selectedAntProject.folderLocation.resolvePath(selectedAntProject.antBuildPath);
                    antBuildHandler();
                    return;
                }
                else
                {
                    var buildDir:FileLocation = antFile.fileBridge.parent;
                    if (buildDir.fileBridge.exists)
                        buildFlag = true;
                    AntFlag = false;
                }
            }

            if (buildFlag)
            {
                if (!AntFlag)
                {
                    Alert.yesLabel = "Choose Ant File";
                    Alert.buttonWidth = 150;
                    Alert.show("There is no Ant file found in the selected Project", "Ant File", Alert.YES | Alert.CANCEL, null, alertListener, null, Alert.CANCEL);

                    function alertListener(eventObj:CloseEvent):void
                    {
                        // Check to see if the OK button was pressed.
                        if (eventObj.detail == Alert.YES)
                        {
                            model.antScriptFile = null;
                            antBuildHandler();
                        }
                        else
                        {
                            return;
                        }
                    }
                }
                else
                {
                    if (antFiles.length > 1)
                    {
                        //Open a popup for select Ant file
                        selectAntPopup = new SelectAntFile();
                        PopUpManager.addPopUp(selectAntPopup, FlexGlobals.topLevelApplication as DisplayObject, false);
                        PopUpManager.centerPopUp(selectAntPopup);
                        selectAntPopup.antFiles = antFiles;
                        selectAntPopup.addEventListener(SelectAntFile.ANTFILE_SELECTED, onAntFileSelected);
                        selectAntPopup.addEventListener(SelectAntFile.ANTFILE_SELECTION_CANCELLED, onAntFileSelectionCancelled);
                    }
                    else
                    {
                        //Start Ant build if there is only one ant file
                        // Set Ant file in ModelLocatior
                        model.antScriptFile = antFiles.getItemAt(0) as FileLocation;
                        antBuildHandler();
                    }
                }
            }
            else
            {
                // build flag flase
                {
                    Alert.buttonWidth = 65;
                    Alert.show("There is no Build folder in selected Project");
                }
            }

        }

        private function antBuildSelected(event:AntBuildEvent):void
        {
            if (event)
            {
                if (event.selectSDK)
                {
                    currentSDK = event.selectSDK;
                }

                if (event.antHome)
                {
                    antHomePath = event.antHome.fileBridge.nativePath;
                }

                if (antBuildScreen)
                {
                    dispatcher.dispatchEvent(
                            new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, antBuildScreen as DisplayObject)
                    );
                }
            }

            if (!model.antScriptFile)
            {
                // Open a file chooser for select Ant script file Ant->Configue
                model.fileCore.browseForOpen("Select Build File", selectBuildFile, null, ["*.xml"]);
            }
            else
            {   //If Ant file is already selected from AntScreen
                workingDir = new FileLocation(model.antScriptFile.fileBridge.nativePath);
                startAntProcess(workingDir);
            }

            if (antBuildScreen)
            {
                antBuildScreen.removeEventListener(AntBuildEvent.ANT_BUILD, antBuildSelected);
            }
        }

        protected function selectBuildFile(fileSelected:Object):void
        {
            // If file is open already, just focus that editor.
            startAntProcess(new FileLocation(fileSelected.nativePath));
        }

        private function getCurrentSDK(pvo:AS3ProjectVO):FileLocation
        {
            return pvo.buildOptions.customSDK ? new FileLocation(pvo.buildOptions.customSDK.fileBridge.getFile.nativePath) : (model.defaultSDK ? new FileLocation(model.defaultSDK.fileBridge.getFile.nativePath) : null);
        }

        private function startAntProcess(buildDir:FileLocation):void
        {
            var antBatPath:String = getAntBatPath();
			var sdkPath:String = UtilsCore.convertString(currentSDK.fileBridge.nativePath);
            var buildDirPath:String = buildDir.fileBridge.nativePath;
			var compileStr:String = "";

            var isFlexJSProject:Boolean = currentSDK.resolvePath("js/bin/mxmlc").fileBridge.exists;
            var isApacheRoyaleSDK:Boolean = currentSDK.resolvePath("frameworks/royale-config.xml").fileBridge.exists;
            var isFlexJSAfter7Arg:String = "";
            var isApacheRoyaleArg:String = "";

            if (!isApacheRoyaleSDK && isFlexJSProject)
            {
                if (UtilsCore.isNewerVersionSDKThan(7, currentSDK.fileBridge.nativePath))
                {
                    isFlexJSAfter7Arg = " -DIS_FLEXJS_AFTER_7=true";
                }
            }

            if (isApacheRoyaleSDK)
            {
                isApacheRoyaleArg = " -DIS_APACHE_ROYALE=true";
                isFlexJSAfter7Arg = " -DIS_FLEXJS_AFTER_7=true";
            }

            if (Settings.os == "win")
            {
                //Create file with following content:
                var antBuildRunnerPath:String = prepareAntBuildRunnerFile(buildDirPath);

                //Created file is being run
				compileStr = compileStr.concat(
					antBuildRunnerPath + isFlexJSAfter7Arg + isApacheRoyaleArg
				);
            }
            else
            {
				compileStr = compileStr.concat(
					antBatPath + " -file " + UtilsCore.convertString(buildDirPath) + isFlexJSAfter7Arg + isApacheRoyaleArg
				);
            }
			
			EnvironmentSetupUtils.getInstance().initCommandGenerationToSetLocalEnvironment(onEnvironmentPrepared, sdkPath, [compileStr]);

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
				shellInfo.workingDirectory = buildDir.fileBridge.parent.fileBridge.getFile as File;
				
				initShell();
				
				if (ConstantsCoreVO.IS_MACOS)
				{
					debug("SDK path: %s", currentSDK.fileBridge.nativePath);
					print(compileStr);
				}
			}
        }

        private function prepareAntBuildRunnerFile(buildDirPath:String):String
        {
            var antBatPath:String = getAntBatPath();
            var buildRunnerFileName:String = "AntBuildRunner.bat";

            if (buildDirPath.indexOf(" ") > -1)
            {
                try
                {
                    var fileContent:String = antBatPath + " -f \"" + buildDirPath + "\"";
                    var antBuildRunnerFile:File = new File(File.cacheDirectory.nativePath).resolvePath(buildRunnerFileName);
                    var fileContentArray:ByteArray = new ByteArray();
                    fileContentArray.writeUTFBytes(fileContent);
                    var fileRef:FileStream = new FileStream();
                    fileRef.open(antBuildRunnerFile, FileMode.WRITE);
                    fileRef.writeBytes(fileContentArray);
                    fileRef.close();

                    return antBuildRunnerFile.nativePath;
                }
                catch (e:Error)
                {

                }
            }

            return antBatPath + " -f " + buildDirPath;
        }

        private function initShell():void
        {
            if (nativeProcess)
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
            if (ConstantsCoreVO.IS_CONSOLE_CLEARED_ONCE) clearOutput();
            ConstantsCoreVO.IS_CONSOLE_CLEARED_ONCE = true;

            nativeProcess = new NativeProcess();
            nativeProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);
            nativeProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
            nativeProcess.addEventListener(NativeProcessExitEvent.EXIT, shellExit);
            nativeProcess.start(shellInfo);
            print("Ant build Running");
        }

        private function shellData(e:ProgressEvent):void
        {
            var output:IDataInput = nativeProcess.standardOutput;
            var data:String = output.readUTFBytes(output.bytesAvailable);

            var match:Array = data.match(/nativeProcess: Target \d not found/);
            if (match)
            {
                error("Target not found. Try again.");
            }

            match = data.match(/nativeProcess: Assigned (\d) as the compile target id/);
            if (data)
            {

                match = data.match(/(.*) \(\d+? bytes\)/);
                if (match)
                {
                    // Successful Build
                    print("Done");

                }
            }
            if (data == "(nativeProcess) ")
            {
                if (errors != "")
                {
                    compilerError(errors);
                    errors = "";
                }
            }

            match = data.match(/BUILD SUCCESSFUL/);
            if (match)
            {
                isASuccessBuild = true;
            }

            if (data.charAt(data.length - 1) == "\n") data = data.substr(0, data.length - 1);

            debug("%s", data);
        }

        private function shellError(e:ProgressEvent):void
        {
            var output:IDataInput = nativeProcess.standardError;
            var data:String = output.readUTFBytes(output.bytesAvailable);

            var syntaxMatch:Array;
            var generalMatch:Array;
            print(data);
            syntaxMatch = data.match(/(.*?)\((\d*)\): col: (\d*) Error: (.*).*/);
            if (syntaxMatch)
            {
                var pathStr:String = syntaxMatch[1];
                var lineNum:int = syntaxMatch[2];
                var errorStr:String = syntaxMatch[4];
                pathStr = pathStr.substr(pathStr.lastIndexOf("/") + 1);
                errors += HtmlFormatter.sprintf("%s<weak>:</weak>%s \t %s\n",
                        pathStr, lineNum, errorStr);
            }

            generalMatch = data.match(/(.*?): Error: (.*).*/);
            if (!syntaxMatch && generalMatch)
            {
                pathStr = generalMatch[1];
                errorStr = generalMatch[2];
                pathStr = pathStr.substr(pathStr.lastIndexOf("/") + 1);

                errors += HtmlFormatter.sprintf("%s: %s", pathStr, errorStr);
            }

            debug("%s", data);
        }

        private function shellExit(e:NativeProcessExitEvent):void
        {
            debug("FSCH exit code: %s", e.exitCode);
            if (exiting)
            {
                exiting = false;
                startShell();
            }

            if (isASuccessBuild && selectedProject)
            {
                print("Files produced under DEPLOY folder.");
                // refresh the build folder
                dispatcher.dispatchEvent(new RefreshTreeEvent(selectedProject.folderLocation.resolvePath("build")));
            }

            reset();
        }

        private function stopShell():void
        {
            if (!nativeProcess) return;
            if (nativeProcess.running)
            {
                nativeProcess.exit();
            }

            nativeProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);
            nativeProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
            nativeProcess.removeEventListener(NativeProcessExitEvent.EXIT, shellExit);
            nativeProcess = null;
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
                var lineModel:TextLineModel = new TextLineModel(text);
                lines.push(lineModel);
            }
            outputMsg(lines);
        }

        private function getAntBatPath():String
        {
            var antFile:FileLocation = model.antHomePath.resolvePath(antPath);
            if (!antFile.fileBridge.exists)
            {
                antFile = model.antHomePath.resolvePath("bin/" + antPath);
            }

            return UtilsCore.convertString(antFile.fileBridge.nativePath);
        }
    }
}
