package actionScripts.impls
{
	import actionScripts.interfaces.ILanguageServerBridge;
	import actionScripts.utils.LanguageServerProjectWatcher;
	import flash.errors.IllegalOperationError;

	public class ILanguageServerBridgeImp implements ILanguageServerBridge
	{
		public function ILanguageServerBridgeImp()
		{
			
		}

		private var _watcher:LanguageServerProjectWatcher;

		public function get connectedProjectCount():int
		{
			if(!this._watcher)
			{
				return 0;
			}
			return this._watcher.connectedProjectCount;
		}
		
		public function startProjectWatcher():void
		{
			this._watcher = new LanguageServerProjectWatcher();
		}
	}
}