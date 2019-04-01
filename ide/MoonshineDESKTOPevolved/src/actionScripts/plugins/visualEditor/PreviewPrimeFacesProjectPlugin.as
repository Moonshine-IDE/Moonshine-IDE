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
package actionScripts.plugins.visualEditor
{
    import actionScripts.events.MavenBuildEvent;
    import actionScripts.events.PreviewPluginEvent;
    import actionScripts.events.ProjectEvent;
    import actionScripts.events.SettingsEvent;
    import actionScripts.events.StatusBarEvent;
    import actionScripts.factory.FileLocation;
    import actionScripts.plugins.maven.MavenBuildPlugin;
    import actionScripts.plugin.build.MavenBuildStatus;
    import actionScripts.utils.MavenPomUtil;
    import actionScripts.utils.UtilsCore;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import actionScripts.valueObjects.FileWrapper;

    import flash.events.Event;

    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;

    import flash.events.IOErrorEvent;

    import flash.events.NativeProcessExitEvent;

    import flash.events.ProgressEvent;
    import flash.net.Socket;

    import flash.net.URLRequest;
    import flash.net.navigateToURL;

    public class PreviewPrimeFacesProjectPlugin extends MavenBuildPlugin
    {
        private static const APP_WAS_DEPLOYED:RegExp = /app was successfully deployed/;
        private static const APP_FAILED:RegExp = /Failed to start, exiting/;
        private static const APP_FAILED_TO_START:RegExp = /Server failed to start/;
        private static const CLOSED:RegExp = /\[CLOSED\]/;

        private const PAYARA_SERVER_BUILD:String = "payaraServerBuild";
        private const URL_PREVIEW:String = "http://localhost:8180/";
        private const PREVIEW_EXTENSION_FILE:String = "xhtml";
        private const LOCAL_HOST:String = "localhost";
        private const PAYARA_SHUTDOWN_PORT:int = 44444;
        private const PAYARA_SHUTDOWN_COMMAND:String = "shutdown";

        private var currentProject:AS3ProjectVO;
        private var newProject:AS3ProjectVO;

        private var filePreview:FileLocation;
        private var newFilePreview:FileLocation;

        private var payaraShutdownSocket:Socket;

        public function PreviewPrimeFacesProjectPlugin()
        {
            super();
        }

        override public function get name():String { return "Start Preview of PrimeFaces project"; }
        override public function get author():String { return "Moonshine Project Team"; }
        override public function get description():String { return "Preview PrimeFaces project."; }

        override public function activate():void
        {
            super.activate();

            dispatcher.addEventListener(PreviewPluginEvent.START_VISUALEDITOR_PREVIEW, previewVisualEditorFileHandler);
            dispatcher.addEventListener(PreviewPluginEvent.STOP_VISUALEDITOR_PREVIEW, stopVisualEditorPreviewHandler);
            dispatcher.addEventListener(ProjectEvent.REMOVE_PROJECT, closeProjectHandler);
        }

        override public function deactivate():void
        {
            super.deactivate();

            dispatcher.addEventListener(PreviewPluginEvent.START_VISUALEDITOR_PREVIEW, previewVisualEditorFileHandler);
        }

        override public function complete():void
        {
            if (status == MavenBuildStatus.STOPPED) return;

            status = MavenBuildStatus.COMPLETE;
            startPreview();

            dispatcher.dispatchEvent(new PreviewPluginEvent(PreviewPluginEvent.PREVIEW_START_COMPLETE, null, currentProject));
        }

        override public function stop(forceStop:Boolean = false):void
        {
            if (!running && status != MavenBuildStatus.COMPLETE)
            {
                warning("Preview is not running.");
                return;
            }

            if (status == MavenBuildStatus.COMPLETE)
            {
                payaraShutdownSocket = new Socket(LOCAL_HOST, PAYARA_SHUTDOWN_PORT);
                payaraShutdownSocket.addEventListener(Event.CONNECT, onPayaraShutdownSocketConnect);
                payaraShutdownSocket.addEventListener(IOErrorEvent.IO_ERROR, onPayaraShutdownSocketIOError);
            }
            else
            {
                super.stop(forceStop);

                dispatcher.dispatchEvent(new PreviewPluginEvent(PreviewPluginEvent.PREVIEW_STOPPED, null, currentProject));
            }
        }

        override protected function startConsoleBuildHandler(event:Event):void
        {

        }

        override protected function stopConsoleBuildHandler(event:Event):void
        {

        }

        override protected function onNativeProcessStandardErrorData(event:ProgressEvent):void
        {
            var data:String = getDataFromBytes(nativeProcess.standardError);
            processOutput(data);

            if (status == MavenBuildStatus.COMPLETE)
            {
                dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
                running = false;
            }
        }

        override protected function onNativeProcessExit(event:NativeProcessExitEvent):void
        {
            removeNativeProcessEventListeners();

            if (!stopWithoutMessage)
            {
                var info:String = isNaN(event.exitCode) ?
                        "Maven build has been terminated." :
                        "Maven build has been terminated with exit code: " + event.exitCode;

                warning(info);
            }

            stopWithoutMessage = false;
            dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));

            if (status == MavenBuildStatus.COMPLETE)
            {
                dispatcher.dispatchEvent(new MavenBuildEvent(MavenBuildEvent.MAVEN_BUILD_COMPLETE, this.buildId, MavenBuildStatus.COMPLETE));
            }
        }

        override protected function processOutput(data:String):void
        {
            if (projectClosed(data))
            {
                currentProject = this.newProject;
                filePreview = this.newFilePreview;
                prepareProjectForPreviewing();
                return;
            }
            else
            {
                super.processOutput(data);
            }
        }

        override protected function buildFailed(data:String):Boolean
        {
            var failed:Boolean = super.buildFailed(data);
            if (!failed)
            {
                if (data.match(APP_FAILED) || data.match(APP_FAILED_TO_START))
                {
                    stop();
                    dispatcher.dispatchEvent(new MavenBuildEvent(MavenBuildEvent.MAVEN_BUILD_FAILED, this.buildId, MavenBuildStatus.FAILED));

                    failed = true;
                }
            }

            return failed;
        }

        override protected function buildSuccess(data:String):void
        {
            super.buildSuccess(data);

            if (data.match(APP_WAS_DEPLOYED))
            {
                complete();
                warning("Preview server has been successfully started for project %s", currentProject.name);
            }
        }

        private function onPayaraShutdownSocketIOError(event:IOErrorEvent):void
        {
            payaraShutdownSocket.removeEventListener(Event.CONNECT, onPayaraShutdownSocketConnect);
            payaraShutdownSocket.removeEventListener(IOErrorEvent.IO_ERROR, onPayaraShutdownSocketIOError);

            error("Shutdown socket connection error %s", event.text);

            if (payaraShutdownSocket.connected)
            {
                payaraShutdownSocket.close();
                payaraShutdownSocket = null;
            }

            dispatcher.dispatchEvent(new PreviewPluginEvent(PreviewPluginEvent.PREVIEW_STOPPED, null, currentProject));
        }

        private function onPayaraShutdownSocketConnect(event:Event):void
        {
            payaraShutdownSocket.removeEventListener(Event.CONNECT, onPayaraShutdownSocketConnect);
            payaraShutdownSocket.removeEventListener(IOErrorEvent.IO_ERROR, onPayaraShutdownSocketIOError);

            payaraShutdownSocket.writeUTFBytes(PAYARA_SHUTDOWN_COMMAND);
            payaraShutdownSocket.flush();

            payaraShutdownSocket.close();
            payaraShutdownSocket = null;

            dispatcher.dispatchEvent(new PreviewPluginEvent(PreviewPluginEvent.PREVIEW_STOPPED, null, currentProject));
        }

        private function previewVisualEditorFileHandler(event:PreviewPluginEvent):void
        {
            var newProject:AS3ProjectVO = null;
            if (event.fileWrapper is FileWrapper)
            {
                newProject = UtilsCore.getProjectFromProjectFolder(event.fileWrapper as FileWrapper) as AS3ProjectVO;
            }
            else
            {
                newProject = event.project;
            }

            if (!newProject)
            {
                return;
            }

            if (currentProject && currentProject != newProject)
            {
                this.newProject = newProject;
                this.newFilePreview = event.fileWrapper.file;

                stop(true);
                return;
            }

            var executableJavaLocation:FileLocation = UtilsCore.getExecutableJavaLocation();
            if (!executableJavaLocation)
            {
                running = false;
                error("In order to run preview server you have to specify Java Development Kit path.");
                dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, "actionScripts.plugins.as3project.mxmlc::MXMLCPlugin"));
                return;
            }

            if (!model.payaraServerLocation)
            {
                warning("Server for PrimeFaces preview has not been setup");
                return;
            }

            this.newProject = null;
            this.newFilePreview = null;

            if (event.fileWrapper is FileWrapper)
            {
                filePreview = event.fileWrapper.file;
            }
            else
            {
                filePreview = event.fileWrapper as FileLocation;
            }

            currentProject = newProject;

            if (status == MavenBuildStatus.COMPLETE && status != MavenBuildStatus.STOPPED)
            {
                startPreview();
            }
            else
            {
                prepareProjectForPreviewing();
            }
        }

        private function stopVisualEditorPreviewHandler(event:Event):void
        {
            if (!currentProject) return;

            stop(true);
        }

        private function closeProjectHandler(event:ProjectEvent):void
        {
            if (event.project == currentProject)
            {
                dispatcher.dispatchEvent(new MavenBuildEvent(MavenBuildEvent.STOP_MAVEN_BUILD, null, MavenBuildStatus.STOPPED));

                stopWithoutMessage = true;
                stop();
            }
        }

        private function onMavenBuildComplete(event:MavenBuildEvent):void
        {
            dispatcher.removeEventListener(MavenBuildEvent.MAVEN_BUILD_COMPLETE, onMavenBuildComplete);
            dispatcher.removeEventListener(MavenBuildEvent.MAVEN_BUILD_FAILED, onMavenBuildFailed);

            preparePreviewServer();
        }

        private function onMavenBuildFailed(event:MavenBuildEvent):void
        {
            error("Starting Preview has been stopped");

            dispatcher.removeEventListener(MavenBuildEvent.MAVEN_BUILD_COMPLETE, onMavenBuildComplete);
            dispatcher.removeEventListener(MavenBuildEvent.MAVEN_BUILD_FAILED, onMavenBuildFailed);

            running = false;
        }

        private function prepareProjectForPreviewing():void
        {
            if (!currentProject && !filePreview) return;

            this.newProject = null;
            this.newFilePreview = null;

            dispatcher.addEventListener(MavenBuildEvent.MAVEN_BUILD_COMPLETE, onMavenBuildComplete);
            dispatcher.addEventListener(MavenBuildEvent.MAVEN_BUILD_FAILED, onMavenBuildFailed);

            dispatcher.dispatchEvent(new Event(MavenBuildEvent.START_MAVEN_BUILD));
        }

        private function preparePreviewServer():void
        {
            if (!currentProject) return;

            var preCommands:Array = this.getPreRunPreviewServerCommands();
            var commands:Array = ["compile", "exec:exec"];

            buildId = PAYARA_SERVER_BUILD;
            prepareStart(buildId, preCommands, commands, model.payaraServerLocation);
        }

        private function startPreview():void
        {
            if (!currentProject || !filePreview) return;

            var fileName:String = filePreview.fileBridge.nativePath.replace(currentProject.sourceFolder.fileBridge.nativePath, "");
            if (filePreview.fileBridge.isDirectory)
            {
                fileName = currentProject.name.concat(".", PREVIEW_EXTENSION_FILE);
                var mainFile:FileLocation = currentProject.targets[0];
                if (!mainFile.fileBridge.exists)
                {
                    warning("Project does not contains main file. Choose specific file for preview.");
                    return;
                }
            }

            var urlReq:URLRequest = new URLRequest(URL_PREVIEW.concat(fileName));
            navigateToURL(urlReq);
        }

        private function getPreRunPreviewServerCommands():Array
        {
            var executableJavaLocation:FileLocation = UtilsCore.getExecutableJavaLocation();
            var prefixSet:String = ConstantsCoreVO.IS_MACOS ? "export" : "set";

            return [prefixSet.concat(" JAVA_EXEC=", executableJavaLocation.fileBridge.nativePath),
                    prefixSet.concat(" TARGET_PATH=", getMavenBuildProjectPath())];
        }

        private function getMavenBuildProjectPath():String
        {
            if (!currentProject) return null;

            var projectPomFile:FileLocation = new FileLocation(currentProject.mavenBuildOptions.mavenBuildPath).resolvePath("pom.xml");

            var artifactId:String = MavenPomUtil.getProjectId(projectPomFile);
            var version:String = MavenPomUtil.getProjectVersion(projectPomFile);

            var separator:String = projectPomFile.fileBridge.separator;

            return currentProject.folderLocation.fileBridge.nativePath.concat(separator, "target", separator, artifactId, "-", version);
        }

        private function projectClosed(data:String):Boolean
        {
            if (data.match(CLOSED))
            {
                stopWithoutMessage = true;
                super.stop(true);

                warning("Preview server for project %s has been shutdown.", currentProject.name);

                filePreview = null;
                currentProject = null;

                return true;
            }

            return false;
        }
    }
}
