package actionScripts.plugins.tibbo
{
	import actionScripts.languageServer.ILanguageServerManager;
	import actionScripts.plugin.ILanguageServerPlugin;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.tibbo.tibboproject.vo.TibboBasicProjectVO;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.ProjectVO;

	public class TibboBasicLanguageServerPlugin extends PluginBase implements ILanguageServerPlugin
	{
		override public function get name():String 			{return "Tibbo Basic Language Server Plugin";}
		override public function get author():String 		{return ConstantsCoreVO.MOONSHINE_IDE_LABEL + " Project Team";}
		override public function get description():String 	{return "Tibbo Basic code intelligence provided by a language server";}

		public function get languageServerProjectType():Class
		{
			return TibboBasicProjectVO;
		}
		
		public function TibboBasicLanguageServerPlugin()
		{
			super();
		}

		public function createLanguageServerManager(project:ProjectVO):ILanguageServerManager
		{
			return new TibboBasicLanguageServerManager(TibboBasicProjectVO(project));
		}
	}
}