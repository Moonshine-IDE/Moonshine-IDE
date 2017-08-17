////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

package com.riaspace.nativeApplicationUpdater.utils
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;

	[Event(name="complete",type="flash.events.Event")]
	[Event(name="error",type="flash.events.ErrorEvent")]
	
	public class HdiutilHelper extends EventDispatcher
	{
		private var dmg:File;
		
		private var result:Function;
		
		private var error:Function;
		
		private var hdiutilProcess:NativeProcess;
		
		public var mountPoint:String;
		
		public function HdiutilHelper(dmg:File)
		{
			this.dmg = dmg;
			this.result = result;
			this.error = error;
		}
		
		public function attach():void
		{
			var info:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			info.executable = new File("/usr/bin/hdiutil");
			
			var args:Vector.<String> = new Vector.<String>();
			args.push("attach", "-plist", dmg.nativePath);
			info.arguments = args;
			
			hdiutilProcess = new NativeProcess();
			hdiutilProcess.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, hdiutilProcess_errorHandler);
			hdiutilProcess.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, hdiutilProcess_errorHandler);
			hdiutilProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, hdiutilProcess_outputHandler);
			hdiutilProcess.start(info);
		}

		private function hdiutilProcess_outputHandler(event:ProgressEvent):void
		{
			hdiutilProcess.removeEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, hdiutilProcess_errorHandler);
			hdiutilProcess.removeEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, hdiutilProcess_errorHandler);
			hdiutilProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, hdiutilProcess_outputHandler);
			hdiutilProcess.exit();
			
			// Storing current XML settings
			var xmlSettings:Object = XML.settings();
			// Setting required custom XML settings
			XML.setSettings(
				{
					ignoreWhitespace : true,
					ignoreProcessingInstructions : true,
					ignoreComments : true,
					prettyPrinting : false
				});
				
			var plist:XML = new XML(hdiutilProcess.standardOutput.readUTFBytes(event.bytesLoaded));
			var dicts:XMLList = plist.dict.array.dict;

			// INFO: for some reason E4X didn't work
			for each(var dict:XML in dicts)
			{
				for each(var element:XML in dict.elements())
				{
					if (element.name() == "key" && element.text() == "mount-point")
					{
						mountPoint = dict.child(element.childIndex() + 1);
						break;
					}
				}
			}

			// Reverting back original XML settings
			XML.setSettings(xmlSettings);
			
			if (mountPoint)
				dispatchEvent(new Event(Event.COMPLETE));
			else
				dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, "Couldn't find mount point!"));
		}

		private function hdiutilProcess_errorHandler(event:IOErrorEvent):void
		{
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, event.text, event.errorID));
		}
	}
}