package actionScripts.plugin.groovy.groovyproject.importer
{
	import actionScripts.factory.FileLocation;
	import flash.filesystem.File;
	import actionScripts.plugin.groovy.groovyproject.vo.GroovyProjectVO;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	import actionScripts.plugin.core.importer.FlashDevelopImporterBase;

	public class GroovyImporter extends FlashDevelopImporterBase
	{
		private static const FILE_EXTENSION_GVYPROJ:String = "gvyproj";

		public static function test(file:File):FileLocation
		{
			if (!file.exists)
			{
				return null;
			}

			var listing:Array = file.getDirectoryListing();
			for each (var i:Object in listing)
			{
				if (i.extension == FILE_EXTENSION_GVYPROJ)
				{
					return new FileLocation(i.nativePath);
				}
			}
			
			return null;
		}

		public static function parse(file:FileLocation, projectName:String=null):GroovyProjectVO
		{
			var folder:File = (file.fileBridge.getFile as File).parent;

			var project:GroovyProjectVO = new GroovyProjectVO(new FileLocation(folder.nativePath), projectName);

			project.projectFile = file;

			project.projectName = file.fileBridge.name.substring(0, file.fileBridge.name.lastIndexOf("."));

			var stream:FileStream = new FileStream();
			stream.open(file.fileBridge.getFile as File, FileMode.READ);
			var data:XML = XML(stream.readUTFBytes(file.fileBridge.getFile.size));
			stream.close();
			
            project.classpaths.length = 0;
            project.targets.length = 0;
			
            parsePaths(data.compileTargets.compile, project.targets, project, "path");
			parsePaths(data.classpaths["class"], project.classpaths, project, "path");

			if (project.targets.length > 0)
			{
				var target:FileLocation = project.targets[0];
				
				// determine source folder path
				var substrPath:String = target.fileBridge.nativePath.replace(project.folderLocation.fileBridge.nativePath + File.separator, "");
				var pathSplit:Array = substrPath.split(File.separator);
				// remove the last class file name
				pathSplit.pop();
				var finalPath:String = project.folderLocation.fileBridge.nativePath;
				// loop through array if source folder level is
				// deeper more than 1 level
				for (var j:int=0; j < pathSplit.length; j++)
				{
					finalPath += File.separator + pathSplit[j];
				}
				
				// even before deciding, go for some more checks -
				// which needs in case user used 'set as default application'
				// to a file exists in different path
				for each (var i:FileLocation in project.classpaths)
				{
					if ((finalPath + File.separator).indexOf(i.fileBridge.nativePath + File.separator) != -1) project.sourceFolder = i;
				}
				
				// if yet not decided from above approach
				if (!project.sourceFolder) project.sourceFolder = new FileLocation(finalPath);
			}
			
			project.jarOutput.parse(data.output, project);

			return project;
		}
	}
}