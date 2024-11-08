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
package actionScripts.plugins.as3project
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.utils.IDataInput;
	
	import mx.controls.Alert;
	
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.PluginBase;
	import actionScripts.ui.editor.text.TextLineModel;
	import actionScripts.utils.HtmlFormatter;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.Settings;
	
	public class CreateCertificate extends PluginBase
	{
		public static const EVENT_ANTBUILD:String = "antbuildEvent";
		public static const ASCRIPTLINES: XML = <root><![CDATA[
							#!/bin/bash
							on run argv
							do shell script "/bin/blah > /dev/null 2>&1 &"
							set userHomePath to POSIX path of (path to home folder)
							do shell script "CreateCertificate.bat"
		
						end run]]></root>
		
		override public function get name():String			{ return "Ant Build Plugin"; }
		override public function get author():String		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String	{ return "Ant Build Plugin."; }
		
		public var certificateName:String;
		
		private var cmdFile:File;
		private var cmdLine:CommandLine = new CommandLine();
		private var shellInfo:NativeProcessStartupInfo;
		private var nativeProcess:NativeProcess;
		private var errors:String = "";
		private var exiting:Boolean = false;
		private var workingDirectory:File;
		
		public function CreateCertificate(workingDirectory:File) 
		{
			this.workingDirectory = workingDirectory;
			if (Settings.os.toLowerCase() == "win") cmdFile = new File("c:\\Windows\\System32\\cmd.exe");
			else if (Settings.os.toLowerCase() == "mac") cmdFile = new File("/bin/bash");
		}
		
		public function buildCertificate():void
		{
			if (!nativeProcess) 
			{
				if (!IDEModel.getInstance().defaultSDK) 
				{
					Alert.show("No Flex SDK found: Creating self-signed certificate ignored.", "Note!");
					return;
				}
				
				var processArgs:Vector.<String> = new Vector.<String>;
				shellInfo = new NativeProcessStartupInfo();
				
				if (Settings.os == "win")
				{
					processArgs.push("/c");
				}
				
				processArgs.push(IDEModel.getInstance().defaultSDK.resolvePath("bin/adt").fileBridge.nativePath);
				processArgs.push("-certificate");
				processArgs.push("-cn");
				processArgs.push(certificateName+"Certificate");
				processArgs.push("2048-RSA");
				processArgs.push("build"+ File.separator + certificateName +"Certificate.p12");
				processArgs.push(certificateName+"Certificate");
				shellInfo.arguments = processArgs;
				shellInfo.executable = cmdFile;
				shellInfo.workingDirectory = workingDirectory;
				initShell();
			}
		}
		
		private function initShell():void 
		{
			if (nativeProcess) {
				nativeProcess.exit();
				exiting = true;
			} else {
				startShell();
			}
		}
		
		private function startShell():void 
		{
			nativeProcess = new NativeProcess();
			nativeProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);
			nativeProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
			nativeProcess.addEventListener(NativeProcessExitEvent.EXIT, shellExit);
			nativeProcess.start(shellInfo);
		}
		
		private function shellData(e:ProgressEvent):void 
		{
			var output:IDataInput = nativeProcess.standardOutput;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			var match:Array;
			
			match = data.match(/nativeProcess: Target \d not found/);
			if (match)
			{
				error("Target not found. Try again.");
			}
			
			match = data.match(/nativeProcess: Assigned (\d) as the compile target id/);
			if (data)
		    {
				match = data.match(/(.*) \(\d+? bytes\)/);
				if (match) 
				{
					// Successful Build
					print("Done");
				}
			 }
			if (data == "(nativeProcess) ") 
			{
				if (errors != "") 
				{
					compilerError(errors);
					errors = "";
				}
			}
			
			if (data.charAt(data.length-1) == "\n") data = data.substr(0, data.length-1);
			print("%s", data);
		}
		
		private function shellError(e:ProgressEvent):void 
		{
			var output:IDataInput = nativeProcess.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			
			var syntaxMatch:Array;
			var generalMatch:Array;
			var initMatch:Array;
			print(data);
			syntaxMatch = data.match(/(.*?)\((\d*)\): col: (\d*) Error: (.*).*/);
			if (syntaxMatch) {
				var pathStr:String = syntaxMatch[1];
				var lineNum:int = syntaxMatch[2];
				var colNum:int = syntaxMatch[3];
				var errorStr:String = syntaxMatch[4];
				pathStr = pathStr.substr(pathStr.lastIndexOf("/")+1);
				errors += HtmlFormatter.sprintf("%s<weak>:</weak>%s \t %s\n",
												pathStr, lineNum, errorStr); 
			}
			
			generalMatch = data.match(/(.*?): Error: (.*).*/);
			if (!syntaxMatch && generalMatch)
			{ 
				pathStr = generalMatch[1];
				errorStr  = generalMatch[2];
				pathStr = pathStr.substr(pathStr.lastIndexOf("/")+1);
				
				errors += HtmlFormatter.sprintf("%s: %s", pathStr, errorStr);
			}
			
			debug("%s", data);
		}
		
		private function shellExit(e:NativeProcessExitEvent):void 
		{
			debug("FSCH exit code: %s", e.exitCode);
			if (exiting) {
				exiting = false;
				startShell();
			}
		}

		protected function compilerError(...msg):void 
		{
			var text:String = msg.join(" ");
			var textLines:Array = text.split("\n");
			var lines:Vector.<TextLineModel> = Vector.<TextLineModel>([]);
			for (var i:int = 0; i < textLines.length; i++)
			{
				if (textLines[i] == "") continue;
				text = "<error> ⚡  </error>" + textLines[i]; 
				var lineModel:TextLineModel = new TextLineModel(text);
				lines.push(lineModel);
			}
			outputMsg(lines);
		}
	}
}