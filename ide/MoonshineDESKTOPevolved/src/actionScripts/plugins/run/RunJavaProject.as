package actionScripts.plugins.run
{
    import flash.events.Event;
    import flash.events.NativeProcessExitEvent;
    
    import actionScripts.events.RunJavaProjectEvent;
    import actionScripts.factory.FileLocation;
    import actionScripts.plugins.build.ConsoleBuildPluginBase;
    import actionScripts.utils.MavenPomUtil;
    import actionScripts.valueObjects.ConstantsCoreVO;

    public class RunJavaProject extends ConsoleBuildPluginBase
    {
        public function RunJavaProject()
        {
            super();
        }

        override public function get name():String
        {
            return "Run Java Project";
        }

        override public function get author():String
        {
            return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team";
        }

        override public function get description():String
        {
            return "Java build plugin. Esc exits.";
        }

        override public function activate():void
        {
            super.activate();

            dispatcher.addEventListener(RunJavaProjectEvent.RUN_JAVA_PROJECT, startConsoleBuildHandler);
        }

        override public function deactivate():void
        {
            super.deactivate();

            dispatcher.removeEventListener(RunJavaProjectEvent.RUN_JAVA_PROJECT, startConsoleBuildHandler);
        }

        override protected function startConsoleBuildHandler(event:Event):void
        {
            var javaProjectEvent:RunJavaProjectEvent = event as RunJavaProjectEvent;
            if (javaProjectEvent && javaProjectEvent.project)
            {
                warning("Starting application: " + javaProjectEvent.project.projectName);

                var pomPathLocation:FileLocation = new FileLocation(javaProjectEvent.project.mavenBuildOptions.mavenBuildPath)
                        .resolvePath("pom.xml");

                var projectVersion:String = MavenPomUtil.getProjectVersion(pomPathLocation);
                var jarName:String = javaProjectEvent.project.projectName.concat("-", projectVersion, ".jar");
                var jarLocation:FileLocation = javaProjectEvent.project.folderLocation
                        .resolvePath("target" + model.fileCore.separator + jarName);

                if (jarLocation.fileBridge.exists)
                {
                    var javaCommand:Vector.<String> = Vector.<String>(["java -classpath " + jarLocation.fileBridge.nativePath +
                                                                        " " + javaProjectEvent.project.mainClassName]);
                    this.start(javaCommand, javaProjectEvent.project.projectFolder.file);
                }
                else
                {
                    error("Project .jar file does not exist: " + jarLocation.fileBridge.nativePath);
                }
            }
        }

        override protected function onNativeProcessExit(event:NativeProcessExitEvent):void
        {
            super.onNativeProcessExit(event);

            if (!isNaN(event.exitCode))
            {
                var info:String = "Application exited with code: " + event.exitCode;
                warning(info);
            }
        }
    }
}
