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
package actionScripts.plugins.git.commands
{
	import mx.utils.UIDUtil;
	
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.ProjectEvent;
	import actionScripts.events.StatusBarEvent;
	import actionScripts.events.WorkerEvent;
	import actionScripts.interfaces.IWorkerSubscriber;
	import actionScripts.locator.IDEModel;
	import actionScripts.locator.IDEWorker;
	import actionScripts.plugin.console.ConsoleOutputter;
	import actionScripts.plugin.settings.event.RequestSettingByNameEvent;
	import actionScripts.plugins.git.GitHubPlugin;
	import actionScripts.plugins.git.model.MethodDescriptor;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.WorkerNativeProcessResult;
	
	public class GitCommandBase extends ConsoleOutputter implements IWorkerSubscriber
	{
		override public function get name():String { return "Git Plugin"; }
		
		public var gitBinaryPathOSX:String;
		public var pendingProcess:Array /* of MethodDescriptor */ = [];
		public var methodStamp:MethodDescriptor;
		
		protected var plugin:GitHubPlugin;
		protected var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		protected var model:IDEModel = IDEModel.getInstance();
		protected var processType:String;
		protected var queue:Vector.<Object> = new Vector.<Object>();
		protected var subscribeIdToWorker:String = UIDUtil.createUID();
		protected var worker:IDEWorker = IDEWorker.getInstance();
		
		public function GitCommandBase()
		{
			getGitPluginReference();
			gitBinaryPathOSX = plugin.gitBinaryPathOSX;
			
			worker.subscribeAsIndividualComponent(subscribeIdToWorker, this);
			worker.sendToWorker(WorkerEvent.SET_IS_MACOS, ConstantsCoreVO.IS_MACOS, subscribeIdToWorker);
		}
		
		protected function unsubscribeFromWorker():void
		{
			worker.unSubscribeComponent(subscribeIdToWorker);
			worker = null;
			queue = null;
			methodStamp = null;
			plugin = null;
		}
		
		protected function getPlatformMessage(value:String):String
		{
			if (ConstantsCoreVO.IS_MACOS)
			{
				return gitBinaryPathOSX + value;
			}
			
			value = value.replace(/( )/g, "&&");
			return gitBinaryPathOSX + value;
		}
		
		public function onWorkerValueIncoming(value:Object):void
		{
			var tmpValue:Object = value.value;
			switch (value.event)
			{
				case WorkerEvent.RUN_NATIVEPROCESS_OUTPUT:
					if (tmpValue.type == WorkerNativeProcessResult.OUTPUT_TYPE_DATA) shellData(tmpValue);
					else if (tmpValue.type == WorkerNativeProcessResult.OUTPUT_TYPE_CLOSE) shellExit(tmpValue);
					else shellError(tmpValue);
					break;
				case WorkerEvent.RUN_LIST_OF_NATIVEPROCESS_PROCESS_TICK:
					if (queue.length != 0) queue.shift();
					processType = tmpValue.processType;
					shellTick(tmpValue);
					break;
				case WorkerEvent.RUN_LIST_OF_NATIVEPROCESS_ENDED:
					listOfProcessEnded();
					dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
					// starts checking pending process here
					if (pendingProcess.length > 0)
					{
						for each (var pp:MethodDescriptor in pendingProcess)
						{
							//var process:MethodDescriptor = pendingProcess.shift();
							pp.callMethod();
						}
					}
					unsubscribeFromWorker();
					break;
				case WorkerEvent.CONSOLE_MESSAGE_NATIVEPROCESS_OUTPUT:
					debug("%s", value.value);
					break;
			}
		}
		
		protected function addToQueue(value:Object):void
		{
			queue.push(value);
		}
		
		protected function listOfProcessEnded():void
		{
		}
		
		protected function shellError(value:Object /** type of WorkerNativeProcessResult **/):void 
		{
			var match:Array = value.output.toLowerCase().match(/'git' is not recognized as an internal or external command/);
			if (match)
			{
				plugin.setGitAvailable(false);
			}
			
			if (!match) error(value.output);
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
			unsubscribeFromWorker();
		}
		
		protected function shellExit(value:Object /** type of WorkerNativeProcessResult **/):void 
		{
			//unsubscribeFromWorker();
		}
		
		protected function shellTick(value:Object /** type of NativeProcessQueueVO **/):void
		{
		}
		
		protected function shellData(value:Object /** type of WorkerNativeProcessResult **/):void 
		{
			var match:Array;
			var isFatal:Boolean;
			
			match = value.output.match(/fatal: .*/);
			if (match) isFatal = true;
			
			if (isFatal)
			{
				shellError(value);
				return;
			}
			else
			{
				notice(value.output);
			}
		}
		
		protected function refreshProjectTree():void
		{
			// refreshing project tree
			GlobalEventDispatcher.getInstance().dispatchEvent(new ProjectEvent(ProjectEvent.PROJECT_FILES_UPDATES, model.activeProject.projectFolder));
		}
		
		private function getGitPluginReference():void
		{
			var tmpEvent:RequestSettingByNameEvent = new RequestSettingByNameEvent("actionScripts.plugins.git::GitHubPlugin");
			dispatcher.dispatchEvent(tmpEvent);
			
			plugin = tmpEvent.value as GitHubPlugin;
		}
	}
}