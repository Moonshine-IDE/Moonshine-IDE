package actionScripts.plugins.exportToRoyaleTemplatedApp.utils
{
    
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;

	public   class ExportContext  
	{
		private var _targetSrcFolder:FileLocation;		
		private var _targetMainAppLocation:FileLocation;		
		private var _targetMainContentLocation:FileLocation;		
		private var _sourceMainContentLocation:FileLocation;		
		
		private var _regex:RegExp = new RegExp("^\\S+\\bsrc\\b");
		
		public function ExportContext(mainAppFile:String, exportedProject:AS3ProjectVO)
		{	
			var matches:Array = _regex.exec(mainAppFile);
			_targetSrcFolder = matches.length > 0
				? new FileLocation(matches[0]) 
				: null;
			
			var separator:String = exportedProject.sourceFolder.fileBridge.separator;
			_targetMainAppLocation = new FileLocation(mainAppFile);
			_targetMainContentLocation = _targetMainAppLocation.fileBridge.parent.resolvePath("view" + separator + "MainContent.mxml");
			
			var sourceProjectFolder:String = exportedProject.sourceFolder.fileBridge.nativePath + separator + exportedProject.name;
			_sourceMainContentLocation = new FileLocation(sourceProjectFolder + separator + "views" + separator + "MainContent.mxml");
		}
		
		public function get targetSrcFolder():FileLocation
		{
			return _targetSrcFolder;
		}
		
		public function get targetMainAppLocation():FileLocation
		{
			return _targetMainAppLocation;
		}
		
		public function get targetMainContentLocation():FileLocation
		{
			return _targetMainContentLocation;
		}
		
		public function get sourceMainContentLocation():FileLocation
		{
			return _sourceMainContentLocation;
		}
	}
}