////////////////////////////////////////////////////////////////////////////////
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0 
// 
// Unless required by applicable law or agreed to in writing, software 
// distributed under the License is distributed on an "AS IS" BASIS, 
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and 
// limitations under the License
// 
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
// 
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugins.git
{
	import com.adobe.utils.StringUtil;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.utils.IDataInput;
	
	import mx.collections.ArrayCollection;
	
	import actionScripts.events.GeneralEvent;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.ProjectEvent;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.console.ConsoleOutputter;
	import actionScripts.plugin.core.compiler.CompilerEventBase;
	import actionScripts.plugins.git.model.GitProjectVO;
	import actionScripts.plugins.git.model.MethodDescriptor;
	import actionScripts.ui.menu.vo.ProjectMenuTypes;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.GenericSelectableObject;
	import actionScripts.valueObjects.Settings;
	import actionScripts.vo.NativeProcessQueueVO;
	
	public class GitProcessManager extends ConsoleOutputter
	{
		public static const GIT_DIFF_CHECKED:String = "gitDiffProcessCompleted";
		public static const GIT_REPOSITORY_TEST:String = "checkIfGitRepository";
		public static const GIT_STATUS_FILE_MODIFIED:String = "gitStatusFileModified";
		public static const GIT_STATUS_FILE_DELETED:String = "gitStatusFileDeleted";
		public static const GIT_STATUS_FILE_NEW:String = "gitStatusFileNew";
		public static const GIT_REMOTE_BRANCH_LIST:String = "getGitRemoteBranchList";
		
		private static const XCODE_PATH_DECTECTION:String = "xcodePathDectection";
		private static const GIT_AVAIL_DECTECTION:String = "gitAvailableDectection";
		private static const GIT_DIFF_CHECK:String = "checkGitDiff";
		private static const GIT_PUSH:String = "gitPush";
		private static const GIT_REMOTE_ORIGIN_URL:String = "getGitRemoteURL";
		private static const GIT_CURRENT_BRANCH_NAME:String = "getGitCurrentBranchName";
		private static const GIT_COMMIT:String = "gitCommit";
		private static const GIT_CHECKOUT_BRANCH:String = "gitCheckoutToBranch";
		private static const GIT_CHECKOUT_NEW_BRANCH:String = "gitCheckoutNewBranch";
		
		public var gitBinaryPathOSX:String;
		public var setGitAvailable:Function;
		public var plugin:GitHubPlugin;
		public var pendingProcess:Array /* of MethodDescriptor */ = [];
		
		protected var processType:String;

		private var customProcess:NativeProcess;
		private var customInfo:NativeProcessStartupInfo;
		private var queue:Vector.<Object> = new Vector.<Object>();
		private var connectedDevices:Vector.<String>;
		private var windowsAutoJavaLocation:File;
		private var model:IDEModel = IDEModel.getInstance();
		private var isAndroid:Boolean;
		private var isErrorClose:Boolean;
		private var onXCodePathDetection:Function;
		private var gitTestProject:AS3ProjectVO;
		
		private var _cloningProjectName:String;
		private function get cloningProjectName():String
		{
			return _cloningProjectName;
		}
		private function set cloningProjectName(value:String):void
		{
			var quoteIndex:int = value.indexOf("'");
			_cloningProjectName = value.substring(++quoteIndex, value.indexOf("'", quoteIndex));
		}
		
		public function GitProcessManager()
		{
		}
		
		public function getOSXCodePath(completion:Function):void
		{
			if (customProcess) startShell(false);
			onXCodePathDetection = completion;
			customInfo = renewProcessInfo();
			
			queue = new Vector.<Object>();
			
			addToQueue({com:'xcode-select -p', showInConsole:false});
			
			processType = XCODE_PATH_DECTECTION;
			if (customProcess) startShell(false);
			startShell(true);
			flush();
		}
		
		public function checkGitAvailability():void
		{
			if (customProcess) startShell(false);
			customInfo = renewProcessInfo();
			
			queue = new Vector.<Object>();
			
			addToQueue(new NativeProcessQueueVO(ConstantsCoreVO.IS_MACOS ? gitBinaryPathOSX +' --version' : 'git&&--version', false, GIT_AVAIL_DECTECTION));
			
			if (customProcess) startShell(false);
			startShell(true);
			flush();
		}
		
		public function checkIfGitRepository(project:AS3ProjectVO):void
		{
			if (customProcess) startShell(false);
			customInfo = renewProcessInfo();
			customInfo.workingDirectory = project.folderLocation.fileBridge.getFile as File;
			
			queue = new Vector.<Object>();
			
			addToQueue(new NativeProcessQueueVO(ConstantsCoreVO.IS_MACOS ? gitBinaryPathOSX +' -C "'+ customInfo.workingDirectory.nativePath +'" status' : 'git&&rev-parse&&--git-dir', false, GIT_REPOSITORY_TEST));
			
			gitTestProject = project;
			if (customProcess) startShell(false);
			startShell(true);
			flush();
		}
		
		public function getGitRemoteURL():void
		{
			if (customProcess) startShell(false);
			customInfo = renewProcessInfo();
			customInfo.workingDirectory = model.activeProject.folderLocation.fileBridge.getFile as File;
			
			queue = new Vector.<Object>();

			addToQueue(new NativeProcessQueueVO(ConstantsCoreVO.IS_MACOS ? gitBinaryPathOSX +' config --get remote.origin.url' : 'git&&config&&--get&&remote.origin.url', false, GIT_REMOTE_ORIGIN_URL));
			
			gitTestProject = model.activeProject as AS3ProjectVO;
			if (customProcess) startShell(false);
			startShell(true);
			flush();
		}
		
		public function clone(url:String, target:String):void
		{
			if (customProcess) startShell(false);
			customInfo = renewProcessInfo();
			customInfo.workingDirectory = new File(target);
			
			queue = new Vector.<Object>();
			
			addToQueue(new NativeProcessQueueVO(ConstantsCoreVO.IS_MACOS ? gitBinaryPathOSX +' clone --progress -v '+ url : 'git&&clone&&--progress&&-v&&'+ url, false, GitHubPlugin.CLONE_REQUEST));
			
			if (customProcess) startShell(false);
			startShell(true);
			flush();
		}
		
		public function checkDiff():void
		{
			if (customProcess) startShell(false);
			if (!model.activeProject) return;
			
			customInfo = renewProcessInfo();
			customInfo.workingDirectory = model.activeProject.folderLocation.fileBridge.getFile as File;
			
			queue = new Vector.<Object>();
			
			addToQueue(new NativeProcessQueueVO(ConstantsCoreVO.IS_MACOS ? gitBinaryPathOSX +' status --porcelain': 'git&&status&&--porcelain', false, GIT_DIFF_CHECK));
			
			if (customProcess) startShell(false);
			startShell(true);
			flush();
		}
		
		public function commit(files:ArrayCollection, withMessage:String):void
		{
			if (customProcess) startShell(false);
			if (!model.activeProject) return;
			
			customInfo = renewProcessInfo();
			customInfo.workingDirectory = model.activeProject.folderLocation.fileBridge.getFile as File;
			
			queue = new Vector.<Object>();
			
			var filesToCommit:Array = [];
			for each (var i:GenericSelectableObject in files)
			{
				if (i.isSelected) filesToCommit.push(i.data.path as String);
			}
			
			addToQueue(new NativeProcessQueueVO(ConstantsCoreVO.IS_MACOS ? gitBinaryPathOSX +' add '+ filesToCommit.join(' ') : 'git&&add&&'+ filesToCommit.join('&&'), false, GIT_COMMIT));
			addToQueue(new NativeProcessQueueVO(ConstantsCoreVO.IS_MACOS ? gitBinaryPathOSX +' commit -m "'+ withMessage +'"' : 'git&&commit&&-m&&"'+ withMessage +'"', false, GIT_COMMIT));
			
			if (customProcess) startShell(false);
			startShell(true);
			flush();
		}
		
		public function revert(files:ArrayCollection):void
		{
			if (customProcess) startShell(false);
			if (!model.activeProject) return;
			
			customInfo = renewProcessInfo();
			customInfo.workingDirectory = model.activeProject.folderLocation.fileBridge.getFile as File;
			
			queue = new Vector.<Object>();
			
			var filesDeletedOrModified:Array = [];
			var filesAdded:Array = [];
			for each (var i:GenericSelectableObject in files)
			{
				if (i.isSelected) 
				{
					switch(i.data.status)
					{
						case GitProcessManager.GIT_STATUS_FILE_DELETED:
						case GitProcessManager.GIT_STATUS_FILE_MODIFIED:
							filesDeletedOrModified.push(i.data.path);
							break;
							
						case GitProcessManager.GIT_STATUS_FILE_NEW:
							filesAdded.push(i.data.path);
							break;
					}
				}
			}
			
			if (filesDeletedOrModified.length > 0) addToQueue(new NativeProcessQueueVO(ConstantsCoreVO.IS_MACOS ? gitBinaryPathOSX +' checkout '+ filesDeletedOrModified.join(' ') : 'git&&checkout&&'+ filesDeletedOrModified.join('&&'), false, GIT_CHECKOUT_BRANCH));
			for each (var j:String in filesAdded)
			{
				addToQueue(new NativeProcessQueueVO(ConstantsCoreVO.IS_MACOS ? gitBinaryPathOSX +' reset '+ j : 'git&&reset&&'+ j, false, null));
			}
			
			if (customProcess) startShell(false);
			startShell(true);
			flush();
		}
		
		public function push(userObject:Object=null):void
		{
			if (customProcess) startShell(false);
			if (!model.activeProject) return;
			
			// safe-check
			if (!ConstantsCoreVO.IS_MACOS && !userObject && !plugin.modelAgainstProject[model.activeProject].sessionUser)
			{
				error("Git requires to authenticate to Push");
				return;
			}
			
			var tmpModel:GitProjectVO = plugin.modelAgainstProject[model.activeProject];
			var userName:String;
			var password:String;
			
			if (!ConstantsCoreVO.IS_MACOS)
			{
				userName = tmpModel.sessionUser ? tmpModel.sessionUser : userObject.userName;
				password = tmpModel.sessionPassword ? tmpModel.sessionPassword : userObject.password;
			}
			
			customInfo = renewProcessInfo();
			customInfo.workingDirectory = model.activeProject.folderLocation.fileBridge.getFile as File;
			
			queue = new Vector.<Object>();
			
			//git push https://user:pass@github.com/user/project.git
			addToQueue(new NativeProcessQueueVO(ConstantsCoreVO.IS_MACOS ? gitBinaryPathOSX +' push -v origin '+ tmpModel.currentBranch : 'git&&push&&https://'+ userName +':'+ password +'@'+ tmpModel.remoteURL +'.git&&'+ tmpModel.currentBranch, false, GIT_PUSH));
			
			warning("Git push requested...");
			if (customProcess) startShell(false);
			startShell(true);
			flush();
		}
		
		public function pull():void
		{
			if (customProcess) startShell(false);
			if (!model.activeProject) return;
			
			var tmpModel:GitProjectVO = plugin.modelAgainstProject[model.activeProject];
			
			customInfo = renewProcessInfo();
			customInfo.workingDirectory = model.activeProject.folderLocation.fileBridge.getFile as File;
			
			queue = new Vector.<Object>();
			
			addToQueue(new NativeProcessQueueVO(ConstantsCoreVO.IS_MACOS ? gitBinaryPathOSX +' pull --progress -v --no-rebase origin '+ tmpModel.currentBranch : 'git&&pull&&--progress&&-v&&--no-rebase&&origin&&'+ tmpModel.currentBranch, false, GitHubPlugin.PULL_REQUEST));
			
			if (customProcess) startShell(false);
			startShell(true);
			flush();
		}
		
		public function switchBranch():void
		{
			if (customProcess) startShell(false);
			if (!model.activeProject) return;
			
			customInfo = renewProcessInfo();
			customInfo.workingDirectory = model.activeProject.folderLocation.fileBridge.getFile as File;
			
			queue = new Vector.<Object>();
			
			addToQueue(new NativeProcessQueueVO(ConstantsCoreVO.IS_MACOS ? gitBinaryPathOSX +' fetch' : 'git&&fetch', false, null));
			addToQueue(new NativeProcessQueueVO(ConstantsCoreVO.IS_MACOS ? gitBinaryPathOSX +' branch -r' : 'git&&branch&&-r', false, GIT_REMOTE_BRANCH_LIST));
			pendingProcess.push(new MethodDescriptor(this, 'getCurrentBranch')); // next method we need to fire when above done
			
			warning("Fetching branch details...");
			if (customProcess) startShell(false);
			startShell(true);
			flush();
		}
		
		public function getCurrentBranch():void
		{
			if (customProcess) startShell(false);
			if (!model.activeProject) return;
			
			customInfo = renewProcessInfo();
			customInfo.workingDirectory = model.activeProject.folderLocation.fileBridge.getFile as File;
			
			queue = new Vector.<Object>();
			
			addToQueue(new NativeProcessQueueVO(ConstantsCoreVO.IS_MACOS ? gitBinaryPathOSX +' branch' : 'git&&branch', false, GIT_CURRENT_BRANCH_NAME));
			
			if (customProcess) startShell(false);
			startShell(true);
			flush();
		}
		
		public function changeBranchTo(value:GenericSelectableObject):void
		{
			if (customProcess) startShell(false);
			if (!model.activeProject) return;
			
			customInfo = renewProcessInfo();
			customInfo.workingDirectory = model.activeProject.folderLocation.fileBridge.getFile as File;
			
			queue = new Vector.<Object>();
			
			addToQueue(new NativeProcessQueueVO(ConstantsCoreVO.IS_MACOS ? gitBinaryPathOSX +' checkout '+ (value.data as String): 'git&&checkout&&'+ (value.data as String), false, GIT_CHECKOUT_BRANCH));
			pendingProcess.push(new MethodDescriptor(this, "getCurrentBranch"));
			
			notice("Trying to switch branch...");
			if (customProcess) startShell(false);
			startShell(true);
			flush();
		}
		
		public function createAndCheckoutNewBranch(name:String, pushToOrigin:Boolean, userObject:Object=null):void
		{
			if (customProcess) startShell(false);
			if (!model.activeProject) return;
			
			// safe-check
			if (!ConstantsCoreVO.IS_MACOS && !userObject && !plugin.modelAgainstProject[model.activeProject].sessionUser)
			{
				error("Git requires to authenticate to Push");
				return;
			}
			
			var tmpModel:GitProjectVO = plugin.modelAgainstProject[model.activeProject];
			
			customInfo = renewProcessInfo();
			customInfo.workingDirectory = model.activeProject.folderLocation.fileBridge.getFile as File;
			
			queue = new Vector.<Object>();
			
			// https://stackoverflow.com/questions/1519006/how-do-you-create-a-remote-git-branch
			addToQueue(new NativeProcessQueueVO(ConstantsCoreVO.IS_MACOS ? gitBinaryPathOSX +' checkout -b '+ name : 'git&&checkout&&-b&&'+ name, false, GIT_CHECKOUT_NEW_BRANCH));
			pendingProcess.push(new MethodDescriptor(this, "getCurrentBranch"));
			if (pushToOrigin) 
			{
				pendingProcess.push(new MethodDescriptor(this, 'push', ConstantsCoreVO.IS_MACOS ? null : {userName:tmpModel.sessionUser ? tmpModel.sessionUser : userObject.userName, password: tmpModel.sessionPassword ? tmpModel.sessionPassword : userObject.password})); // next method we need to fire when above done
			}
			
			notice("Trying to switch branch...");
			if (customProcess) startShell(false);
			startShell(true);
			flush();
		}
		
		public function checkout():void
		{
			if (customProcess) startShell(false);
			if (!model.activeProject) return;
			
			var tmpModel:GitProjectVO = plugin.modelAgainstProject[model.activeProject];
			
			customInfo = renewProcessInfo();
			customInfo.workingDirectory = model.activeProject.folderLocation.fileBridge.getFile as File;
			
			queue = new Vector.<Object>();
			
			addToQueue(new NativeProcessQueueVO(ConstantsCoreVO.IS_MACOS ? gitBinaryPathOSX +' checkout '+ tmpModel.currentBranch +' --' : 'git&&checkout&&'+ tmpModel.currentBranch +'&&--', false, GIT_CHECKOUT_BRANCH));
			
			if (customProcess) startShell(false);
			startShell(true);
			flush();
		}
		
		private function addToQueue(value:Object):void
		{
			queue.push(value);
		}
		
		private function flush():void
		{
			if (queue.length == 0) 
			{
				startShell(false);
				
				// starts checking pending process here
				if (pendingProcess.length > 0)
				{
					var process:MethodDescriptor = pendingProcess.shift();
					process.callMethod();
				}
				return;
			}
			
			if (queue[0].showInConsole) debug("Sending to command: %s", queue[0].com);
			
			var tmpArr:Array = queue[0].com.split("&&");
			if (Settings.os == "win") tmpArr.insertAt(0, "/c");
			else tmpArr.insertAt(0, "-c");
			processType = queue[0].processType;
			customInfo.arguments = Vector.<String>(tmpArr);
			
			queue.shift();
			customProcess.start(customInfo);
		}
		
		private function startShell(start:Boolean):void 
		{
			if (start)
			{
				customProcess = new NativeProcess();
				customProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);
				
				// @note
				// for some strange reason all the standard output turns to standard error output by git command line.
				// to have them dictate and continue the native process (without terminating by assuming as an error)
				// let's listen standard errors to shellData method only
				customProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellData);
				
				customProcess.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, shellError);
				customProcess.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, shellError);
				customProcess.addEventListener(NativeProcessExitEvent.EXIT, shellExit);
			}
			else
			{
				if (!customProcess) return;
				if (customProcess.running) customProcess.exit();
				customProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);
				customProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellData);
				customProcess.removeEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, shellError);
				customProcess.removeEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, shellError);
				customProcess.removeEventListener(NativeProcessExitEvent.EXIT, shellExit);
				customProcess = null;
				processType = null;
				isErrorClose = false;
				GlobalEventDispatcher.getInstance().dispatchEvent(new CompilerEventBase(CompilerEventBase.STOP_DEBUG,false));
			}
		}
		
		private function shellError(e:ProgressEvent):void 
		{
			if (customProcess)
			{
				var output:IDataInput = customProcess.standardError;
				var data:String = output.readUTFBytes(output.bytesAvailable).toLowerCase();
				
				var syntaxMatch:Array;
				var generalMatch:Array;
				var initMatch:Array;
				var hideDebug:Boolean;
				
				syntaxMatch = data.match(/(.*?)\((\d*)\): col: (\d*) error: (.*).*/);
				if (syntaxMatch) {
					var pathStr:String = syntaxMatch[1];
					var lineNum:int = syntaxMatch[2];
					var colNum:int = syntaxMatch[3];
					var errorStr:String = syntaxMatch[4];
				}
				
				generalMatch = data.match(/(.*?): error: (.*).*/);
				if (!syntaxMatch && generalMatch)
				{ 
					pathStr = generalMatch[1];
					errorStr  = generalMatch[2];
					pathStr = pathStr.substr(pathStr.lastIndexOf("/")+1);
					error(data);
					hideDebug = true;
				}
				
				if (!hideDebug) debug("%s", data);
				isErrorClose = true;
				startShell(false);
			}
		}
		
		private function shellExit(e:NativeProcessExitEvent):void 
		{
			if (customProcess) 
			{
				if (!isErrorClose) 
				{
					switch (processType)
					{
						case GitHubPlugin.CLONE_REQUEST:
							success("'"+ cloningProjectName +"'...downloaded successfully ("+ customInfo.workingDirectory.nativePath + File.separator + cloningProjectName +")");
							break;
						case GIT_PUSH:
							success("...process completed");
							break;
						case GIT_CHECKOUT_BRANCH:
						case GIT_CHECKOUT_NEW_BRANCH:
						case GitHubPlugin.PULL_REQUEST:
							refreshProjectTree(); // important
							break;
					}
					
					flush();
				}
			}
		}
		
		private function shellData(e:ProgressEvent):void 
		{
			var output:IDataInput = (customProcess.standardOutput.bytesAvailable != 0) ? customProcess.standardOutput : customProcess.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			var match:Array;
			var isFatal:Boolean;
			
			match = data.match(/fatal: .*/);
			if (match) isFatal = true;
			
			match = data.toLowerCase().match(/(.*?)error: (.*).*/);
			if (match)
			{ 
				error(data);
				isErrorClose = true;
				startShell(false);
				return;
			}
			
			switch(processType)
			{
				case XCODE_PATH_DECTECTION:
				{
					match = data.toLowerCase().match(/xcode.app\/contents\/developer/);
					if (match && (onXCodePathDetection != null))
					{
						onXCodePathDetection(data);
						return;
					}
					
					match = data.toLowerCase().match(/commandlinetools/);
					if (match && (onXCodePathDetection != null))
					{
						onXCodePathDetection(data);
						return;
					}
					break;
				}
				case GIT_AVAIL_DECTECTION:
				{
					match = data.toLowerCase().match(/git version/);
					if (match) 
					{
						setGitAvailable(true);
						return;
					}
					
					match = data.toLowerCase().match(/'git' is not recognized as an internal or external command/);
					if (match)
					{
						setGitAvailable(false);
						isErrorClose = true;
						startShell(false);
						return;
					}
					break;
				}
				case GIT_REPOSITORY_TEST:
				{
					if (!isFatal)
					{
						gitTestProject.menuType += ","+ ProjectMenuTypes.GIT_PROJECT;
						if (plugin.modelAgainstProject[gitTestProject] == undefined) plugin.modelAgainstProject[gitTestProject] = new GitProjectVO();
						
						// continuing fetch
						pendingProcess.push(new MethodDescriptor(this, 'getCurrentBranch')); // store the current branch
						pendingProcess.push(new MethodDescriptor(this, 'getGitRemoteURL')); // store the remote URL
						
						gitTestProject = null;
						dispatchEvent(new GeneralEvent(GIT_REPOSITORY_TEST));
					}
					else if (ConstantsCoreVO.IS_MACOS)
					{
						// in case of OSX sandbox if the project's parent folder
						// consists of '.git' and do not have bookmark access
						// the running command is tend to be fail, in that case
						// a brute check
						initiateSandboxGitRepositoryCheckBrute(gitTestProject);
					}
					return;
				}
				case GitHubPlugin.CLONE_REQUEST:
				{
					match = data.toLowerCase().match(/cloning into/);
					if (match)
					{
						// for some weird reason git clone always
						// turns to errordata first
						cloningProjectName = data;
						warning(data);
						return;
					}
					break;
				}
				case GIT_DIFF_CHECK:
				{
					if (!isFatal) checkDiffFileExistence(data);
					break;
				}
				case GIT_REMOTE_ORIGIN_URL:
				{
					match = data.match(/.*.$/);
					if (match)
					{
						var tmpResult:Array = new RegExp("http.*\://", "i").exec(data);
						if (tmpResult != null)
						{
							// extracting remote origin URL as 'github/[author]/[project]
							if (plugin.modelAgainstProject[model.activeProject] != undefined) plugin.modelAgainstProject[model.activeProject].remoteURL = data.substr(tmpResult[0].length, data.length).replace("\n", "");
						}
						return;
					}
					break;
				}
				case GIT_REMOTE_BRANCH_LIST:
				{
					if (!isFatal) parseRemoteBranchList(data);
					return;
				}
				case GIT_CURRENT_BRANCH_NAME:
				{
					parseCurrentBranch(data);
					return;
				}
				case GIT_CHECKOUT_BRANCH:
				case GIT_CHECKOUT_NEW_BRANCH:
				{
					if (isFatal) isErrorClose = true;
					break;
				}
				case GitHubPlugin.PULL_REQUEST:
				{
					if (isFatal) isErrorClose = true;
					break;
				}
			}
			
			if (isFatal)
			{
				error(data);
				isErrorClose = true;
				startShell(false);
				return;
			}

			isErrorClose = false;
			debug("%s", data);
		}
		
		private function renewProcessInfo():NativeProcessStartupInfo
		{
			customInfo = new NativeProcessStartupInfo();
			customInfo.executable = (Settings.os == "win") ? new File("c:\\Windows\\System32\\cmd.exe") : new File("/bin/bash");
			
			return customInfo;
		}
		
		private function initiateSandboxGitRepositoryCheckBrute(value:AS3ProjectVO):void
		{
			var tmpFile:File = value.folderLocation.fileBridge.getFile as File;
			do
			{
				tmpFile = tmpFile.parent;
				if (tmpFile && tmpFile.resolvePath(".git").exists && tmpFile.resolvePath(".git/index").exists)
				{
					dispatchEvent(new GeneralEvent(GIT_REPOSITORY_TEST, {project:value, gitRootLocation:tmpFile}));
					break;
				}
				
			} while (tmpFile != null);
		}
		
		private function checkDiffFileExistence(value:String):void
		{
			var tmpPositions:ArrayCollection = new ArrayCollection();
			var contentInLineBreaks:Array = value.split("\n");
			var firstPart:String;
			var secondPart:String;
			contentInLineBreaks.forEach(function(element:String, index:int, arr:Array):void
			{
				if (element != "")
				{
					element = StringUtil.trim(element);
					firstPart = element.substring(0, element.indexOf(" "));
					secondPart = element.substr(element.indexOf(" ")+1, element.length);
					
					// in some cases the output comes surrounding with double-quote
					// we need to remove them before a commit
					secondPart = secondPart.replace(/\"/g, "");
					secondPart = StringUtil.trim(secondPart);
					
					tmpPositions.addItem(new GenericSelectableObject(true, {path: secondPart, status:getFileStatus(firstPart)}));
				}
			});
			
			dispatchEvent(new GeneralEvent(GIT_DIFF_CHECKED, tmpPositions));
			
			/*
			* @local
			*/
			function getFileStatus(value:String):String
			{
				if (value == "D") return GIT_STATUS_FILE_DELETED;
				else if (value == "??" || value == "A") return GIT_STATUS_FILE_NEW;
				return GIT_STATUS_FILE_MODIFIED;
			}
		}
		
		private function parseRemoteBranchList(value:String):void
		{
			if (model.activeProject && plugin.modelAgainstProject[model.activeProject] != undefined)
			{
				var tmpModel:GitProjectVO = plugin.modelAgainstProject[model.activeProject];
				
				tmpModel.branchList = new ArrayCollection();
				var contentInLineBreaks:Array = value.split("\n");
				contentInLineBreaks.forEach(function(element:String, index:int, arr:Array):void
				{
					if (element != "" && element.indexOf("origin/") != -1 && element.indexOf("->") == -1)
					{
						tmpModel.branchList.addItem(new GenericSelectableObject(false, element.substr(element.indexOf("origin/")+7, element.length)));
					}
				});
			}
		}
		
		private function parseCurrentBranch(value:String):void
		{
			var starredIndex:int = value.indexOf("* ") + 2;
			var selectedBranchName:String = value.substring(starredIndex, value.indexOf("\n", starredIndex));
			
			// store the project's selected branch to its model
			if (model.activeProject && plugin.modelAgainstProject[model.activeProject] != undefined)
			{
				var tmpModel:GitProjectVO = plugin.modelAgainstProject[model.activeProject];
				tmpModel.currentBranch = selectedBranchName;
				
				for each (var i:GenericSelectableObject in tmpModel.branchList)
				{
					if (i.data == selectedBranchName)
					{
						i.isSelected = true;
						dispatchEvent(new GeneralEvent(GIT_REMOTE_BRANCH_LIST, tmpModel.branchList));
						break;
					}
				}
			}
		}
		
		private function refreshProjectTree():void
		{
			// refreshing project tree
			GlobalEventDispatcher.getInstance().dispatchEvent(new ProjectEvent(ProjectEvent.PROJECT_FILES_UPDATES, model.activeProject.projectFolder));
		}
	}
}