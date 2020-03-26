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
	import actionScripts.events.WorkerEvent;
	import actionScripts.plugin.console.ConsoleCommandEvent;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.vo.NativeProcessQueueVO;

	public class GitAddCommand extends GitCommandBase
	{
		public function GitAddCommand(filePath:String)
		{
			super();
			
			queue = new Vector.<Object>();
			
			addToQueue(new NativeProcessQueueVO(
				ConstantsCoreVO.IS_MACOS ? gitBinaryPathOSX +" add $'"+ UtilsCore.getEncodedForShell(filePath) +"'" : gitBinaryPathOSX +'&&add&&'+ UtilsCore.getEncodedForShell(filePath), false
			));
			
			notice("Adding.."+ filePath);
			worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {queue:queue, workingDirectory:model.activeProject.folderLocation.fileBridge.nativePath}, subscribeIdToWorker);
		}
		
		override protected function shellError(value:Object):void
		{
			super.shellError(value);
			
			// activates the console view (to ensure its showing)
			dispatcher.dispatchEvent(new ConsoleCommandEvent(ConsoleCommandEvent.EVENT_ACTIVATE));
		}
	}
}