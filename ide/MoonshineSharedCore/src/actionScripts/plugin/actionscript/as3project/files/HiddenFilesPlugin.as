package actionScripts.plugin.actionscript.as3project.files
{
    import actionScripts.events.HiddenFilesEvent;
    import actionScripts.events.RefreshTreeEvent;
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.IPlugin;
    import actionScripts.plugin.PluginBase;
    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
    import actionScripts.utils.UtilsCore;
    import actionScripts.valueObjects.FileWrapper;

    public class HiddenFilesPlugin extends PluginBase implements IPlugin
    {
        override public function get name():String { return "Hidden Files"; }
        override public function get author():String { return "Moonshine Project Team"; }
        override public function get description():String { return "Handle hide/show operations on folders in Project Tree"; }

        public function HiddenFilesPlugin()
        {
            super();
        }

        override public function activate():void
        {
            super.activate();

            dispatcher.addEventListener(HiddenFilesEvent.MARK_FILES_AS_VISIBLE, showFilesHandler);
            dispatcher.addEventListener(HiddenFilesEvent.MARK_FILES_AS_HIDDEN, hideFilesHandler);
        }

        override public function deactivate():void
        {
            super.deactivate();

            dispatcher.removeEventListener(HiddenFilesEvent.MARK_FILES_AS_VISIBLE, showFilesHandler);
            dispatcher.removeEventListener(HiddenFilesEvent.MARK_FILES_AS_HIDDEN, hideFilesHandler);
        }

        private function hideFilesHandler(event:HiddenFilesEvent):void
        {
            var fileWrapper:FileWrapper = event.fileWrapper;
            var project:AS3ProjectVO = UtilsCore.getProjectFromProjectFolder(fileWrapper) as AS3ProjectVO;
            project.hiddenPaths.push(new FileLocation(fileWrapper.nativePath));
            project.saveSettings();

            dispatcher.dispatchEvent(new RefreshTreeEvent(fileWrapper.file));
        }

        private function showFilesHandler(event:HiddenFilesEvent):void
        {
            var fileWrapper:FileWrapper = event.fileWrapper;
            var project:AS3ProjectVO = UtilsCore.getProjectFromProjectFolder(fileWrapper) as AS3ProjectVO;
            var fileIndex:int = -1;
            if (project.hiddenPaths.some(function(item:FileLocation, index:int, arr:Vector.<FileLocation>):Boolean
            {
                if (item.fileBridge.nativePath == fileWrapper.nativePath)
                {
                    fileIndex = index;
                    return true;
                }
                return false;
            }))
            {
                project.hiddenPaths.removeAt(fileIndex);
                project.saveSettings();

                dispatcher.dispatchEvent(new RefreshTreeEvent(fileWrapper.file));
            }
        }
    }
}
