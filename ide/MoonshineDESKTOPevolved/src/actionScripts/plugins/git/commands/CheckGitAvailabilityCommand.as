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
	import actionScripts.valueObjects.NativeProcessQueueVO;

	public class CheckGitAvailabilityCommand extends GitCommandBase
	{
		private static const GIT_AVAIL_DECTECTION:String = "gitAvailableDectection";
		
		public function CheckGitAvailabilityCommand()
		{
			super();
			
			var versionMessage:String = getPlatformMessage(' --version');
			if(!versionMessage)
			{
				//when the git path isn't set at all, getPlatformMessage()
				//returns null because there's no command to run
				plugin.setGitAvailable(false);
				return;
			}
			
			queue = new Vector.<Object>();
			addToQueue(new NativeProcessQueueVO(versionMessage, false, GIT_AVAIL_DECTECTION));
			worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {queue:queue, workingDirectory:null}, subscribeIdToWorker);
		}
		
		override protected function shellData(value:Object):void
		{
			var match:Array;
			var tmpQueue:Object = value.queue; /** type of NativeProcessQueueVO **/
			
			switch(tmpQueue.processType)
			{
				case GIT_AVAIL_DECTECTION:
				{
					match = value.output.toLowerCase().match(/git version/);
					if (match) 
					{
						plugin.setGitAvailable(true);
						return;
					}
					
					match = value.output.toLowerCase().match(/'git' is not recognized as an internal or external command/);
					if (match)
					{
						plugin.setGitAvailable(false);
						return;
					}
					break;
				}
			}
			
			// call super - it might have some essential
			// commands to run
			super.shellData(value);
		}
	}
}