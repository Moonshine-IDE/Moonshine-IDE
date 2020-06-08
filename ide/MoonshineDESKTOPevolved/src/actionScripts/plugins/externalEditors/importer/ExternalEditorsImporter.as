package actionScripts.plugins.externalEditors.importer
{
	import flash.filesystem.File;
	
	import mx.collections.ArrayCollection;
	
	import actionScripts.plugins.externalEditors.vo.ExternalEditorVO;
	import actionScripts.utils.FileUtils;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ConstantsCoreVO;

	public class ExternalEditorsImporter
	{
		public static const WINDOWS_INSTALL_DIRECTORIES:Array = ["Program files", "Program Files (x86)"];
		
		public static function getDefaultEditors():ArrayCollection
		{
			var listFile:File = File.applicationDirectory.resolvePath("elements/data/DefaultExternalEditors.xml");
			if (!listFile.exists) return null;
			
			var tmpCollection:ArrayCollection = new ArrayCollection();
			var listFileXML:XML = XML(FileUtils.readFromFile(listFile));
			var tmpEditor:ExternalEditorVO;
			var isWindows:Boolean;
			var isMac:Boolean;
			for each (var editor:XML in listFileXML..editor)
			{
				isWindows = String(editor.@isWindows) == "true" ? true : false;
				isMac = String(editor.@isMac) == "true" ? true : false;
				 
				if (ConstantsCoreVO.IS_MACOS && !isMac)
				{
					continue;
				}
				else if (!ConstantsCoreVO.IS_MACOS && !isWindows)
				{
					continue;
				} 
				
				tmpEditor = new ExternalEditorVO();
				tmpEditor.title = String(editor.title);
				tmpEditor.website = String(editor.website);
				
				var installPath:String = String(editor.defaultLocation[ConstantsCoreVO.IS_MACOS ? "macos" : "windows"].valueOf());
				if (!ConstantsCoreVO.IS_MACOS)
				{
					installPath = validateWindowsInstallation(installPath);
				}
				if (editor.hasOwnProperty("defaultArguments"))
				{
					tmpEditor.extraArguments = String(editor.defaultArguments[ConstantsCoreVO.IS_MACOS ? "macos" : "windows"].valueOf());
				}
				
				tmpEditor.installPath = new File(installPath);
				tmpEditor.defaultInstallPath = installPath;
				tmpEditor.isEnabled = tmpEditor.isValid == true;
				tmpEditor.isMoonshineDefault = true;
				
				tmpCollection.addItem(tmpEditor);
			}
			
			if (tmpCollection)
			{
				UtilsCore.sortCollection(tmpCollection, ["title"]);
			}
			
			return tmpCollection;
		}
		
		private static function validateWindowsInstallation(path:String):String
		{
			var tmpPath:String;
			path = path.replace("$programFiles", "");
			if (ConstantsCoreVO.is64BitSupport)
			{
				for (var i:String in WINDOWS_INSTALL_DIRECTORIES)
				{
					tmpPath = "C:/"+ i +"/"+ path;
					if (FileUtils.isPathExists(tmpPath))
					{
						return tmpPath;
					}
				}
			}
			
			return "C:/"+ WINDOWS_INSTALL_DIRECTORIES[0] +"/"+ path;
		}
	}
}