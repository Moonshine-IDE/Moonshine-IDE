package actionScripts.plugin.syntax
{
    import actionScripts.plugin.PluginBase;
    import actionScripts.plugin.settings.ISettingsProvider;
    import actionScripts.plugin.IEditorPlugin;
    import actionScripts.plugin.settings.vo.ISetting;

	public class BasicSyntaxPlugin extends PluginBase implements ISettingsProvider, IEditorPlugin
	{
		public function BasicSyntaxPlugin()
		{
		}

		public function getSettingsList():Vector.<ISetting>
		{
			throw new Error("Method not implemented.");
		}
	}
}