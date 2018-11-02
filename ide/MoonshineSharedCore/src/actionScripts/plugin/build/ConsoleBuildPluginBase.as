package actionScripts.plugin.build
{
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.PluginBase;
    import actionScripts.valueObjects.Settings;

    import flash.desktop.NativeProcess;
    import flash.desktop.NativeProcessStartupInfo;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.NativeProcessExitEvent;
    import flash.events.ProgressEvent;
    import flash.utils.IDataInput;

    public class ConsoleBuildPluginBase extends PluginBase
    {
        protected var nativeProcess:NativeProcess;
        private var nativeProcessStartupInfo:NativeProcessStartupInfo;

        private var console:FileLocation;

        private var running:Boolean;

        public function ConsoleBuildPluginBase()
        {
            super();
        }

        override public function activate():void
        {
            super.activate();

            console = new FileLocation(getConsoleLocation());
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

        public function start(args:Vector.<String>, buildDirectory:*):void
        {
            if (nativeProcess.running && running) return;

            running = true;

            addNativeProcessEventListeners();

            nativeProcessStartupInfo.arguments = args;
            nativeProcessStartupInfo.workingDirectory = buildDirectory.fileBridge.getFile;

            nativeProcess.start(nativeProcessStartupInfo);
        }

        public function stop():void
        {
            nativeProcess.exit();

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
            var output:IDataInput = nativeProcess.standardOutput;
            var data:String = output.readUTFBytes(output.bytesAvailable);

            print("%s", data);
        }

        private function onNativeProcessIOError(event:IOErrorEvent):void
        {
            error("%s", event.text);

            removeNativeProcessEventListeners();
            running = false;
        }

        private function onNativeProcessStandardErrorData(event:ProgressEvent):void
        {
            var output:IDataInput = nativeProcess.standardError;
            var data:String = output.readUTFBytes(output.bytesAvailable);

            error("%s", data);

            removeNativeProcessEventListeners();
            running = false;
        }

        protected function onNativeProcessExit(event:NativeProcessExitEvent):void
        {
            removeNativeProcessEventListeners();
        }

        private function addNativeProcessEventListeners():void
        {
            nativeProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onNativeProcessStandardOutputData);
            nativeProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onNativeProcessStandardErrorData);
            nativeProcess.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, onNativeProcessIOError);
            nativeProcess.addEventListener(IOErrorEvent.STANDARD_INPUT_IO_ERROR, onNativeProcessIOError);
            nativeProcess.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, onNativeProcessIOError);
            nativeProcess.addEventListener(NativeProcessExitEvent.EXIT, onNativeProcessExit);
        }

        private function removeNativeProcessEventListeners():void
        {
            nativeProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onNativeProcessStandardOutputData);
            nativeProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, onNativeProcessStandardErrorData);
            nativeProcess.removeEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, onNativeProcessIOError);
            nativeProcess.removeEventListener(IOErrorEvent.STANDARD_INPUT_IO_ERROR, onNativeProcessIOError);
            nativeProcess.removeEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, onNativeProcessIOError);
            nativeProcess.removeEventListener(NativeProcessExitEvent.EXIT, onNativeProcessExit);
        }

        private function getConsoleLocation():String
        {
            if (Settings.os == "win")
            {
                // in windows
                return "c:\\Windows\\System32\\cmd.exe";
            }
            else
            {
                // in mac
                return "/bin/bash";
            }

        }
    }
}
