package actionScripts.impls
{
    
	import actionScripts.factory.FileLocation;
	import actionScripts.plugins.core.ProjectBridgeImplBase;
	import actionScripts.interfaces.IBasicBridge;
	import actionScripts.plugin.basic.importer.BasicImporter;	
	import actionScripts.plugin.basic.vo.BasicProjectVO;	
	import flash.filesystem.File;
	import actionScripts.plugin.syntax.BasicSyntaxPlugin;
	import actionScripts.plugin.basic.BasicProjectPlugin;

	public class IBasicBridgeImpl extends ProjectBridgeImplBase implements IBasicBridge
	{
		public function IBasicBridgeImpl()
		{
			super()
		}
		
		public function testBasic(file:Object):FileLocation {
			
			return BasicImporter.test(file as File);
			
		}
		
        public function parseBasic(file:FileLocation, projectName:String=null, settingsFileLocation:FileLocation = null):BasicProjectVO{
        		return BasicImporter.parse(file, projectName, settingsFileLocation);
        }

        public function getCorePlugins():Array
        {
        		return [
            ];
        }

        public function getDefaultPlugins():Array
        {
            return [
			    BasicSyntaxPlugin,
                BasicProjectPlugin
				
            ];
        }

        public function getPluginsNotToShowInSettings():Array
        {
        		return []
        }

        public function get runtimeVersion():String
        {
        		return ""
        }

        public function get version():String
        {
      	  	return ""
        }
	}
}