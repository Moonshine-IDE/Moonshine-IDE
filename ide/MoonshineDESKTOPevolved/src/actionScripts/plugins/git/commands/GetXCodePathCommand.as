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

	public class GetXCodePathCommand extends GitCommandBase
	{
		private static const XCODE_PATH_DECTECTION:String = "xcodePathDectection";
		
		private var onXCodePathDetection:Function;
		private var xCodePathDetectionType:String;
		
		public function GetXCodePathCommand(completion:Function, against:String)
		{
			super();
			
			queue = new Vector.<Object>();
			onXCodePathDetection = completion;
			xCodePathDetectionType = against;
			
			addToQueue(new NativeProcessQueueVO('xcode-select -p', false, XCODE_PATH_DECTECTION));
			worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {queue:queue, workingDirectory:null}, subscribeIdToWorker);
		}
		
		override protected function shellError(value:Object):void
		{
			switch (value.queue.processType)
			{
				case XCODE_PATH_DECTECTION:
				{
					if (onXCodePathDetection != null)
					{
						onXCodePathDetection(null, true, null);
					}
				}
			}
			
			// call super - it might have some essential 
			// commands to run
			super.shellError(value);
		}
		
		override protected function shellData(value:Object):void
		{
			var match:Array;
			var tmpQueue:Object = value.queue; /** type of NativeProcessQueueVO **/
			
			switch(tmpQueue.processType)
			{
				case XCODE_PATH_DECTECTION:
				{
					value.output = value.output.replace("\n", "");
					match = value.output.toLowerCase().match(/xcode.app\/contents\/developer/);
					if (match && (onXCodePathDetection != null))
					{
						onXCodePathDetection(value.output, true, xCodePathDetectionType);
						onXCodePathDetection = null;
						return;
					}
					
					match = value.output.toLowerCase().match(/commandlinetools/);
					if (match && (onXCodePathDetection != null))
					{
						onXCodePathDetection(value.output, false, xCodePathDetectionType);
						onXCodePathDetection = null;
						return;
					}
					
					onXCodePathDetection = null;
					break;
				}
			}
			
			// call super - it might have some essential
			// commands to run
			super.shellData(value);
		}
		
		override protected function unsubscribeFromWorker():void
		{
			super.unsubscribeFromWorker();
			onXCodePathDetection = null;
		}
	}
}