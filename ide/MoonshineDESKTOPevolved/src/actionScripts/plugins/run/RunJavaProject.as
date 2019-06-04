package actionScripts.plugins.run
{
    import flash.events.Event;
    import flash.events.NativeProcessExitEvent;
    
    import actionScripts.events.RunJavaProjectEvent;
    import actionScripts.events.StatusBarEvent;
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
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
			var tmpJavaProject:JavaProjectVO = event ? (event as RunJavaProjectEvent).project : null;
			var javaCommand:Vector.<String>;
            if (tmpJavaProject)
            {
				dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED,
					tmpJavaProject.name,
					"Running "));
				
				// maven project
				warning("Starting application: " + tmpJavaProject.projectName);
				
				var pomPathLocation:FileLocation = new FileLocation(tmpJavaProject.mavenBuildOptions.buildPath)
					.resolvePath("pom.xml");
				
				var projectVersion:String = MavenPomUtil.getProjectVersion(pomPathLocation);
				var jarName:String = tmpJavaProject.projectName.concat("-", projectVersion, ".jar");
				var jarLocation:FileLocation = tmpJavaProject.folderLocation
					.resolvePath("target" + model.fileCore.separator + jarName);
				
				if (jarLocation.fileBridge.exists)
				{
					javaCommand = Vector.<String>(["java -classpath " + jarLocation.fileBridge.nativePath +
						" " + tmpJavaProject.mainClassName]);
					this.start(javaCommand, tmpJavaProject.projectFolder.file);
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
			
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
            if (!isNaN(event.exitCode))
            {
                var info:String = "Application exited with code: " + event.exitCode;
                warning(info);
            }
        }
    }
}
