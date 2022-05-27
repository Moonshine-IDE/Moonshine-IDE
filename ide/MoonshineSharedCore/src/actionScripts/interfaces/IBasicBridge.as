package actionScripts.interfaces
{
    import actionScripts.interfaces.IProject;
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.basic.vo.BasicProjectVO;

	public interface IBasicBridge extends IProject
	{
		function testBasic(file:Object):FileLocation;
        function parseBasic(file:FileLocation, projectName:String=null, settingsFileLocation:FileLocation = null):BasicProjectVO;
	}
}