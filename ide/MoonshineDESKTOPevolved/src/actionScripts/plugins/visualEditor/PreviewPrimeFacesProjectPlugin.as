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
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.PluginBase;
    import actionScripts.plugins.maven.MavenBuildPlugin;
    import actionScripts.utils.UtilsCore;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import actionScripts.valueObjects.FileWrapper;
    import flash.events.Event;

    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;

    import flash.events.ProgressEvent;

    public class PreviewPrimeFacesProjectPlugin extends PluginBase
    {
        private const PAYARA_SERVER_BUILD:String = "payaraServerBuild";

        private var _currentProject:AS3ProjectVO;
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
        }

        override public function deactivate():void
        {
            super.deactivate();

            dispatcher.addEventListener(PreviewPluginEvent.PREVIEW_PRIMEFACES_FILE, previewPrimeFacesFileHandler);
        }

        private function previewPrimeFacesFileHandler(event:PreviewPluginEvent):void
        {
            if (running)
            {
                warning("Starting Preview is in progress...");
                return;
            }

            running = true;
            _currentProject = UtilsCore.getProjectFromProjectFolder(event.fileWrapper as FileWrapper) as AS3ProjectVO;
            if (!_currentProject) return;

            if (!model.payaraServerLocation)
            {
                warning("Server for PrimeFaces preview has not been setup");
                return;
            }

            preparePreviewServer();
        }

        private function preparePreviewServer():void
        {
            dispatcher.addEventListener(MavenBuildEvent.MAVEN_BUILD_COMPLETE, onMavenBuildComplete);
            dispatcher.addEventListener(MavenBuildEvent.MAVEN_BUILD_FAILED, onMavenBuildFailed);

            dispatcher.dispatchEvent(new Event(MavenBuildEvent.START_MAVEN_BUILD));
        }

        private function runPreviewServer():void
        {
            var preCommands:Array = this.getPreRunPreviewServerCommands();
            var commands:Array = ["compile", "exec:exec"];

            dispatcher.dispatchEvent(new MavenBuildEvent(MavenBuildEvent.START_MAVEN_BUILD,
                    PAYARA_SERVER_BUILD, model.payaraServerLocation.fileBridge.nativePath, preCommands, commands));
        }

        private function onMavenBuildComplete(event:MavenBuildEvent):void
        {
            if (event.buildId == PAYARA_SERVER_BUILD)
            {
                dispatcher.removeEventListener(MavenBuildEvent.MAVEN_BUILD_COMPLETE, onMavenBuildComplete);
                dispatcher.removeEventListener(MavenBuildEvent.MAVEN_BUILD_FAILED, onMavenBuildFailed);
            }
            else
            {
                runPreviewServer();
            }
        }

        private function onMavenBuildFailed(event:MavenBuildEvent):void
        {
            error("Starting Preview has been stopped");

            dispatcher.removeEventListener(MavenBuildEvent.MAVEN_BUILD_COMPLETE, onMavenBuildComplete);
            dispatcher.removeEventListener(MavenBuildEvent.MAVEN_BUILD_FAILED, onMavenBuildFailed);

            running = false;
        }

        private function  getPreRunPreviewServerCommands():Array
        {
            var executableJavaLocation:FileLocation = UtilsCore.getExecutableJavaLocation();
            var prefixSet:String = ConstantsCoreVO.IS_MACOS ? "export" : "set";

            return [prefixSet.concat(" JAVA_EXEC=", executableJavaLocation.fileBridge.nativePath),
                    prefixSet.concat(" TARGET_PATH=", "\"", getMavenBuildProjectPath(), "\"")];
        }

        private function getMavenBuildProjectPath():String
        {
            var projectPomFile:FileLocation = new FileLocation(_currentProject.mavenBuildOptions.mavenBuildPath).resolvePath("pom.xml");
            var pom:XML = XML(projectPomFile.fileBridge.read());

            var artifactId:String = pom.elements(new QName("http://maven.apache.org/POM/4.0.0", "artifactId"))[0];
            var version:String = pom.elements(new QName("http://maven.apache.org/POM/4.0.0", "version"))[0];

            var separator:String = projectPomFile.fileBridge.separator;

            return _currentProject.folderLocation.fileBridge.nativePath.concat(separator, "target", separator, artifactId, "-", version);
        }
    }
}
