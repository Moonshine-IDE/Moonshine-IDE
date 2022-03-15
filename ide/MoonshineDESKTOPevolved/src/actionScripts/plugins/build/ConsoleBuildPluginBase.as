package actionScripts.plugins.build
{
	import actionScripts.interfaces.IJavaProject;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.java.javaproject.vo.JavaTypes;
	import actionScripts.valueObjects.ProjectVO;

	import flash.desktop.NativeProcess;
    import flash.desktop.NativeProcessStartupInfo;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.NativeProcessExitEvent;
    import flash.events.ProgressEvent;
    import flash.filesystem.File;
    import flash.utils.IDataInput;
    
    import actionScripts.factory.FileLocation;
    import actionScripts.utils.EnvironmentSetupUtils;
    import actionScripts.utils.UtilsCore;
    import actionScripts.valueObjects.EnvironmentUtilsCusomSDKsVO;
    import actionScripts.valueObjects.Settings;

    public class ConsoleBuildPluginBase extends CompilerPluginBase
    {
        protected var nativeProcess:NativeProcess;
		protected var nativeProcessStartupInfo:NativeProcessStartupInfo;

        public function ConsoleBuildPluginBase()
        {
            super();
        }

        private var _running:Boolean;
        protected function get running():Boolean
        {
            return _running;
        }

        protected function set running(value:Boolean):void
        {
            _running = value;
        }

        override public function activate():void
        {
            super.activate();

            var console:FileLocation = new FileLocation(UtilsCore.getConsolePath());
            nativeProcess = new NativeProcess();
            nativeProcessStartupInfo = new NativeProcessStartupInfo();

            var executable:* = console.fileBridge.getFile;
            nativeProcessStartupInfo.executable = executable;

            addNativeProcessEventListeners();
        }

        override public function deactivate():void
        {
            super.deactivate();

            removeNativeProcessEventListeners();

            nativeProcess = null;
            nativeProcessStartupInfo = null;
        }

        public function start(args:Vector.<String>, buildDirectory:*, customSDKs:EnvironmentUtilsCusomSDKsVO=null):void
        {
            if (nativeProcess.running && _running)
            {
                warning("Build is running. Wait for finish...");
                return;
            }
            
			// remove -c or /c 
			// we'll use them later
			var firstArgument:String = args ? args[0].toLowerCase() : null;
			if (firstArgument && 
				(firstArgument == "/c" || firstArgument == "-c"))
			{
				args.shift();
			}
			
			var newArray:Array = new Array().concat(args);
			EnvironmentSetupUtils.getInstance().initCommandGenerationToSetLocalEnvironment(onEnvironmentPrepared, customSDKs, newArray);
			
			/*
			* @local
			*/
			function onEnvironmentPrepared(value:String):void
			{
				if (nativeProcess.running)
				{
					removeNativeProcessEventListeners();
					nativeProcess = new NativeProcess();
				}
				
				var processArgs:Vector.<String> = new Vector.<String>;
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
				
				addNativeProcessEventListeners();
				
				//var workingDirectory:File = currentSDK.resolvePath("bin/");
				nativeProcessStartupInfo.arguments = processArgs;
				if (buildDirectory) 
				{
					if (buildDirectory is FileLocation)	nativeProcessStartupInfo.workingDirectory = buildDirectory.fileBridge.getFile;
					else if (buildDirectory is File) nativeProcessStartupInfo.workingDirectory = buildDirectory;
				}
				
				nativeProcess.start(nativeProcessStartupInfo);
				running = true;
			}
        }

        public function stop(forceStop:Boolean = false):void
        {
            if (running || forceStop)
            {
                nativeProcess.exit(forceStop);
            }

            running = false;
        }

        public function complete():void
        {
            running = false;
        }

        protected function stopConsoleBuildHandler(event:Event):void
        {

        }

        protected function startConsoleBuildHandler(event:Event):void
        {

        }

        protected function onNativeProcessStandardOutputData(event:ProgressEvent):void
        {
            print("%s", getDataFromBytes(nativeProcess.standardOutput));
        }

        protected function onNativeProcessIOError(event:IOErrorEvent):void
        {
            error("%s", event.text);
        }

        protected function onNativeProcessStandardErrorData(event:ProgressEvent):void
        {
            error("%s", getDataFromBytes(nativeProcess.standardError));
        }

        protected function onNativeProcessStandardInputClose(event:Event):void
        {

        }

        protected function onNativeProcessExit(event:NativeProcessExitEvent):void
        {
			removeNativeProcessEventListeners();
        }

        protected function getDataFromBytes(data:IDataInput):String
        {
            return data.readUTFBytes(data.bytesAvailable);
        }

        protected function addNativeProcessEventListeners():void
        {
            nativeProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onNativeProcessStandardOutputData);
            nativeProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onNativeProcessStandardErrorData);
            nativeProcess.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, onNativeProcessIOError);
            nativeProcess.addEventListener(IOErrorEvent.STANDARD_INPUT_IO_ERROR, onNativeProcessIOError);
            nativeProcess.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, onNativeProcessIOError);
            nativeProcess.addEventListener(Event.STANDARD_INPUT_CLOSE, onNativeProcessStandardInputClose);
            nativeProcess.addEventListener(NativeProcessExitEvent.EXIT, onNativeProcessExit);
        }

        protected function removeNativeProcessEventListeners():void
        {
            nativeProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onNativeProcessStandardOutputData);
            nativeProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, onNativeProcessStandardErrorData);
            nativeProcess.removeEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, onNativeProcessIOError);
            nativeProcess.removeEventListener(IOErrorEvent.STANDARD_INPUT_IO_ERROR, onNativeProcessIOError);
            nativeProcess.removeEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, onNativeProcessIOError);
            nativeProcess.removeEventListener(NativeProcessExitEvent.EXIT, onNativeProcessExit);
			running = false;
        }

		public static function checkRequireJava(project:ProjectVO=null):Boolean
		{
			if (!project)
            {
                project = IDEModel.getInstance().activeProject;
            }

            var javaProject:IJavaProject = project as IJavaProject;
			if (javaProject)
			{
				if ((javaProject.jdkType == JavaTypes.JAVA_DEFAULT) &&
                    !UtilsCore.isJavaForTypeaheadAvailable())
				{
					return false;
				}
				if ((javaProject.jdkType == JavaTypes.JAVA_8) &&
                    !UtilsCore.isJava8Present())
				{
					return false;
				}
			}

			if ((project is AS3ProjectVO) &&
					(project as AS3ProjectVO).isDominoVisualEditorProject)
			{
				if (((project as AS3ProjectVO).jdkType == JavaTypes.JAVA_8) &&
						!UtilsCore.isJava8Present())
				{
					return false;
				}
			}

			return true;
		}
    }
}
