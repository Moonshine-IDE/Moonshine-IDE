////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
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