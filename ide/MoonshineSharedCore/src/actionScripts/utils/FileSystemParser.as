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
package actionScripts.utils
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import mx.utils.UIDUtil;
	
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.WorkerEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.interfaces.IWorkerSubscriber;
	import actionScripts.locator.IDEModel;
	import actionScripts.locator.IDEWorker;
	import actionScripts.plugin.console.ConsoleOutputEvent;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.NativeProcessQueueVO;
	import actionScripts.valueObjects.WorkerNativeProcessResult;
	
	[Event(name=EVENT_PARSE_COMPLETED, type="flash.events.Event")]
	public class FileSystemParser extends EventDispatcher implements IWorkerSubscriber
	{
		public static const EVENT_PARSE_COMPLETED:String = "ParseCompleted";
		
		private static const PARSE_FILES_ON_PATH:String = "parseFilesOnPath";
		
		private var subscribeIdToWorker:String;
		private var worker:IDEWorker = IDEWorker.getInstance();
		private var queue:Vector.<Object> = new Vector.<Object>();
		private var readableExtensions:Array;
		private var filesTreeByDirectory:Dictionary = new Dictionary();
		private var allOutput:String = "";
		private var fileSeparator:String;
		private var newLineCharacter:String = ConstantsCoreVO.IS_WINDOWS ? "\r\n" : "\n";
		
		private var _projectPath:String;
		public function get projectPath():String
		{
			return _projectPath;
		}

		private var _filePath:String;
		public function get filePath():String
		{
			return _filePath;
		}
		
		private var _fileName:String;
		public function get fileName():String
		{
			return _fileName;
		}
		
		private var _resultsStringFormat:String = "";
		public function get resultsStringFormat():String
		{
			return _resultsStringFormat;
		}

		public function get resultsArrayFormat():Array
		{
			return _resultsStringFormat.split(newLineCharacter);
		}
		
		public function FileSystemParser() 
		{	
			fileSeparator = IDEModel.getInstance().fileCore.separator;
			subscribeIdToWorker = UIDUtil.createUID();
			
			worker.subscribeAsIndividualComponent(subscribeIdToWorker, this);
			worker.sendToWorker(WorkerEvent.SET_IS_WINDOWS, ConstantsCoreVO.IS_WINDOWS, subscribeIdToWorker);
		}
		
		public function parseFilesPaths(fromPath:String, withName:String, readableExtensions:Array=null):void
		{
			var tempDirectory:FileLocation = IDEModel.getInstance().fileCore.resolveTemporaryDirectoryPath("moonshine");
			if (!tempDirectory.fileBridge.exists)
			{
				tempDirectory.fileBridge.createDirectory();
			}

			withName ||= UIDUtil.createUID();

			this.readableExtensions = readableExtensions;
			this._projectPath = fromPath;
			this._fileName = withName;
			this._filePath = tempDirectory.fileBridge.resolvePath(this._fileName +".txt").fileBridge.nativePath;

			var tmpExtensions:String = "";
			if (readableExtensions)
			{
				if (ConstantsCoreVO.IS_WINDOWS)
				{
					for each (var ext:String in readableExtensions)
					{
						tmpExtensions += "*."+ ext +" ";
					}
				}
				else
				{
					tmpExtensions = " -regex '.*\\.("+ readableExtensions.join("|") +")'";
				}
			}

			// @example
			// macOS: find -E $'folderPath' -regex '.*\.(mxml|xml)' -type f
			// windows: dir /a-d /b /s *.mxml *.xml
			queue = new Vector.<Object>();
			addToQueue(new NativeProcessQueueVO(
				ConstantsCoreVO.IS_WINDOWS ?
					"dir /a-d /b /s "+ tmpExtensions +" > "+ UtilsCore.getEncodedForShell(_filePath) :
					"find -E $'"+ UtilsCore.getEncodedForShell(fromPath) +"'"+ tmpExtensions +" -type f > '"+ _filePath +"'",
				false,
				PARSE_FILES_ON_PATH)
			);
			worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {queue:queue, workingDirectory:fromPath}, subscribeIdToWorker);
		}
		
		public function unsubscribeFromWorker():void
		{
			worker.unSubscribeComponent(subscribeIdToWorker);
			worker = null;
			queue = null;
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
					shellTick(tmpValue);
					break;
				case WorkerEvent.RUN_LIST_OF_NATIVEPROCESS_ENDED:
					listOfProcessEnded();
					break;
				case WorkerEvent.CONSOLE_MESSAGE_NATIVEPROCESS_OUTPUT:
					//debug("%s", value.value);
					break;
			}
		}
		
		protected function addToQueue(value:Object):void
		{
			queue.push(value);
		}
		
		protected function listOfProcessEnded():void
		{
			unsubscribeFromWorker();
			
			// read the file content
			IDEModel.getInstance().fileCore.readAsyncWithListener(
				onReadCompletes, 
				onReadError, 
				new FileLocation(filePath)
			);
			
			/*
			* @local
			*/
			function onReadCompletes(output:String):void
			{
				if (output)
				{
					_resultsStringFormat += (ConstantsCoreVO.IS_WINDOWS ? "\r\n" : "\n") + output;
				}
				dispatchEvent(new Event(EVENT_PARSE_COMPLETED));
			}
			function onReadError(value:String):void
			{
				dispatchEvent(new Event(EVENT_PARSE_COMPLETED));
				GlobalEventDispatcher.getInstance().dispatchEvent(
					new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT, value, false, false, ConsoleOutputEvent.TYPE_ERROR)
				);
			}
		}
		
		protected function shellError(value:Object /** type of WorkerNativeProcessResult **/):void 
		{
			unsubscribeFromWorker();
			dispatchEvent(new Event(EVENT_PARSE_COMPLETED));
			GlobalEventDispatcher.getInstance().dispatchEvent(
				new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT, value.output, false, false, ConsoleOutputEvent.TYPE_ERROR)
			);
		}
		
		protected function shellExit(value:Object /** type of WorkerNativeProcessResult **/):void 
		{
			trace("Shell Exits");
		}
		
		protected function shellTick(value:Object /** type of NativeProcessQueueVO **/):void
		{
		}
		
		protected function shellData(value:Object /** type of WorkerNativeProcessResult **/):void 
		{
			if (value.output.match(/fatal: .*/))
			{
				shellError(value);
			}
			else
			{
				//trace(value.output);
				//_resultsStringFormat += value.output.replace(/^[ \n|\r\n]/gm, newLineCharacter); // remove all the blank lines
				//allOutput += StringUtil.trim(value.output);
				//parsedFiles = parsedFiles.concat(value.output.split("\r\n"));
			}
		}
	}
}