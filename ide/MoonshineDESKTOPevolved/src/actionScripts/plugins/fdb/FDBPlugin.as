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
package actionScripts.plugins.fdb
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.collections.XMLListCollection;
	import mx.controls.Alert;
	import mx.events.AdvancedDataGridEvent;
	import mx.events.CloseEvent;
	import mx.events.ListEvent;
	import mx.utils.ObjectUtil;
	import mx.utils.StringUtil;
	
	import actionScripts.events.EditorPluginEvent;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.OpenFileEvent;
	import actionScripts.events.StatusBarEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.IPlugin;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.actionscript.mxmlc.MXMLCPluginEvent;
	import actionScripts.plugin.core.compiler.CompilerEventBase;
	import actionScripts.plugins.fdb.event.FDBEvent;
	import actionScripts.plugins.fdb.view.FDBView;
	import actionScripts.plugins.swflauncher.event.SWFLaunchEvent;
	import actionScripts.ui.IContentWindow;
	import actionScripts.ui.editor.BasicTextEditor;
	import actionScripts.ui.editor.text.events.DebugLineEvent;
	import actionScripts.ui.menu.MenuPlugin;
	import actionScripts.ui.tabview.CloseTabEvent;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.Settings;
	
	public class FDBPlugin extends PluginBase implements IPlugin
	{
		override public function get name():String 			{ return "Flex Debugger Plugin"; }
		override public function get author():String 		{ return "Miha Lunar & Moonshine Project Team"; }
		override public function get description():String 	{ return "Debugs AS3 projects with FDB."; }
		
		private static const CONSOLE_MODE:String 	= "fdb";
		
		private var fdbPath:String      			= "bin/fdb";
		private var outputBuffer:String 			= "";
		private var cmdFile:File;
		private var cookie:Object;
		private var breakPointArr:ArrayCollection;
		private var currentSDK:File;
		private var debuggerInfo:NativeProcessStartupInfo;
		private var fdb:NativeProcess;
		
		private var manualMode:Boolean    			 = false;
		private var localsNext:Boolean    			 = false;
		private var itemQueue:Vector.<XML> 			 = new Vector.<XML>();
		
		private var debugView:FDBView;
		private var objectTree:XMLListCollection;
		private var nameOfFile:String;
		private var isStepOver:Boolean				 = false;
		private var commandStr:String				 = "";
		private var isExpanded:Boolean				 = false;
		private var editor:BasicTextEditor;
		private var fschstr:String;
		private var SDKstr:String;
		private var isSession:Boolean			 = false;
		
		public function FDBPlugin()
		{
			if (Settings.os == "win")
			{
				fdbPath += ".bat";
				cmdFile = new File("c:\\Windows\\System32\\cmd.exe");
			}
			else
			{
				//For MacOS
				cmdFile = new File("/bin/bash");
			}
			
		}
		
		override public function activate():void
		{
			super.activate();
			
			debugView = new FDBView();
			debugView.addEventListener(AdvancedDataGridEvent.ITEM_OPEN, objectOpened);
			debugView.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, refreshItem);
			
			
			dispatcher.addEventListener(CompilerEventBase.POSTBUILD, postbuild);
			dispatcher.addEventListener(CompilerEventBase.PREBUILD, handleCompile);
			dispatcher.addEventListener(EditorPluginEvent.EVENT_EDITOR_OPEN, handleEditorOpen);
			dispatcher.addEventListener(MenuPlugin.MENU_SAVE_EVENT, handleEditorSave);
			dispatcher.addEventListener(MenuPlugin.MENU_SAVE_AS_EVENT, handleEditorSave);
			dispatcher.addEventListener(CloseTabEvent.EVENT_CLOSE_TAB, handleEditorSave);
			dispatcher.addEventListener(FDBEvent.SHOW_DEBUG_VIEW, handleShowDebugView);
			dispatcher.addEventListener(CompilerEventBase.CONTINUE_EXECUTION,continueExecutionHandler);
			dispatcher.addEventListener(CompilerEventBase.TERMINATE_EXECUTION,terminateExecutionHandler);
	
			
			var	fdbObj:Object = new Object();
			fdbObj.callback = fdbCommand;
			fdbObj.commandDesc = "Debug a Flex Application.  CURRENTLY UNAVAILABLE.";
			registerCommand(CONSOLE_MODE, fdbObj);
			
			cookie = {};
			breakPointArr = new ArrayCollection();
		}
		
		//"F6" will call below function and step over the line
		private function handleCodeStepOver(e:Event):void
		{
			send("next");
			debug(">>> %s <<<", "fdb next");
		}
		
		//Continue Execution
		private function continueExecutionHandler(e:Event):void
		{
			if(fdb)
			{
				send("continue");
				var ed:BasicTextEditor = model.activeEditor as BasicTextEditor;
				if(ed)
				{
					ed.getEditorComponent().model.hasTraceSelection = false;
					ed.getEditorComponent().updateSelection();
					ed.getEditorComponent().updateTraceSelection();
					ed.getEditorComponent().removeTraceSelection();
				}
			}
		}
		
		//Terminate execution of running application
		private function terminateExecutionHandler(e:Event):void
		{
			if(fdb)
				stopDebugger();
		}
		
		private function exitFDBHandler(e:CompilerEventBase):void{
			if(fdb) 
				send("quit");
		}
		private function handleShowDebugView(e:Event):void
		{
			IDEModel.getInstance().mainView.addPanel(debugView);
		}
		
		private function objectOpened(e:AdvancedDataGridEvent):void
		{
			var item : XML = XML(e.item);
			if (item.children().length() == 0)
			{
				updateItem(item);
			}
			isExpanded = true;
		}
		
		private function refreshItem(e:ListEvent):void
		{
			var item : XML = XML(e.itemRenderer.data);
			updateItem(item);
		}
		
		
		private function updateItem(item:XML):void
		{
			item.@label = "updating...";
			itemQueue.push(item);
			send("print " + item.@path + (item.@isBranch == "true" ? "." : ""));
		}
		
		override public function deactivate():void
		{
			super.deactivate();
			dispatcher.removeEventListener(CompilerEventBase.POSTBUILD, postbuild);
			
			unregisterCommand(CONSOLE_MODE);
			
			if (fdb)
			{
				startShell(false);
			}
		}
		
		private function handleEditorOpen(event:EditorPluginEvent):void
		{
			if (event.newFile || !event.file)
				return;
			
			var path : String = event.file.fileBridge.nativePath;
			var breakpoints : Array = cookie[path] as Array;
			if (breakpoints)
			{
				event.editor.breakpoints = breakpoints;
			}
		}
		
		private function handleEditorSave(event:Event):void
		{
			var editor : BasicTextEditor;
			if (event is CloseTabEvent)
			{
				editor = CloseTabEvent(event).tab as BasicTextEditor;
			}
			else
			{
				editor = IDEModel.getInstance().activeEditor as BasicTextEditor;
			}
			
			saveForEditor(editor);
		}
		
		private function handleCompile(event:MXMLCPluginEvent):void
		{
			
			currentSDK = event.sdk.fileBridge.getFile as File;
			// Make sure we have stuff from all editors. (even unsaved?)
			dispatcher.addEventListener(DebugLineEvent.SET_DEBUG_LINE,debugLineHandler);
		}
		
		//Adding/removing breakpoints at runtime
		private function debugLineHandler(event:DebugLineEvent):void
		{
			editor = IDEModel.getInstance().activeEditor as BasicTextEditor;
			if (!editor)
				return;
			if (!editor.currentFile)
				return;
			
			var path : String = editor.currentFile.fileBridge.nativePath;
			if (path == "")
				return;
			var bp:Array = cookie[path] as Array;
			if(!bp)
				bp = new Array();
			if(event.breakPoint)
			{
				var f : File = new File(path);
				bp.push(event.breakPointLine);
				cookie[path] = bp;
				if(fdb)
				{
					commandStr = "break " + f.name+":"+(event.breakPointLine + 1);
					send("break " + f.name+":"+(event.breakPointLine + 1));
				}
			}
			else
			{
				if(fdb)
				{
					var index:int
					for (var filePath : String in cookie)
					{
						f  = new File(filePath);
						for each(var bpObj:Object in breakPointArr)
						if(f.name == bpObj.bpFile && int(bpObj.bpLine) == event.breakPointLine)
						{
							if(f.name == bpObj.bpFile && int(bpObj.bpLine) == event.breakPointLine)
							{
								commandStr = "delete "+bpObj.bpNum;
								send("delete "+bpObj.bpNum);
								breakPointArr.removeItem(bpObj);	
								index = bp.indexOf( event.breakPointLine );
								bp.splice( index, 1 );
								cookie[path] = bp;
								break;
							}
						}
					}
				}
			}
		}
		
		private function saveForEditor(editor:BasicTextEditor):void
		{
			if (!editor)
				return;
			if (!editor.currentFile)
				return;
			
			var path : String = editor.currentFile.fileBridge.nativePath;
			if (path == "")
				return;
			
			cookie[path] = editor.getEditorComponent().breakpoints;
		}
		
		private function fdbCommand(args:Array):void
		{
			if (args.length == 0)
			{
				enterConsoleMode(CONSOLE_MODE);
				manualMode = true;
			}
			else if (args[0] == "exit")
			{
				exitConsoleMode();
				manualMode = false;
				if (fdb)
					send(args.join(" "));
			}
			else
			{
				print("FDB " + args.join(" "));
				if (!fdb)
				{
					// start debugg process
					GlobalEventDispatcher.getInstance().dispatchEvent(new CompilerEventBase(CompilerEventBase.BUILD_AND_DEBUG,false,false));
					//send(args.join(" "));
					//print("FDB not running, please build the project you want to debug at least once.");
				}
				else
				{
					send(args.join(" "));
				}
			}
		}
		
		// init debugger
		private function initDebugger():void
		{
			if (!currentSDK) 
			{
				error("No Flex SDK set, check settings.");
				return;
			}
			objectTree = debugView.objectTree;
			var fdbFile:File = currentSDK.resolvePath(fdbPath);
			debuggerInfo = new NativeProcessStartupInfo();
			var processArgs:Vector.<String> = new Vector.<String>;
			
			fschstr = fdbFile.nativePath;
			fschstr = UtilsCore.convertString(fschstr);
			
			SDKstr = currentSDK.nativePath;
			SDKstr = UtilsCore.convertString(SDKstr);
			
			if(Settings.os == "win")
			{
				processArgs.push("/c");
				processArgs.push("set FLEX_HOME="+SDKstr+"&& "+fschstr);
			}
			else
			{
				processArgs.push("-c");
				processArgs.push("export FLEX_HOME="+SDKstr+"&& "+fschstr);
			}
			
			debuggerInfo.arguments = processArgs;
			debuggerInfo.executable = cmdFile;
			
			if (model.activeProject)
			{
				debuggerInfo.workingDirectory = model.activeProject.folderLocation.fileBridge.getFile as File;
			}
			print("3 in FDBPlugin debugafterBuild");
			startShell(true);
		}
		
		private function startShell(start:Boolean):void 
		{
			if (start)
			{
				fdb = new NativeProcess();
				fdb.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, debuggerData);
				fdb.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, debuggerError);
				fdb.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR,debuggerError);
				fdb.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR,debuggerError);
				fdb.addEventListener(NativeProcessExitEvent.EXIT, debuggerExit);
				fdb.start(debuggerInfo);
				
				dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_DEBUG_STARTED, model.activeProject.projectName, "Debugging "));
				dispatcher.addEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onTerminateBuildRequest);
			}
			else
			{
				if (!fdb) return;
				if (fdb.running) fdb.exit();
				fdb.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, debuggerData);
				fdb.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, debuggerError);
				fdb.removeEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR,debuggerError);
				fdb.removeEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR,debuggerError);
				fdb.removeEventListener(NativeProcessExitEvent.EXIT, debuggerExit);
				fdb = null;
				
				dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_DEBUG_ENDED));
				dispatcher.removeEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onTerminateBuildRequest);
			}
		}
		
		private function onTerminateBuildRequest(event:StatusBarEvent):void
		{
			if (fdb && fdb.running)
			{
				stopDebugHandler(null);
			}
		}
		
		private function getMainTargetFolder():File
		{
			var project : AS3ProjectVO = AS3ProjectVO(IDEModel.getInstance().activeProject);
			return project.targets.length == 0 ? null : (FileLocation(project.targets[0]).fileBridge.getFile as File).parent;
		}
		
		/**
		 * Returns the file path relative to the project's main target path
		 */
		private function getRelativeTargetPath(f:File):String
		{
			return getMainTargetFolder().getRelativePath(f, true);
		}
		
		/**
		 * Resolves the path based on the project's main target path
		 */
		private function resolveTargetPath(path:String):File
		{
			var f:File = getMainTargetFolder().resolvePath(path);
			return f;
		}
		
		private function getFileTargetPath(path:String):FileLocation
		{
			for (var path : String in cookie)
			{
				var f:FileLocation = new FileLocation(path);
				if(f.fileBridge.name == nameOfFile)
					break;
			}
			return f;
		}
		
		private function sessionStart():void
		{
			var editors : Array = IDEModel.getInstance().editors.source;
			for (var i : int = 0; i < editors.length; i++)
			{
				saveForEditor(editors[i] as BasicTextEditor);
			}
			
			send("delete");
			send("y");
			send("run");
			
			for (var path : String in cookie)
			{
				var f : File = new File(path);
				send("cf " + getRelativeTargetPath(f));
				var breakpoints : Array = cookie[path];
				for (i = 0; i < breakpoints.length; i++)
				{
					send("break " + f.name+":"+(breakpoints[i] + 1));
				}
			}
			if (!manualMode)
				send("continue");
			
			// Add debugview if not visible
			if (!debugView.stage) model.mainView.addPanel(debugView);
			
			// Make session flag true
			isSession = true;
		}
		
		private function sessionStop():void
		{
			//if (debugView.stage) debugView.parent.removeChild(debugView);
			debugView.objectTree = new XMLListCollection();
		}
		
		
		private function debuggerData(e:ProgressEvent):void
		{
			var output:IDataInput = fdb.standardOutput;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			//Alert.show(data);
			var match:Array;
			var project:ProjectVO = IDEModel.getInstance().activeProject;
			var isMatchFound:Boolean;
			
			//A new filter added here which will detect command for FDB exit
			match = data.match(/.*\(fdb\) The program is running.  Exit anyway.*/);
			if (match)
			{
				send("y");
				isMatchFound = true;
			}
			else
			{
				match = data.match(/Waiting for Player to connect/)
				if(match)
				{				
					GlobalEventDispatcher.getInstance().dispatchEvent(new CompilerEventBase(CompilerEventBase.RUN_AFTER_DEBUG));
					isMatchFound = true;
				}
				match = data.match(/.*Player connected; session starting\..*/);
				if (match)
				{
					sessionStart();
					isMatchFound = true;
				}
				
				match = data.match(/.*Player session terminated.*/);
				if (match)
				{
					//send("quit");
					sessionStop();
					isMatchFound = true;
				}
				
				match = data.match(/\[trace\] (.*)\n/s);
				if (match)
				{
					print(match[1]);
					outputBuffer += data;
					isMatchFound = true;
				}
				
				match= data.match(/Do you want to attempt to halt execution.*?/);
				if (match)
				{
					send("y");
					isMatchFound = true;
				}
				
				match = data.match(/Attempting to halt./);
				if(match)
				{
					if(commandStr!="")
					{
						send(commandStr);
						send("continue");
						commandStr="";
					}
					isMatchFound = true;
				}
				else
				{
					outputBuffer += data;
				}
			}
			match = outputBuffer.match(/(.*)\n\(fdb\) /s);
			if (match)
			{
				var buffer:String = match[1];
				if (manualMode)
				{
					print("fdb> " + buffer);
				}
				else if (itemQueue.length > 0)
				{
					
					var item:XML = itemQueue.shift();
					
					var branch:Boolean = item.@isBranch == "true";
					// Remove all items first
					if (branch)
						item.setChildren(new XMLList());
					
					var objects:Array = buffer.replace(/\r\n/g, "\n").split("\n");
					var skipFirst:Boolean = !localsNext && branch;
					for each (var objLine:String in objects)
					{
						if (skipFirst)
						{
							skipFirst = false;
							continue;
						}
						match = objLine.match(" ?(.*?) = (.*)");
						if (!match)
							continue;
						
						var objName:String = match[1];
						var objValue:String = match[2];
						if (branch)
						{
							var complex:Boolean = Boolean(objValue.match(/^\[Object .*?\]$/));
							var newItem:XML;
							if (complex)
							{
								var objMatch:Array = objValue.match(/Object (\d*), class='(.*)']/);
								if(objMatch)
									newItem = <item label={objName} path={item.@path + (item.@path == "" ? "" : ".") + objName} name={objName} value={objMatch[2]+" (@"+objMatch[1]+")"}/>;
								newItem.@isBranch = "true";
								
							}
							else
								newItem = <item label={objName} path={item.@path + (item.@path == "" ? "" : ".") + objName} name={objName} value={objValue}/>;
							item.appendChild(newItem);
							
						}
						else
						{
							item.@value = objValue;
						}
						
					}
					item.@label = item.@name;
					localsNext = false;
					isMatchFound = true;
				}
				
				match = buffer.match("/There is no executable code on the specified line./");
				if(match){
					
				}
				
				match = buffer.match(/^\[SWF\].*?Additional ActionScript code has been loaded from a SWF or a frame/) || buffer.match(/.*Additional ActionScript code has been loaded from a SWF or a frame/);
				if (match) {						
					send("continue");
					isMatchFound = true;
				}
				
				match = buffer.match(/Resolved breakpoint (\d*?) to (.*?):(\d*).*+/g)
				if(match.length>0)
				{
					for each(var m:String in match)
					{
						var subStrMatch:Array = m.match(/Resolved breakpoint (\d*?) to (.*?):(\d*).*?/)
						if(subStrMatch)
						{ 
							var bpFile:String;
							var bpLine:int;
							var bpNum:int;
							if(subStrMatch[0].indexOf("()")!=-1)
							{
								var fileNamearr:Array = String(subStrMatch[2]).split(" ");
								bpFile = fileNamearr[fileNamearr.length-1];	
								bpLine = int(subStrMatch[3]) - 1;
								bpNum = int(subStrMatch[1]);
								AddBreakpoint(bpFile,bpLine,bpNum);
							}
							else
							{
								bpFile = subStrMatch[2];
								bpLine = int(subStrMatch[3]) - 1;
								bpNum = int(subStrMatch[1]);
								AddBreakpoint(bpFile,bpLine,bpNum);	
							}
							
						}
					}
					isMatchFound = true;
				}
				
				match = buffer.match(/Breakpoint (\d*?): file (.*?), line (\d*).*?/)
				if(match){
					var bpFile1:String = match[2];
					var bpLine1:int = int(match[3]) - 1;
					var bpNum1:int = int(match[1]);
					AddBreakpoint(bpFile1,bpLine1,bpNum1);
					isMatchFound = true;
				}
				
				match = buffer.match(/Breakpoint (\d*?), (.*?) at (.*?):(\d*).*?/) || buffer.match(/Breakpoint (\d*?), (.*?):(\d*).*?/);
				if (match)
				{
					var bpFunc:String="";
					var bpNum2:int = int(match[1]);
					var bpFile2:String="";
					var bpLine2:int=0;
					if(match[0].indexOf("()")!=-1)
					{
						bpFunc = match[2];
						bpFile2 = nameOfFile = match[3];
						bpLine2 = int(match[4]) -1;
						AddBreakpoint(bpFile2,bpLine2,bpNum2);
						print("Breakpoint in " + bpFunc + " at line " + (bpLine2+1) + " of " + bpFile2);
						
					}else{
						
						bpFile2 =nameOfFile= match[2];
						bpLine2 = int(match[3]) -1;
						AddBreakpoint(bpFile2,bpLine2,bpNum2);
						print("Breakpoint in at line " + (bpLine2+1) + " of " + bpFile2);
						
					}
					// Open file & scroll & select the given line
					dispatcher.dispatchEvent(new OpenFileEvent(OpenFileEvent.TRACE_LINE, getFileTargetPath(nameOfFile), bpLine2));
					// Chances are we're not in focus here, so let's focus Moonshine
					// This slows everything down like /crazy/. Why?
					// NativeApplication.nativeApplication.activate(NativeApplication.nativeApplication.openedWindows[0]);
					if (!manualMode)
					{
						isStepOver = true;
						dispatcher.addEventListener(CompilerEventBase.DEBUG_STEPOVER,handleCodeStepOver );
						objectTree.removeAll();
						var itemThis : XML = <item label="this" path="this" name="this" value="this" isBranch="true" />;
						var itemLocals : XML = <item label="locals" path="" name="locals" value="locals" isBranch="true" />;
						objectTree.addItem(itemThis);
						objectTree.addItem(itemLocals);
						if(isExpanded)
						debugView.expandItem(itemThis);
						itemQueue.push(itemThis);
						send("print this.");
						localsNext = true;
					}
					isMatchFound = true;
				}
			
				match = buffer.match(/Execution halted,(.*?):(\d*)*/);
				if(match)
				{
					var lineNum:Array = new Array;
					var nextLine:int =0;
					
					if(match[0].indexOf("()")!=-1){
						lineNum = match[0].toString().split(":");
						nextLine = lineNum[1];	
						var tempArr:Array = match[1].toString().split(" ");
						nameOfFile = tempArr[tempArr.length-1];
					}else{
						lineNum = match[0].toString().split(":");
						nextLine = lineNum[1];
						
						nameOfFile = StringUtil.trim(match[1]);
					}
					
					send("continue");
					isMatchFound = true;
				}
				
				match = buffer.match(/Execution halted .* at .*/)
				if(match)
				{
					send("continue");
					//Remove traceline selection from the view
					for each (var contentWindow:IContentWindow in model.editors)
					{
						var ed:BasicTextEditor = contentWindow as BasicTextEditor;
						if(ed)
						{
							ed.getEditorComponent().model.hasTraceSelection = false;
							ed.getEditorComponent().updateSelection();
							ed.getEditorComponent().updateTraceSelection();
							ed.getEditorComponent().removeTraceSelection();
							var path : String = ed.currentFile.fileBridge.nativePath;
							cookie[path] = ed.getEditorComponent().breakpoints;
						}
					}
					//unregister "F6" command
					dispatcher.removeEventListener(CompilerEventBase.DEBUG_STEPOVER,handleCodeStepOver );
					isMatchFound = true;
				}
				
				match = buffer.match(/[\(fdb)\]*^\s[0-9]+[\s*]+\w*/);
				if(match && isStepOver)
				{
					match = buffer.match(/^\s[0-9]+[\s*]/);
					if(match)
					{
						var nextLine3:int = match[0];
						dispatcher.dispatchEvent(new OpenFileEvent(OpenFileEvent.TRACE_LINE, getFileTargetPath(nameOfFile), nextLine3-1));
						dispatcher.addEventListener(CompilerEventBase.DEBUG_STEPOVER,handleCodeStepOver );
					}
					isMatchFound = true;
				}
				
				outputBuffer = "";
			}
			// This line is for dev. purpose to display fdb data in console
			if (!isMatchFound) debug(">>> %s <<<", data);
		}
		
		//Adding breakpoint at runtime
		private function AddBreakpoint(bpFile:String,bpLine:int,bpNum:int):void
		{
			var flag:Boolean = false;
			var bpObj:Object = {bpNum:bpNum,bpFile:bpFile,bpLine:bpLine};
			
			var index:int = breakPointArr.getItemIndex(bpObj);
			for each(var item:Object in breakPointArr)
			{
				if(ObjectUtil.compare(item,bpObj,0)==0)
				{
					flag = true;
				}
			}
			if(!flag)
				breakPointArr.addItem(bpObj);
		}
		
		private function debuggerError(e:ProgressEvent):void
		{
			var output:IDataInput = fdb.standardOutput;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			
			if (data.charAt(data.length - 1) == "\n")
				data = data.substr(0, data.length - 1);
			if (manualMode)
			{
				print("fdb> " + data);
			}
			
			debug("Error: %s", data); 
			fdb = null;
		}
		
		private function debuggerExit(e:NativeProcessExitEvent):void
		{
			debug("FDB exit code %s", e.exitCode);
			GlobalEventDispatcher.getInstance().removeEventListener(CompilerEventBase.STOP_DEBUG,stopDebugHandler);
			fdb = null;
		}
		
		private function postbuild(e:Event):void
		{
			// In case we have no SDK set we fail silently (MXMLCPlugin will be all over it).
			if (!currentSDK)
			{
				return;
			}
			if (!fdb)
			{
				print("2 in MXMLCPlugin debugafterBuild");
				initDebugger();
				send("run");
				GlobalEventDispatcher.getInstance().addEventListener(CompilerEventBase.STOP_DEBUG,stopDebugHandler);
				GlobalEventDispatcher.getInstance().addEventListener(CompilerEventBase.EXIT_FDB,exitFDBHandler);
			}
			else
			{
				// Alert for terminate current debug session
				Alert.show("You are already debugging an application. Do you wish to terminate the existing debugging session, and start a new session?", "", Alert.YES | Alert.CANCEL, null, alertListener, null, Alert.CANCEL);
				
				function alertListener(eventObj:CloseEvent):void {
					// Check to see if the OK button was pressed.
					if (eventObj.detail==Alert.YES) {
						stopDebugger();
						setTimeout(postbuild,1000,e)
					}
					else
					{
						return;
					}
				}
				
			}
		}
		
		private function stopDebugHandler(e:CompilerEventBase):void{
			if(fdb)
			{
				stopDebugger();
			}
			GlobalEventDispatcher.getInstance().removeEventListener(CompilerEventBase.STOP_DEBUG,stopDebugHandler);
		}
		
		// remoce trace line from editor and unlaunch swf
		private function stopDebugger():void{
			
			for each (var contentWindow:IContentWindow in model.editors)
			{
				var ed:BasicTextEditor = contentWindow as BasicTextEditor;
				if(ed)
				{
					ed.getEditorComponent().model.hasTraceSelection = false;
					ed.getEditorComponent().updateSelection();
					ed.getEditorComponent().updateTraceSelection();
					ed.getEditorComponent().removeTraceSelection();
				}
			}
			//unregister "F6" command
			dispatcher.removeEventListener(CompilerEventBase.DEBUG_STEPOVER,handleCodeStepOver );
			if(!isSession){
				fdb.closeInput();
			}
			sessionStop();
			fdb.exit(true);
			startShell(false);
			GlobalEventDispatcher.getInstance().dispatchEvent(new SWFLaunchEvent(SWFLaunchEvent.EVENT_UNLAUNCH_SWF, null));
		}
		
		private function send(msg:String):void
		{
			debug("Send to fdb: %s", msg);
			var input:IDataOutput = fdb.standardInput;
			input.writeUTFBytes(msg + "\n");
		}
	}
}
