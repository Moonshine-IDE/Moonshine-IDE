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
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.PluginBase;
    import actionScripts.plugins.maven.MavenBuildStatus;
    import actionScripts.utils.UtilsCore;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import actionScripts.valueObjects.FileWrapper;
    import flash.events.Event;

    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;

    import flash.net.URLRequest;
    import flash.net.navigateToURL;

    public class PreviewPrimeFacesProjectPlugin extends PluginBase
    {
        private const PAYARA_SERVER_BUILD:String = "payaraServerBuild";
        private const URL_PREVIEW:String = "http://localhost:8180/";
        private const PREVIEW_EXTENSION_FILE:String = "xhtml";

        private var _currentProject:AS3ProjectVO;
        private var _filePreview:FileLocation;

        private var running:Boolean;

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

            dispatcher.addEventListener(PreviewPluginEvent.PREVIEW_PRIMEFACES_FILE, previewPrimeFacesFileHandler);
            dispatcher.addEventListener(ProjectEvent.REMOVE_PROJECT, closeProjectHandler);
        }

        override public function deactivate():void
        {
            super.deactivate();

            dispatcher.addEventListener(PreviewPluginEvent.PREVIEW_PRIMEFACES_FILE, previewPrimeFacesFileHandler);
        }

        private function previewPrimeFacesFileHandler(event:PreviewPluginEvent):void
        {
            _filePreview = event.fileWrapper.file;
            _currentProject = UtilsCore.getProjectFromProjectFolder(event.fileWrapper as FileWrapper) as AS3ProjectVO;
            if (!_currentProject) return;

            if (!model.payaraServerLocation)
            {
                warning("Server for PrimeFaces preview has not been setup");
                return;
            }

            if (running)
            {
                startPreview();
            }
            else
            {
                prepareProjectForPreviewing();
            }
        }

        private function closeProjectHandler(event:ProjectEvent):void
        {
            if (event.project == _currentProject)
            {
                dispatcher.dispatchEvent(new MavenBuildEvent(MavenBuildEvent.STOP_MAVEN_BUILD, null, MavenBuildStatus.STOPPED));
                _filePreview = null;
                _currentProject = null;

                running = false;
            }
        }

        private function onMavenBuildComplete(event:MavenBuildEvent):void
        {
            if (event.buildId == PAYARA_SERVER_BUILD)
            {
                dispatcher.removeEventListener(MavenBuildEvent.MAVEN_BUILD_COMPLETE, onMavenBuildComplete);
                dispatcher.removeEventListener(MavenBuildEvent.MAVEN_BUILD_FAILED, onMavenBuildFailed);
                warning("Preview server is running...");

                startPreview();
            }
            else if (!running)
            {
                running = true;
                preparePreviewServer();
            }
        }

        private function prepareProjectForPreviewing():void
        {
            dispatcher.addEventListener(MavenBuildEvent.MAVEN_BUILD_COMPLETE, onMavenBuildComplete);
            dispatcher.addEventListener(MavenBuildEvent.MAVEN_BUILD_FAILED, onMavenBuildFailed);

            dispatcher.dispatchEvent(new Event(MavenBuildEvent.START_MAVEN_BUILD));
        }

        private function preparePreviewServer():void
        {
            var preCommands:Array = this.getPreRunPreviewServerCommands();
            var commands:Array = ["compile", "exec:exec"];

            dispatcher.dispatchEvent(new MavenBuildEvent(MavenBuildEvent.START_MAVEN_BUILD,
                    PAYARA_SERVER_BUILD, MavenBuildStatus.STARTED, model.payaraServerLocation.fileBridge.nativePath, preCommands, commands));
        }

        private function startPreview():void
        {
            var filePath:String = _filePreview.fileBridge.nativePath.replace(_currentProject.sourceFolder.fileBridge.nativePath, "");
            var fileName:String = _filePreview.fileBridge.isDirectory ?
                    _currentProject.name.concat(".", PREVIEW_EXTENSION_FILE) :
                    filePath;

            var urlReq:URLRequest = new URLRequest(URL_PREVIEW.concat(fileName));
            navigateToURL(urlReq);
        }

        private function onMavenBuildFailed(event:MavenBuildEvent):void
        {
            error("Starting Preview has been stopped");

            dispatcher.removeEventListener(MavenBuildEvent.MAVEN_BUILD_COMPLETE, onMavenBuildComplete);
            dispatcher.removeEventListener(MavenBuildEvent.MAVEN_BUILD_FAILED, onMavenBuildFailed);

            running = false;
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
            if (!_currentProject) return null;

            var projectPomFile:FileLocation = new FileLocation(_currentProject.mavenBuildOptions.mavenBuildPath).resolvePath("pom.xml");
            var pom:XML = XML(projectPomFile.fileBridge.read());

            var artifactId:String = pom.elements(new QName("http://maven.apache.org/POM/4.0.0", "artifactId"))[0];
            var version:String = pom.elements(new QName("http://maven.apache.org/POM/4.0.0", "version"))[0];

            var separator:String = projectPomFile.fileBridge.separator;

            return _currentProject.folderLocation.fileBridge.nativePath.concat(separator, "target", separator, artifactId, "-", version);
        }
    }
}
