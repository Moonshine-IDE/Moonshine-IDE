package actionScripts.utils
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.utils.StringUtil;
	
	import actionScripts.events.WorkerEvent;
	import actionScripts.valueObjects.WorkerFileWrapper;

	public class WorkerSearchInProjects
	{
		public static var FILES_COUNT:int;
		public static var FILE_PROCESSED_COUNT:int;
		public static var FILES_FOUND_IN_COUNT:int;
		
		public var worker:MoonshineWorker;
		public var projectSearchObject:Object;
		public var storedPathsForProbableReplace:Array;
		
		private var allRedableExtensions:Array;
		private var projects:Array;
		private var totalFoundCount:int;
		private var customFilePatterns:Array = [];
		private var isCustomFilePatterns:Boolean;
		private var isStorePathsForProbableReplace:Boolean;
		
		public function WorkerSearchInProjects()
		{
		}
		
		public function initiateBeforeNewSearch():void
		{
			allRedableExtensions = projectSearchObject.value.allRedableExtensions;
			projects = projectSearchObject.value.projects;
			isStorePathsForProbableReplace = projectSearchObject.value.isShowReplaceWhenDone;
			FILES_FOUND_IN_COUNT = 0;
			storedPathsForProbableReplace = null;
			storedPathsForProbableReplace = [];
			
			parseProjectsTree();
		}
		
		private function parseProjectsTree():void
		{
			// probable termination
			if (projects.length == 0)
			{
				worker.workerToMain.send({event:WorkerEvent.PROCESS_ENDS, value:FILES_FOUND_IN_COUNT});
				return;
			}
			
			FILES_COUNT = FILE_PROCESSED_COUNT = 0;
			totalFoundCount = 0;
			isCustomFilePatterns = false;
			
			var tmpWrapper:WorkerFileWrapper = new WorkerFileWrapper(new File(projects[0]), true);
			
			// in case a given path is not valid, do not parse anything
			if (!tmpWrapper.file.exists)
			{
				// restart with available next project (if any)
				projects.shift();
				var timeoutValue:uint = setTimeout(function():void
				{
					clearTimeout(timeoutValue);
					parseProjectsTree();
				}, 400);
				return;
			}
			
			worker.workerToMain.send({event:WorkerEvent.TOTAL_FILE_COUNT, value:FILES_COUNT});
			
			if (projectSearchObject.value.patterns != "*")
			{
				var filtered:String = projectSearchObject.value.patterns.replace(/( )/g, "");
				customFilePatterns = filtered.split(",");
				
				var hasGloablSearchSign:Boolean = customFilePatterns.some(
					function isValidExtension(item:Object, index:int, arr:Array):Boolean {
						return item == "*";
					});
				
				isCustomFilePatterns = !hasGloablSearchSign;
			}
			
			parseChildrens(tmpWrapper);
		}
		
		public function startReplacing():void
		{
			for each (var i:Object in storedPathsForProbableReplace)
			{
				if (i.isSelected)
				{
					testFilesForValueExist(i.label, projectSearchObject.value.valueToReplace);
					worker.workerToMain.send({event:WorkerEvent.FILE_PROCESSED_COUNT, value:i.label}); // sending path value instead of completion count in case of replace 
				}
			}
			
			// once done 
			worker.workerToMain.send({event:WorkerEvent.PROCESS_ENDS, value:null});
		}
		
		private function parseChildrens(value:Object):void
		{
			if (!value) return;
			
			var extension: String = value.file.extension;
			var tmpReturnCount:int;
			var tmpLineObject:Object;
			
			if ((value.children is Array) && (value.children as Array).length > 0) 
			{
				var tmpTotalChildrenCount:int = value.children.length;
				for (var c:int=0; c < value.children.length; c++)
				{
					extension = value.children[c].file.extension;
					var isAcceptable:Boolean = (extension != null) ? isAcceptableResource(extension) : false;
					if (!value.children[c].file.isDirectory && isAcceptable)
					{
						tmpLineObject = testFilesForValueExist(value.children[c].file.nativePath);
						tmpReturnCount = tmpLineObject ? tmpLineObject.foundCountInFile : -1;
						if (tmpReturnCount == -1)
						{
							value.children.splice(c, 1);
							tmpTotalChildrenCount --;
							c--;
						}
						else
						{
							value.children[c].searchCount = tmpReturnCount;
							value.children[c].children = tmpLineObject.foundMatches;
							totalFoundCount += tmpReturnCount;
							FILES_FOUND_IN_COUNT++;
							if (isStorePathsForProbableReplace) storedPathsForProbableReplace.push({label:value.children[c].file.nativePath, isSelected:true});
						}
					}
					else if (!value.children[c].file.isDirectory && !isAcceptable)
					{
						value.children.splice(c, 1);
						tmpTotalChildrenCount --;
						c--;
					}
					else if (value.children[c].file.isDirectory) 
					{
						//lastChildren = value.children;
						parseChildrens(value.children[c]);
						if (!value.children[c].children || (value.children[c].children && value.children[c].children.length == 0)) 
						{
							value.children.splice(c, 1);
							c--;
						}
					}
					
					notifyFileCountCompletionToMain();
				}
				
				// when recursive listing done
				if (value.isRoot)
				{
					notifyFileCountCompletionToMain();
					worker.workerToMain.send({event:WorkerEvent.TOTAL_FOUND_COUNT, value:value.file.nativePath +"::"+ totalFoundCount});
					worker.workerToMain.send({event:WorkerEvent.FILTERED_FILE_COLLECTION, value:value});
					
					// restart with available next project (if any)
					projects.shift();
					var timeoutValue:uint = setTimeout(function():void
					{
						clearTimeout(timeoutValue);
						parseProjectsTree();
					}, 400);
				}
			}
			else 
			{
				notifyFileCountCompletionToMain();
			}
			
			/*
			* @local
			*/
			function notifyFileCountCompletionToMain():void
			{
				tmpLineObject = null;
				worker.workerToMain.send({event:WorkerEvent.FILE_PROCESSED_COUNT, value:++FILE_PROCESSED_COUNT});
			}
		}
		
		private function isAcceptableResource(extension:String):Boolean
		{
			if (isCustomFilePatterns)
			{
				return customFilePatterns.some(
					function isValidExtension(item:Object, index:int, arr:Array):Boolean {
						return item == extension;
					});
			}
			
			return allRedableExtensions.some(
				function isValidExtension(item:Object, index:int, arr:Array):Boolean {
					return item == extension;
				});
		}
		
		private function testFilesForValueExist(value:String, replace:String=null):Object
		{
			var r:FileStream = new FileStream();
			var f:File = new File(value); 
			r.open(f, FileMode.READ);
			var content:String = r.readUTFBytes(f.size);
			r.close();
			
			// remove all the leading space/tabs in a line
			// so we can show the lines without having space/tabs in search results
			//content = content.replace(/^[ \t]+(?=\S)/gm, "");
			content = StringUtil.trim(content);
			
			var flags:String = projectSearchObject.value.isMatchCase ? "g" : "gi";
			var searchString:String;
			if (projectSearchObject.value.isRegexp)
			{
				if (projectSearchObject.value.isEscapeChars)
				{
					searchString = escapeRegex(projectSearchObject.value.valueToSearch);
				}
				else
				{
					searchString = projectSearchObject.value.valueToSearch;
				}
			}
			else
			{
				searchString = escapeRegex(projectSearchObject.value.valueToSearch);
			}
			var searchRegExp:RegExp = new RegExp(searchString, flags);
			
			var foundMatches:Array = [];
			var results:Array = searchRegExp.exec(content);
			var tmpFW:WorkerFileWrapper;
			var res:SearchResult;
			var lastLineIndex:int = -1;
			var foundCountInFile:int;
			var lines:Array;
			while (results != null)
			{
				var lc:Point = charIdx2LineCharIdx(content, results.index, "\n");
				
				res = new SearchResult();
				res.startLineIndex = lc.x;
				res.endLineIndex = lc.x;
				res.startCharIndex = lc.y;
				res.endCharIndex = lc.y + results[0].length;
				
				if (res.startLineIndex != lastLineIndex)
				{
					if (!lines)
					{
						lines = content.split(/\r?\n|\r/);
					}
					tmpFW = new WorkerFileWrapper(null);
					tmpFW.isShowAsLineNumber = true;
					tmpFW.lineNumbersWithRange = [];
					tmpFW.fileReference = value;
					foundMatches.push(tmpFW);
					lastLineIndex = res.startLineIndex;
				}
				
				//tmpFW.lineText = StringUtil.trim(lines[res.startLineIndex]);
				tmpFW.lineText = lines[res.startLineIndex];
				tmpFW.lineNumbersWithRange.push(res);
				results = searchRegExp.exec(content);
				
				// since a line could have multiple searched instance
				// we need to count do/while separately other than
				// counting total lines (foundMatches)
				foundCountInFile++;
			}
			
			if (foundMatches.length > 0 && replace)
			{
				replaceAndSaveFile();
			}
			
			lines = null;
			content = null;
			return ((foundMatches.length > 0) ? {foundMatches:foundMatches, foundCountInFile:foundCountInFile} : null);
			
			/*
			* @local
			*/
			function replaceAndSaveFile():void
			{
				content = content.replace(searchRegExp, replace);
				
				r = new FileStream();
				r.open(f, FileMode.WRITE);
				r.writeUTFBytes(content);
				r.close();
			}
		}
		
		private function escapeRegex(str:String):String 
		{
			return str.replace(/[\$\(\)\*\+\.\[\]\?\\\^\{\}\|]/g,"\\$&");
		}
		
		private function charIdx2LineCharIdx(str:String, charIdx:int, lineDelim:String):Point
		{
			var line:int = 0;
			var current:int = charIdx;
			while(true)
			{
				current = str.lastIndexOf(lineDelim, current - 1);
				if (current == -1)
				{
					break;
				}
				line++;
			}
			var chr:int = line > 0 ? charIdx - str.lastIndexOf(lineDelim, charIdx - 1) - lineDelim.length : charIdx;
			return new Point(line, chr);
		}
	}
}

class SearchResult
{
	public var startLineIndex:int = -1;
	public var startCharIndex:int = -1;
	public var endLineIndex:int = -1;
	public var endCharIndex:int = -1;
	public var totalMatches:int = 0;
	public var totalReplaces:int = 0;
	public var selectedIndex:int = 0;
	public var didWrap:Boolean;
	
	public function SearchResult() {}	
}