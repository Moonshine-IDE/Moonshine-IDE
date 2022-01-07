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
	import flash.events.Event;

	import mx.collections.ArrayCollection;

	import mx.utils.UIDUtil;
	
	import actionScripts.events.WorkerEvent;
	import actionScripts.interfaces.IWorkerSubscriber;
	import actionScripts.locator.IDEWorker;
	import actionScripts.plugin.console.ConsoleOutputter;
	import actionScripts.plugin.help.HelpPlugin;
	import actionScripts.valueObjects.ComponentTypes;
	import actionScripts.valueObjects.ComponentVO;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.WorkerNativeProcessResult;
	import actionScripts.valueObjects.NativeProcessQueueVO;

	public class SoftwareVersionChecker extends ConsoleOutputter implements IWorkerSubscriber
	{
		private static const QUERY_FLEX_AIR_VERSION:String = "getFlexAIRversion";
		private static const QUERY_ROYALE_FJS_VERSION:String = "getRoyaleFlexJSversion";
		private static const QUERY_JDK_VERSION:String = "getJDKVersion";
		private static const QUERY_JDK_8_VERSION:String = "getJDK8Version";
		private static const QUERY_ANT_VERSION:String = "getAntVersion";
		private static const QUERY_MAVEN_VERSION:String = "getMavenVersion";
		private static const QUERY_SVN_GIT_VERSION:String = "getSVNGitVersion";
		private static const QUERY_GRADLE_VERSION:String = "getGradleVersion";
		private static const QUERY_GRAILS_VERSION:String = "getGrailsVersion";
		private static const QUERY_NODEJS_VERSION:String = "getNodeJSVersion";
		private static const QUERY_NOTES_VERSION:String = "getHCLNotesVersion";
		private static const QUERY_VAGRANT_VERSION:String = "getVagrantVersion";
		private static const QUERY_MACPORTS_VERSION:String = "getMacPortsVersion";
		
		public var pendingProcess:Array /* of MethodDescriptor */ = [];
		
		protected var processType:String;
		
		private var worker:IDEWorker = IDEWorker.getInstance();
		private var queue:Vector.<Object> = new Vector.<Object>();
		private var environmentSetup:EnvironmentSetupUtils = EnvironmentSetupUtils.getInstance();
		private var components:ArrayCollection;
		private var lastOutput:String;
		private var subscribeIdToWorker:String;
		private var itemUnderCursorIndex:int;
		
		/**
		 * CONSTRUCTOR
		 */
		public function SoftwareVersionChecker()
		{
			if (HelpPlugin.ABOUT_SUBSCRIBE_ID_TO_WORKER)
			{
				subscribeIdToWorker = HelpPlugin.ABOUT_SUBSCRIBE_ID_TO_WORKER;
			}
			else
			{
				subscribeIdToWorker = HelpPlugin.ABOUT_SUBSCRIBE_ID_TO_WORKER = UIDUtil.createUID();
			}
			
			worker.subscribeAsIndividualComponent(subscribeIdToWorker, this);
			worker.sendToWorker(WorkerEvent.SET_IS_MACOS, ConstantsCoreVO.IS_MACOS, subscribeIdToWorker);
		}
		
		/**
		 * Checks some required/optional software installation
		 * and their version if available
		 */
		public function retrieveAboutInformation(items:ArrayCollection):void
		{
			components = items;
			startRequestProcess();
		}
		
		private function startRequestProcess():void
		{
			var itemTypeUnderCursor:String;
			if (itemUnderCursorIndex <= (components.length - 1))
			{
				var executable:String;
				var itemUnderCursor:ComponentVO = components.getItemAt(itemUnderCursorIndex) as ComponentVO;
				var executableFullPath:String;
				if (itemUnderCursor.installToPath != null)
				{
					var commands:String;
					queue = new Vector.<Object>();
					switch (itemUnderCursor.type)
					{
						case ComponentTypes.TYPE_FLEX:
						case ComponentTypes.TYPE_FLEX_HARMAN:
						case ComponentTypes.TYPE_FEATHERS:
						case ComponentTypes.TYPE_FLEXJS:
							executable = ConstantsCoreVO.IS_MACOS ? "mxmlc" : "mxmlc.bat";
							commands = '"'+ itemUnderCursor.installToPath+'/bin/'+ executable +'" --version' + (ConstantsCoreVO.IS_MACOS ? ';' : '&& ');
							executable = ConstantsCoreVO.IS_MACOS ? "adt" : "adt.bat";
							commands += '"'+ itemUnderCursor.installToPath+'/bin/'+ executable +'" -version';
							itemTypeUnderCursor = QUERY_FLEX_AIR_VERSION;
							break;
						case ComponentTypes.TYPE_ROYALE:
							executable = ConstantsCoreVO.IS_MACOS ? "mxmlc" : "mxmlc.bat";
							commands = '"'+ itemUnderCursor.installToPath+'/js/bin/'+ executable +'" --version';
							itemTypeUnderCursor = QUERY_ROYALE_FJS_VERSION;
							break;
						case ComponentTypes.TYPE_OPENJAVA:
						case ComponentTypes.TYPE_OPENJAVA_V8:
							commands = '"'+ itemUnderCursor.installToPath+'/bin/java" -version';
							itemTypeUnderCursor = (itemUnderCursor.type == ComponentTypes.TYPE_OPENJAVA_V8) ?
									QUERY_JDK_8_VERSION : QUERY_JDK_VERSION;
							break;
						case ComponentTypes.TYPE_ANT:
							executable = ConstantsCoreVO.IS_MACOS ? "ant" : "ant.bat";
							commands = '"'+ itemUnderCursor.installToPath+'/bin/'+ executable +'" -version';
							itemTypeUnderCursor = QUERY_ANT_VERSION;
							break;
						case ComponentTypes.TYPE_MAVEN:
							executable = ConstantsCoreVO.IS_MACOS ? "mvn" : "mvn.cmd";
							executableFullPath = itemUnderCursor.installToPath+'/bin/'+ executable;
							if (!FileUtils.isPathExists(executableFullPath))
							{
								executableFullPath = itemUnderCursor.installToPath+'/'+ executable;
							}
							commands = '"'+ executableFullPath +'" -version';
							itemTypeUnderCursor = QUERY_MAVEN_VERSION;
							break;
						case ComponentTypes.TYPE_SVN:
						case ComponentTypes.TYPE_GIT:
							commands = '"'+ itemUnderCursor.installToPath+'" --version';
							itemTypeUnderCursor = QUERY_SVN_GIT_VERSION;
							break;
						case ComponentTypes.TYPE_GRADLE:
							executable = ConstantsCoreVO.IS_MACOS ? "gradle" : "gradle.bat";
							commands = '"'+ itemUnderCursor.installToPath+'/bin/'+ executable +'" --version';
							itemTypeUnderCursor = QUERY_GRADLE_VERSION;
							break;
						case ComponentTypes.TYPE_GRAILS:
							executable = ConstantsCoreVO.IS_MACOS ? "grails" : "grails.bat";
							commands = '"'+ itemUnderCursor.installToPath+'/bin/'+ executable +'" --version';
							itemTypeUnderCursor = QUERY_GRAILS_VERSION;
							break;
						case ComponentTypes.TYPE_NODEJS:
							executable = ConstantsCoreVO.IS_MACOS ? "node" : "node.exe";
							if (ConstantsCoreVO.IS_MACOS) commands = '"'+ itemUnderCursor.installToPath+'/bin/'+ executable +'" --version';
							else commands = '"'+ itemUnderCursor.installToPath+'/'+ executable +'" --version';
							itemTypeUnderCursor = QUERY_NODEJS_VERSION;
							break;
						case ComponentTypes.TYPE_VAGRANT:
							executable = UtilsCore.getVagrantBinPath();
							if (executable)
							{
								if (ConstantsCoreVO.IS_MACOS) commands = '"'+ executable +'" --version';
								else commands = '"'+ executable +'" --version';
								itemTypeUnderCursor = QUERY_VAGRANT_VERSION;
							}
							break;
						case ComponentTypes.TYPE_MACPORTS:
							/*executable = UtilsCore.getMacPortsBinPath();
							if (executable)
							{
								commands = '"'+ executable +'" version';
								itemTypeUnderCursor = QUERY_MACPORTS_VERSION;
							}*/
							break;
						case ComponentTypes.TYPE_NOTES:
							if (ConstantsCoreVO.IS_MACOS)
							{
								commands = 'defaults read "'+ itemUnderCursor.installToPath+'"/Contents/Info CFBundleShortVersionString';
							}
							else
							{
								commands = '"'+ itemUnderCursor.installToPath+'/nsd.exe" -version';
							}
							itemTypeUnderCursor = QUERY_NOTES_VERSION;
							break;
					}
					
					environmentSetup.initCommandGenerationToSetLocalEnvironment(onEnvironmentPrepared, null, [commands]);
				}
				else
				{
					itemUnderCursorIndex++;
					startRequestProcess();
				}
			}
			else
			{
				dispatchEvent(new Event(Event.COMPLETE));
			}
			
			function onEnvironmentPrepared(value:String):void
			{
				addToQueue(new NativeProcessQueueVO(value, false, itemTypeUnderCursor, itemUnderCursorIndex));
				worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {queue:queue, workingDirectory:null}, subscribeIdToWorker);
				itemUnderCursorIndex++;
			}
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
					//success("...Flex Process completed");
					break;
			}
			
			startRequestProcess();
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
						components[tmpIndex].version = lastOutput;
						break;
					case QUERY_MAVEN_VERSION:
					case QUERY_GRADLE_VERSION:	
						components[tmpIndex].version = getVersionNumberedTypeLine(lastOutput);
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
			var versionNumberString:String;
			
			match = value.output.match(/fatal: .*/);
			if (match) isFatal = true;
			
			match = value.output.match(/is not recognized as an internal or external command/);
			if (!match)
			{
				switch(tmpQueue.processType)
				{
					case QUERY_FLEX_AIR_VERSION:
					{
						versionNumberString = getVersionNumberedTypeLine(value.output);
						if (!lastOutput && versionNumberString) lastOutput = versionNumberString;
						else if (versionNumberString) lastOutput += ", "+ versionNumberString;
						break;
					}
					case QUERY_ROYALE_FJS_VERSION:
						match = value.output.match(/Version /);
						if (match)
						{
							components[int(tmpQueue.extraArguments[0])].version = getVersionNumberedTypeLine(value.output);
						}
						break;
					case QUERY_VAGRANT_VERSION:
						match = value.output.match(/Vagrant /);
						if (match)
						{
							components[int(tmpQueue.extraArguments[0])].version = getVersionNumberedTypeLine(value.output);
						}
						break;
					case QUERY_MACPORTS_VERSION:
						break;
					case QUERY_JDK_VERSION:
					case QUERY_JDK_8_VERSION:
					case QUERY_ANT_VERSION:
					case QUERY_SVN_GIT_VERSION:
					case QUERY_NODEJS_VERSION:
					{
						if (!components[int(tmpQueue.extraArguments[0])].version)
						{
							versionNumberString = getVersionNumberedTypeLine(value.output);
							if (versionNumberString) components[int(tmpQueue.extraArguments[0])].version = versionNumberString;
						}
						break;
					}
					case QUERY_GRAILS_VERSION:
					{
						match = value.output.match(/Version:/);
						if (match && !components[int(tmpQueue.extraArguments[0])].version)
						{
							components[int(tmpQueue.extraArguments[0])].version = getVersionNumberedTypeLine(value.output);
						}
						break;
					}
					case QUERY_NOTES_VERSION:
						if (ConstantsCoreVO.IS_MACOS && !components[int(tmpQueue.extraArguments[0])].version)
						{
							components[int(tmpQueue.extraArguments[0])].version = value.output;
						}
						else if (!ConstantsCoreVO.IS_MACOS)
						{
							match = value.output.match(/Release /);
							if (match)
							{
								components[int(tmpQueue.extraArguments[0])].version = value.output.substring(value.output.indexOf("Release"), value.output.length - 3);
							}
						}
						break;
					case QUERY_MAVEN_VERSION:
					case QUERY_GRADLE_VERSION:
						// in case of 'mvn -version' on OSX the process
						// returns the full information in many shell-data
						// so we need to prepare the full output first
						// (unlike others) and extract the first line
						// from it
						if (!lastOutput) lastOutput = value.output;
						else lastOutput += value.output;
						break;
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
		
		private function getVersionNumberedTypeLine(value:String):String
		{
			var lines:Array = value.split(UtilsCore.getLineBreakEncoding());
			for each (var line:String in lines)
			{
				if ((line.match(/\d+.\d+.\d+/)) || line.match(/\d+.\d+/)) return line;
			}
			
			return null;
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