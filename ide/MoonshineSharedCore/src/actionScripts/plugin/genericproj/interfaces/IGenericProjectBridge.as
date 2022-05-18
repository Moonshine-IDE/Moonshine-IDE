package actionScripts.plugin.genericproj.interfaces
{
	import actionScripts.factory.FileLocation;
	import actionScripts.interfaces.IProject;
	import actionScripts.plugin.genericproj.vo.GenericProjectVO;

	public interface IGenericProjectBridge extends IProject
	{
		function testGenericProject(file:Object):FileLocation;
		function parseGenericProject(file:FileLocation):GenericProjectVO;
	}
}
