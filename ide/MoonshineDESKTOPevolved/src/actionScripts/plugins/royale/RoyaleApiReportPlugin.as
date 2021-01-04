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
package actionScripts.plugins.royale
{
	import actionScripts.events.RefreshTreeEvent;
	import actionScripts.events.RoyaleApiReportEvent;
	import actionScripts.events.WorkerEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.interfaces.IWorkerSubscriber;
	import actionScripts.locator.IDEWorker;
	import actionScripts.plugin.IPlugin;
	import actionScripts.plugin.PluginBase;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.RoyaleApiReportVO;
	import actionScripts.valueObjects.NativeProcessQueueVO;

	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	import mx.utils.UIDUtil;

	public class RoyaleApiReportPlugin extends PluginBase implements IPlugin, IWorkerSubscriber
	{
		override public function get name():String			{ return "Apache Royale Api Report Plugin."; }
		override public function get author():String		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String	{ return "Apache Royale Api Report Plugin."; }

		private const API_REPORT_FILE_NAME:String = "apireport.csv";
		private const API_REPORT_LOG_FILE_NAME:String = "apireport.log";

		private var worker:IDEWorker = IDEWorker.getInstance();
		private var queue:Vector.<Object> = new Vector.<Object>();
		private var subscribeIdToWorker:String;

		private var hasErrors:Boolean;

		private var logFileStream:FileStream;
		private var fullReportPath:String;
		private var fullLogPath:String;

		public function RoyaleApiReportPlugin():void
		{
			super();
		}

		override public function activate():void
		{
			super.activate();

			subscribeIdToWorker = this.name + UIDUtil.createUID();

			dispatcher.addEventListener(RoyaleApiReportEvent.LAUNCH_REPORT_GENERATION, onLaunchReportGeneration);
		}

		override public function deactivate():void
		{
			super.deactivate();
		}

		private function onLaunchReportGeneration(event:RoyaleApiReportEvent):void
		{
			hasErrors = false;
			var reportConfig:RoyaleApiReportVO = event.reportConfiguration;

			fullLogPath = reportConfig.reportOutputLogPath +
											model.fileCore.separator +
											model.activeProject.name + "_" + API_REPORT_LOG_FILE_NAME;

			var logFile:File = new File(fullLogPath);
			logFileStream = new FileStream();
			logFileStream.open(logFile, FileMode.WRITE);
			logFileStream.writeUTFBytes("Log file for Apache Royale API report: " + new Date().toString() + '\r\n');

			var royaleMxmlc:String = reportConfig.royaleSdkPath + getMxmlcLocation();
			var flexConfig:String = reportConfig.flexSdkPath + getFlexConfigLocation();
			fullReportPath = reportConfig.reportOutputPath +
									   model.fileCore.separator +
									   model.activeProject.name + "_" + API_REPORT_FILE_NAME;

			var libraryPath:String = "";
			for each (var library:FileLocation in reportConfig.libraries)
			{
				libraryPath += " -library-path+=".concat(library.fileBridge.nativePath, " ");
			}

			worker.subscribeAsIndividualComponent(subscribeIdToWorker, this);

			var fullCommand:String = royaleMxmlc.concat(" ",
					libraryPath,
					"-api-report=", fullReportPath, " ",
					"-load-config=", flexConfig,  " ",
					reportConfig.mainAppFile);

			var reportCommand:NativeProcessQueueVO = new NativeProcessQueueVO(fullCommand, false);

			queue.push(reportCommand);

			worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {queue:queue, workingDirectory: reportConfig.workingDirectory}, subscribeIdToWorker);
		}

		private function getMxmlcLocation():String
		{
			return model.fileCore.separator + "bin" + model.fileCore.separator + "mxmlc";
		}

		public function getFlexConfigLocation():String
		{
			return model.fileCore.separator + "frameworks" + model.fileCore.separator + "flex-config.xml";
		}

		public function onWorkerValueIncoming(value:Object):void
		{
			switch (value.event)
			{
				case WorkerEvent.RUN_NATIVEPROCESS_OUTPUT:
					if (value.value.output)
					{
						var match:Array = value.value.output.match(/Error/);
						var noCommand:Array = value.value.output.match(/is not recognized as an internal or external command/);
						if(match || noCommand)
						{
							hasErrors = true;
						}

						print(value.value.output);
					}
					break;
				case WorkerEvent.RUN_LIST_OF_NATIVEPROCESS_PROCESS_TICK:
					if (queue.length != 0)
					{
						queue.shift();
					}
					break;
				case WorkerEvent.RUN_LIST_OF_NATIVEPROCESS_ENDED:
					var endMessage:String = "Generating report has ended. ";
					if (hasErrors)
					{
						endMessage = "Generating report has ended with some errors. ";
					}

					hasErrors = false;
					dispatcher.dispatchEvent(new RoyaleApiReportEvent(RoyaleApiReportEvent.REPORT_GENERATION_COMPLETED));

					print(endMessage);

					success(endMessage);
					warning("Log: " + fullLogPath);
					warning("Report path: " + fullReportPath);

					dispatcher.dispatchEvent(new RefreshTreeEvent(new FileLocation(fullReportPath)));

					logFileStream.close();
					logFileStream = null;
					break;
				case WorkerEvent.CONSOLE_MESSAGE_NATIVEPROCESS_OUTPUT:
					print("%s", value.value);
					break;
			}
		}

		override protected function print(str:String, ...replacements):void
		{
			if (logFileStream)
			{
				logFileStream.writeUTFBytes(str);
			}
		}
	}
}