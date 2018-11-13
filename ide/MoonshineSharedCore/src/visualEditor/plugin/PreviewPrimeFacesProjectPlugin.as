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
package visualEditor.plugin
{
    import actionScripts.events.MavenBuildEvent;
    import actionScripts.events.PreviewPluginEvent;
    import actionScripts.factory.FileLocation;
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.build.ConsoleBuildPluginBase;
    import actionScripts.utils.UtilsCore;
    import actionScripts.valueObjects.FileWrapper;
    import actionScripts.valueObjects.Settings;

    import flash.desktop.NativeProcess;
    import flash.desktop.NativeProcessStartupInfo;

    import flash.events.Event;

    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;

    public class PreviewPrimeFacesProjectPlugin extends ConsoleBuildPluginBase
    {
        private const PAYARA_SERVER_BUILD:String = "payaraServerBuild";

        private var _currentProject:AS3ProjectVO;

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

            if (!model.payaraServerPath)
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

            dispatcher.dispatchEvent(new MavenBuildEvent(MavenBuildEvent.START_MAVEN_BUILD,
                    PAYARA_SERVER_BUILD, model.payaraServerPath.fileBridge.nativePath, ["clean", "compile"]));
        }

        private function runPreviewServer():void
        {
            var execArgs:String = "-Dexec.args=\"-classpath %classpath " +
                    "-Dnet.prominic.project=" + getMavenBuildProjectPath() +
                    " net.prominic.PayaraEmbeddedLauncher\"";
            var execExecutable:String = "-Dexec.executable=".concat("\"", model.javaPathForTypeAhead.fileBridge.nativePath, "\"");
            var mavenPlugin:String = "org.codehaus.mojo:exec-maven-plugin:1.6.0:exec";

            var args:Vector.<String> = this.getConstantArguments();
            args.push(execArgs, execExecutable, mavenPlugin);

            start(args, _currentProject.folderLocation);
        }

        private function onMavenBuildComplete(event:MavenBuildEvent):void
        {
            if (event.buildId == PAYARA_SERVER_BUILD)
            {
                dispatcher.dispatchEvent(new Event(MavenBuildEvent.START_MAVEN_BUILD));
            }
            else
            {
                dispatcher.removeEventListener(MavenBuildEvent.MAVEN_BUILD_COMPLETE, onMavenBuildComplete);
                dispatcher.removeEventListener(MavenBuildEvent.MAVEN_BUILD_FAILED, onMavenBuildFailed);

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

        private function getConstantArguments():Vector.<String>
        {
            var args:Vector.<String> = new Vector.<String>();
            if (Settings.os == "win")
            {
                args.push("/C");
            }
            else
            {
                args.push("-c");
            }

            args.push(UtilsCore.getMavenBinPath());

            return args;
        }

        private function getMavenBuildProjectPath():String
        {
            var projectPomFile:FileLocation = new FileLocation(_currentProject.mavenBuildOptions.mavenBuildPath).resolvePath("pom.xml");
            var pom:XML = XML(projectPomFile.fileBridge.read());

            var artifactId:String = pom.elements(new QName("http://maven.apache.org/POM/4.0.0", "artifactId"))[0];
            var version:String = pom.elements(new QName("http://maven.apache.org/POM/4.0.0", "version"))[0];

            var separator:String = projectPomFile.fileBridge.separator;

            return projectPomFile.fileBridge.nativePath.concat(separator, "target", separator, artifactId, "-", version);
        }
    }
}
