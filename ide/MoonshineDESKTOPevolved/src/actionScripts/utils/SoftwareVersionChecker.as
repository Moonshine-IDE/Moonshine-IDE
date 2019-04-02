////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
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
// Author: Prominic.NET, Inc. 
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
////////////////////////////////////////////////////////////////////////////////
package actionScripts.utils
{
	import mx.collections.ArrayCollection;
	
	import actionScripts.events.GeneralEvent;
	import actionScripts.events.WorkerEvent;
	import actionScripts.locator.IDEModel;
	import actionScripts.locator.IDEWorker;
	import actionScripts.plugin.console.ConsoleOutputter;
	import actionScripts.plugins.git.model.MethodDescriptor;
	import actionScripts.valueObjects.ComponentTypes;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.WorkerNativeProcessResult;
	import actionScripts.vo.NativeProcessQueueVO;

	public class SoftwareVersionChecker extends ConsoleOutputter
	{
		private static const QUERY_FLEX_AIR_VERSION:String = "getFlexAIRversion";
		private static const QUERY_ROYALE_FJS_VERSION:String = "getRoyaleFlexJSversion";
		private static const QUERY_JDK_VERSION:String = "getJDKVersion";
		private static const QUERY_ANT_VERSION:String = "getAntVersion";
		private static const QUERY_MAVEN_VERSION:String = "getMavenVersion";
		private static const QUERY_SVN_GIT_VERSION:String = "getSVNGitVersion";
		
		public var pendingProcess:Array /* of MethodDescriptor */ = [];
		
		protected var processType:String;
		
		private var worker:IDEWorker = IDEWorker.getInstance();
		private var queue:Vector.<Object> = new Vector.<Object>();
		private var model:IDEModel = IDEModel.getInstance();
		private var components:ArrayCollection;
		private var lastOutput:String;
		private var lineBreak:String;
		
		/**
		 * CONSTRUCTOR
		 */
		public function SoftwareVersionChecker()
		{
			lineBreak = ConstantsCoreVO.IS_MACOS ? "\n" : "\r\n";
			worker.sendToWorker(WorkerEvent.SET_IS_MACOS, ConstantsCoreVO.IS_MACOS);
			worker.addEventListener(IDEWorker.WORKER_VALUE_INCOMING, onWorkerValueIncoming, false, 0, true);
		}
		
		/**
		 * Checks some required/optional software installation
		 * and their version if available
		 */
		public function retrieveAboutInformation(items:ArrayCollection):void
		{
			var executable:String;
			components = items;
			for (var index:int=0; index < components.length; index++)
			{
				if (components[index].installToPath != null)
				{
					queue = new Vector.<Object>();
					switch (components[index].type)
					{
						case ComponentTypes.TYPE_FLEX:
						case ComponentTypes.TYPE_FEATHERS:
						case ComponentTypes.TYPE_FLEXJS:
							executable = ConstantsCoreVO.IS_MACOS ? "mxmlc" : "mxmlc.bat";
							addToQueue(new NativeProcessQueueVO(getPlatformMessage(components[index].installToPath+'/bin/'+ executable +'&&--version'), false, QUERY_FLEX_AIR_VERSION, index));
							executable = ConstantsCoreVO.IS_MACOS ? "adt" : "adt.bat";
							addToQueue(new NativeProcessQueueVO(getPlatformMessage(components[index].installToPath+'/bin/'+ executable +'&&-version'), false, QUERY_FLEX_AIR_VERSION, index));
							worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {queue:queue, workingDirectory:null});
							break;
						case ComponentTypes.TYPE_ROYALE:
							executable = ConstantsCoreVO.IS_MACOS ? "mxmlc" : "mxmlc.bat";
							addToQueue(new NativeProcessQueueVO(getPlatformMessage(components[index].installToPath+'/js/bin/'+ executable +'&&--version'), false, QUERY_ROYALE_FJS_VERSION, index));
							worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {queue:queue, workingDirectory:null});
							break;
						case ComponentTypes.TYPE_OPENJAVA:
							addToQueue(new NativeProcessQueueVO(getPlatformMessage(components[index].installToPath+'/bin/java&&-version'), false, QUERY_JDK_VERSION, index));
							worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {queue:queue, workingDirectory:null});
							break;
						case ComponentTypes.TYPE_ANT:
							executable = ConstantsCoreVO.IS_MACOS ? "ant" : "ant.bat";
							addToQueue(new NativeProcessQueueVO(getPlatformMessage(components[index].installToPath+'/bin/'+ executable +'&&-version'), false, QUERY_ANT_VERSION, index));
							worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {queue:queue, workingDirectory:null});
							break;
						case ComponentTypes.TYPE_MAVEN:
							executable = ConstantsCoreVO.IS_MACOS ? "mvn" : "mvn.cmd";
							addToQueue(new NativeProcessQueueVO(getPlatformMessage(components[index].installToPath+'/bin/'+ executable +'&&-version'), false, QUERY_MAVEN_VERSION, index));
							worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {queue:queue, workingDirectory:null});
							break;
						case ComponentTypes.TYPE_SVN:
						case ComponentTypes.TYPE_GIT:
							addToQueue(new NativeProcessQueueVO(getPlatformMessage(components[index].installToPath+'&&--version'), false, QUERY_SVN_GIT_VERSION, index));
							worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {queue:queue, workingDirectory:null});
							break;
					}
				}
			}
		}
		
		private function getPlatformMessage(value:String):String
		{
			if (ConstantsCoreVO.IS_MACOS)
			{
				value = value.replace(/(&&)/g, " ");
				return value;
			}
			
			return value;
		}
		
		private function onWorkerValueIncoming(event:GeneralEvent):void
		{
			var tmpValue:Object = event.value.value;
			switch (event.value.event)
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
					// starts checking pending process here
					if (pendingProcess.length > 0)
					{
						var process:MethodDescriptor = pendingProcess.shift();
						process.callMethod();
					}
					break;
				case WorkerEvent.CONSOLE_MESSAGE_NATIVEPROCESS_OUTPUT:
					//debug("%s", event.value.value);
					break;
			}
		}
		
		private function addToQueue(value:Object):void
		{
			queue.push(value);
		}
		
		private function listOfProcessEnded():void
		{
			switch (processType)
			{
				case QUERY_FLEX_AIR_VERSION:
					success("...process completed");
					break;
			}
		}
		
		private function shellError(value:Object /** type of WorkerNativeProcessResult **/):void 
		{
			error(value.output);
		}
		
		private function shellExit(value:Object /** type of WorkerNativeProcessResult **/):void 
		{
			var tmpQueue:Object = value.queue; /** type of NativeProcessQueueVO **/
			if (tmpQueue.extraArguments && tmpQueue.extraArguments.length != 0 && lastOutput)
			{
				var tmpIndex:int = int(tmpQueue.extraArguments[0]);
				switch (tmpQueue.processType)
				{
					case QUERY_FLEX_AIR_VERSION:
						if (!components[tmpIndex].version) components[tmpIndex].version = lastOutput;
						else components[tmpIndex].version += ", "+ lastOutput;
						break;
				}
			}
			
			lastOutput = null;
		}
		
		private function shellTick(value:Object /** type of NativeProcessQueueVO **/):void
		{
			/*var tmpIndex:int = int(value.extraArguments[0]);
			switch (value.processType)
			{
			case QUERY_FLEX_AIR_VERSION:
			if (!components[tmpIndex].version) components[tmpIndex].version = lastOutput;
			else components[tmpIndex].version += ", "+ lastOutput;
			break;
			}*/
		}
		
		private function shellData(value:Object /** type of WorkerNativeProcessResult **/):void 
		{
			var match:Array;
			var tmpQueue:Object = value.queue; /** type of NativeProcessQueueVO **/
			var isFatal:Boolean;
			var tmpProject:ProjectVO;
			
			match = value.output.match(/fatal: .*/);
			if (match) isFatal = true;
			
			match = value.output.match(/is not recognized as an internal or external command/);
			if (!match)
			{
				switch(tmpQueue.processType)
				{
					case QUERY_FLEX_AIR_VERSION:
					{
						lastOutput = value.output.split(lineBreak)[0];
						break;
					}
					case QUERY_ROYALE_FJS_VERSION:
						match = value.output.match(/Version /);
						if (match)
						{
							components[int(tmpQueue.extraArguments[0])].version = value.output.split(lineBreak)[0];
						}
						break;
					case QUERY_JDK_VERSION:
					case QUERY_ANT_VERSION:
					case QUERY_MAVEN_VERSION:
					case QUERY_SVN_GIT_VERSION:
					{
						if (!components[int(tmpQueue.extraArguments[0])].version)
						{
							components[int(tmpQueue.extraArguments[0])].version = value.output.split(lineBreak)[0];
						}
						break;
					}
				}
			}
			
			if (isFatal)
			{
				shellError(value);
				return;
			}
			else
			{
				//notice(value.output);
			}
		}
		
		/**
		 * Retrieves Java path in OSX
		 */
		/*public function getJavaPath(completionHandler:Function):void
		{
			javaPathRetrievalHandler = completionHandler;
			cmdFile = File.documentsDirectory.resolvePath("/bin/bash");
			isMacOS = true;
			checkingQueues = ["/usr/libexec/java_home/ -v 1.8"];
			
			nativeInfoReaderHandler = parseJavaOnlyPath;
			startCheckingProcess();
		}*/
	}
}