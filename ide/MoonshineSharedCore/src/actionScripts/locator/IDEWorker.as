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
package actionScripts.locator
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.utils.ByteArray;
	
	import actionScripts.events.GeneralEvent;
	
	public class IDEWorker extends EventDispatcher
	{
		public static const WORKER_VALUE_INCOMING:String = "WORKER_VALUE_INCOMING";
		
		[Embed(source="/elements/swf/MoonshineWorker.swf", mimeType="application/octet-stream")]
		private static var WORKER_SWF:Class;
		private static var instance:IDEWorker;
		
		private var mainToWorker:MessageChannel;
		private var workerToMain:MessageChannel;
		private var worker:Worker;
		
		public static function getInstance():IDEWorker 
		{	
			if (!instance) 
			{
				instance = new IDEWorker();
				instance.initWorker();
			}
			
			return instance;
		}
		
		public function initWorker():void
		{
			var workerBytes:ByteArray = new WORKER_SWF() as ByteArray;
			worker = WorkerDomain.current.createWorker(workerBytes, true);
			
			// send to worker
			mainToWorker = Worker.current.createMessageChannel(worker);
			worker.setSharedProperty("mainToWorker", mainToWorker);
			
			// receive from worker
			workerToMain = worker.createMessageChannel(Worker.current);
			workerToMain.addEventListener(Event.CHANNEL_MESSAGE, onWorkerToMain);
			worker.setSharedProperty("workerToMain", workerToMain);
			worker.start();
		}
		
		public function sendToWorker(type:String, value:Object):void
		{
			mainToWorker.send({event: type, value: value});
		}
		
		private function onWorkerToMain(event:Event): void
		{
			dispatchEvent(new GeneralEvent(WORKER_VALUE_INCOMING, workerToMain.receive()));
		}
	}
}