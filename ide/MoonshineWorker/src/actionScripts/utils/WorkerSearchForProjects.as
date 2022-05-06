package actionScripts.utils
{
	import flash.filesystem.File;
	
	import actionScripts.events.WorkerEvent;
	
	public class WorkerSearchForProjects
	{
		public static const READABLE_FILES_PATTERNS:Array = ["as3proj", "veditorproj", "javaproj", "grailsproj", "ondiskproj", "genericproj", "actionScriptProperties"];
		
		public var worker:MoonshineWorker;
		public var projectSearchObject:Object;
		
		private var foundProjectsInDirectories:Array;
		private var maxDepthCount:int;
		
		public function WorkerSearchForProjects()
		{
		}
		
		public function initiateNewSearch():void
		{
			depthIndex = 0;
			maxDepthCount = projectSearchObject.value.maxDepthCount;
			
			foundProjectsInDirectories = [];
			
			// give a check if root consists a project
			var rootFiles:Array = searchForProjectFile(new File(projectSearchObject.value.path));
			parseDirectories(rootFiles);
		}
		
		private var depthIndex:int;
		private function parseDirectories(baseQueue:Array):void
		{
			if (!baseQueue || (depthIndex >= maxDepthCount))
			{
				projectSearchObject.value.foundProjectsInDirectories = foundProjectsInDirectories;
				worker.workerToMain.send({event:WorkerEvent.FOUND_PROJECTS_IN_DIRECTORIES, value:projectSearchObject});
				return;
			}
			
			var currentFile:File;
			var currentDirectoriesInFile:Array;
			var subQueue:Array = [];
			
			while (baseQueue.length != 0)
			{
				currentFile = baseQueue.shift();
				if (currentFile.isDirectory)
				{
					currentDirectoriesInFile = searchForProjectFile(currentFile);
					if (currentDirectoriesInFile)
					{
						subQueue = subQueue.concat(currentDirectoriesInFile);
					}
				}
			}
			
			depthIndex++;
			parseDirectories(subQueue);
		}
		
		private function searchForProjectFile(value:File):Array
		{
			var hasFlashBuilderProject:File = value.resolvePath(".project");
			var tmpFiles:Array = value.getDirectoryListing();
			for (var i:int = 0; i < tmpFiles.length; i++)
			{
				if (!tmpFiles[i].isDirectory)
				{
					if (isAcceptableResource(tmpFiles[i].extension))
					{
						// we want to keep precedence of Moonshine
						// configuration files over Flash-Builder files
						updateToProjects(tmpFiles[i]);
						return null;
					}
					else
					{
						tmpFiles.splice(i, 1);
						i--;
					}
				}
			}
			
			// if no Moonshine project configuration file found
			// but flash-builder configuration 
			if (hasFlashBuilderProject && hasFlashBuilderProject.exists) 
			{
				updateToProjects(hasFlashBuilderProject);
				return null;
			}
			
			return ((tmpFiles.length != 0) ? tmpFiles : null);
			
			/*
			 * @local
			 */
			function updateToProjects(path:File):void
			{
				var tmpResult:SearchResult = new SearchResult();
				tmpResult.isRoot = (depthIndex == 0);
				tmpResult.projectFile = path;
				foundProjectsInDirectories.push(tmpResult);
			}
		}
		
		private function isAcceptableResource(extension:String):Boolean
		{
			return READABLE_FILES_PATTERNS.some(
				function isValidExtension(item:Object, index:int, arr:Array):Boolean {
					return item == extension;
				});
		}
	}
}
import flash.filesystem.File;

class SearchResult
{
	public var isRoot:Boolean;
	public var projectFile:File;
	
	public function SearchResult() {}
}