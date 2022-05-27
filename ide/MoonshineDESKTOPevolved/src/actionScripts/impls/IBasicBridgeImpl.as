package actionScripts.impls
{
    
	import actionScripts.factory.FileLocation;
	import actionScripts.plugins.core.ProjectBridgeImplBase;
	import actionScripts.interfaces.IBasicBridge;

	public class BasicBridgeImpl extends ProjectBridgeImplBase implements IBasicBridge
	{
		public function BasicBridgeImpl()
		{
			super()
		}
		
		public function testBasic(file:Object):FileLocation {
			throw new Error("testBasic method is not implemented")
		}
		
        public function parseBasic(file:FileLocation, projectName:String=null, settingsFileLocation:FileLocation = null):BasicProjectVO{
        		throw new Error("testBasic method is not implemented")
        }

        public function getCorePlugins():Array
        {
        		return [];
        }

        public function getDefaultPlugins():Array
        {
        	throw new Error("Method not implemented.");
        }

        public function getPluginsNotToShowInSettings():Array
        {
        	throw new Error("Method not implemented.");
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