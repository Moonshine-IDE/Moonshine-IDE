package actionScripts.languageServer
{
	import actionScripts.valueObjects.ProjectVO;

	public interface ILanguageServerManager
	{
		function get project():ProjectVO;
	}
}