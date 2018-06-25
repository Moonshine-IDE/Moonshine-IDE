package actionScripts.plugin.actionscript.as3project.files
{
    import actionScripts.plugin.IPlugin;
    import actionScripts.plugin.PluginBase;

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
        }

        override public function deactivate():void
        {
            super.deactivate();
        }
    }
}
