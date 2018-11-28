package actionScripts.plugins.build
{
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.PluginBase;
    import actionScripts.utils.UtilsCore;

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

        protected var running:Boolean;

        public function ConsoleBuildPluginBase()
        {
            super();
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

        public function start(args:Vector.<String>, buildDirectory:*):void
        {
            if (nativeProcess.running && running)
            {
                warning("Build is running. Wait for finish...");
                return;
            }
            else if (nativeProcess.running)
            {
                removeNativeProcessEventListeners();
                nativeProcess = new NativeProcess();
            }

            running = true;

            addNativeProcessEventListeners();

            nativeProcessStartupInfo.arguments = args;
            nativeProcessStartupInfo.workingDirectory = buildDirectory.fileBridge.getFile;

            nativeProcess.start(nativeProcessStartupInfo);
        }

        public function stop(forceStop:Boolean = false):void
        {
            if (running)
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

            removeNativeProcessEventListeners();
            running = false;
        }

        protected function onNativeProcessStandardErrorData(event:ProgressEvent):void
        {
            error("%s", getDataFromBytes(nativeProcess.standardError));

            removeNativeProcessEventListeners();
            running = false;
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

        private function addNativeProcessEventListeners():void
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
        }
    }
}
