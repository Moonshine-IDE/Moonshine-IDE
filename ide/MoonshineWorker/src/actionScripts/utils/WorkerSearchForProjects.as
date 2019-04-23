package actionScripts.utils
{
	import flash.filesystem.File;
	
	import actionScripts.events.WorkerEvent;
	
	public class WorkerSearchForProjects
	{
		public static const READABLE_FILES_PATTERNS:Array = ["as3proj", "veditorproj", "javaproj", ".project"];
		
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
				worker.workerToMain.send({event:WorkerEvent.FOUND_PROJECTS_IN_DIRECTORIES, value:foundProjectsInDirectories});
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
			var tmpFiles:Array = value.getDirectoryListing();
			for (var i:int = 0; i < tmpFiles.length; i++)
			{
				if (!tmpFiles[i].isDirectory)
				{
					if (isAcceptableResource(tmpFiles[i].extension))
					{
						var tmpResult:SearchResult = new SearchResult();
						tmpResult.isRoot = (depthIndex == 0);
						tmpResult.projectFile = tmpFiles[i];
						foundProjectsInDirectories.push(tmpResult);
						return null;
					}
					else
					{
						tmpFiles.splice(i, 1);
						i--;
					}
				}
			}
			
			return ((tmpFiles.length != 0) ? tmpFiles : null);
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