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
package actionScripts.plugins.groovy
{
    import actionScripts.events.RefreshTreeEvent;
    import actionScripts.events.StatusBarEvent;
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.IPlugin;
    import actionScripts.plugin.PluginBase;
    import actionScripts.plugin.core.compiler.CompilerEventBase;
    import actionScripts.plugin.groovy.groovyproject.vo.GroovyProjectVO;
    import actionScripts.plugin.settings.ISettingsProvider;
    import actionScripts.plugin.settings.vo.ISetting;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import actionScripts.valueObjects.ProjectVO;

    import flash.desktop.NativeProcess;
    import flash.desktop.NativeProcessStartupInfo;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.NativeProcessExitEvent;
    import flash.events.ProgressEvent;
    import flash.filesystem.File;
    import flash.utils.IDataInput;
	
	public class GroovyCPlugin extends PluginBase implements IPlugin, ISettingsProvider
	{
		override public function get name():String			{ return "Groovy Build Plugin"; }
		override public function get author():String		{ return "Moonshine Project Team"; }
		override public function get description():String	{ return "Builds Groovy projects"; }

		private var groovycProcess:NativeProcess = null;
		private var jarProcess:NativeProcess = null;
		private var currentProject:GroovyProjectVO = null;
		
		public function GroovyCPlugin() 
		{
		}
		
		override public function activate():void 
		{
			if (activated) return;
			
			super.activate();
			
			dispatcher.addEventListener(CompilerEventBase.BUILD, buildHandler);
		}
		
		override public function deactivate():void 
		{
			super.deactivate();
		}
		
		public function getSettingsList():Vector.<ISetting>
		{
			return null;
		}

		private function stopCompile():void
		{
			if(!groovycProcess)
			{
				return;
			}
			if(groovycProcess.running)
			{
				groovycProcess.exit();
			}
			groovycProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, nativeProcess_stdoutDataHandler);
			groovycProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, nativeProcess_stderrDataHandler);
			groovycProcess.removeEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, nativeProcess_ioErrorHandler);
			groovycProcess.removeEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, nativeProcess_ioErrorHandler);
			groovycProcess.removeEventListener(NativeProcessExitEvent.EXIT, groovycProcess_exitHandler);
			groovycProcess = null;
		}

		private function stopCreateJar():void
		{
			if(!jarProcess)
			{
				return;
			}
			if(jarProcess.running)
			{
				jarProcess.exit();
			}
			jarProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, nativeProcess_stdoutDataHandler);
			jarProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, nativeProcess_stderrDataHandler);
			jarProcess.removeEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, nativeProcess_ioErrorHandler);
			jarProcess.removeEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, nativeProcess_ioErrorHandler);
			jarProcess.removeEventListener(NativeProcessExitEvent.EXIT, jarProcess_exitHandler);
			jarProcess = null;
		}

		private function stopBuild():void
		{
            if(!currentProject)
			{
				return;
			}
			stopCompile();
			stopCreateJar();

            dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
            dispatcher.removeEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, projectBuildTerminateHandler);
		}
		
		private function buildHandler(event:Event):void 
		{
			var activeProject:ProjectVO = model.activeProject;
			if(!(activeProject is GroovyProjectVO))
			{
				return;
			}

			stopBuild();

            clearOutput();

			currentProject = GroovyProjectVO(activeProject);
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED,
					currentProject.projectName, "Building "));
			dispatcher.addEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, projectBuildTerminateHandler);
			
			startCompile();
		}

		private function startCompile():void
		{
			print("Compiling " + currentProject.projectName);
			if (currentProject.targets.length == 0) 
			{
				error("No targets found for compilation.");
				stopBuild();
				return;
			}

			var processArgs:Vector.<String> = currentProject.buildOptions.getProcessArguments();
			processArgs.push(currentProject.targets[0].fileBridge.nativePath);
			
			var startupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			startupInfo.arguments = processArgs;
			startupInfo.executable = new File("C:\\Program Files (x86)\\Groovy\\Groovy-2.5.6\\bin\\groovyc.exe");
			startupInfo.workingDirectory = currentProject.folderLocation.fileBridge.getFile as File;
			
			groovycProcess = new NativeProcess();
			groovycProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, nativeProcess_stdoutDataHandler);
			groovycProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, nativeProcess_stderrDataHandler);
			groovycProcess.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, nativeProcess_ioErrorHandler);
			groovycProcess.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, nativeProcess_ioErrorHandler);
			groovycProcess.addEventListener(NativeProcessExitEvent.EXIT, groovycProcess_exitHandler);
			groovycProcess.start(startupInfo);
		}

		private function startCreateJar():void
		{
			print("Creating .jar archive");
			if (currentProject.targets.length == 0) 
			{
				error("No targets found for compilation.");
				stopBuild();
				return;
			}

			var javaLocation:File = model.javaPathForTypeAhead.fileBridge.getFile as File;
			if(!javaLocation)
			{
				error("Java not found.");
				stopBuild();
				return;
			}
			var jarExecutablePath:String = "bin" + File.separator + "jar";
			if(!ConstantsCoreVO.IS_MACOS)
			{
				jarExecutablePath += ".exe";
			}
			var jarExecutable:File = javaLocation.resolvePath(jarExecutablePath);

			var outputJar:File = currentProject.jarOutput.path.fileBridge.getFile as File;
			var outputDir:File = outputJar.parent;
			if(!outputDir.exists)
			{
				outputDir.createDirectory();
			}

			var entrypoint:String = null;
			var entrypointFile:File = currentProject.targets[0].fileBridge.getFile as File;
			for each(var classpath:FileLocation in currentProject.classpaths)
			{
				var classpathFile:File = classpath.fileBridge.getFile as File;
				var relativePath:String = classpathFile.getRelativePath(entrypointFile);
				if(entrypointFile.nativePath != relativePath)
				{
					entrypoint = relativePath.replace(/\.groovy$/, "");
				}
			}
			trace("entrypoint:", entrypoint);
			if(entrypoint == null)
			{
				error("Could not convert entrypoint file to class name: " + entrypointFile.nativePath);
				stopBuild();
			}
			
			var processArgs:Vector.<String> = new <String>[];
			processArgs.push("cfe");
			processArgs.push(outputJar.nativePath);
			processArgs.push(entrypoint);
			processArgs.push("-C");
			processArgs.push(currentProject.buildOptions.destdir);
			processArgs.push(".");
			
			var startupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			startupInfo.arguments = processArgs;
			startupInfo.executable = jarExecutable;
			startupInfo.workingDirectory = currentProject.folderLocation.fileBridge.getFile as File;
			
			jarProcess = new NativeProcess();
			jarProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, nativeProcess_stdoutDataHandler);
			jarProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, nativeProcess_stderrDataHandler);
			jarProcess.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, nativeProcess_ioErrorHandler);
			jarProcess.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, nativeProcess_ioErrorHandler);
			jarProcess.addEventListener(NativeProcessExitEvent.EXIT, jarProcess_exitHandler);
			jarProcess.start(startupInfo);
		}

		private function projectBuildTerminateHandler(event:StatusBarEvent):void
		{
			if (groovycProcess && groovycProcess.running)
			{
				groovycProcess.exit(true);
			}
			if (jarProcess && jarProcess.running)
			{
				jarProcess.exit(true);
			}
		}
		
		private function nativeProcess_stdoutDataHandler(e:ProgressEvent):void 
		{
			if(!groovycProcess)
			{
				return;
			}
			var output:IDataInput = groovycProcess.standardOutput;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			print(data);
		}
		
		private function nativeProcess_stderrDataHandler(e:ProgressEvent):void 
		{
			if(!groovycProcess)
			{
				return;
			}
			var output:IDataInput = groovycProcess.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			print(data);
		}
		
		private function nativeProcess_ioErrorHandler(e:IOErrorEvent):void 
		{
		}

		private function groovycProcess_exitHandler(event:NativeProcessExitEvent):void
		{
			stopCompile();
			var exitCode:Number = event.exitCode;
			if(exitCode == 0)
			{
				dispatcher.dispatchEvent(new RefreshTreeEvent(currentProject.folderLocation));
				dispatcher.dispatchEvent(new RefreshTreeEvent(new FileLocation(currentProject.buildOptions.destdir)));
            	startCreateJar();
				return;
			}
			else if(isNaN(exitCode))
			{
				error("Build terminated");
			}
			else
			{
				error("The process exited with code " + exitCode);
			}
			stopBuild();
		}

		private function jarProcess_exitHandler(event:NativeProcessExitEvent):void
		{
			stopCreateJar();
			var exitCode:Number = event.exitCode;
			if(exitCode == 0)
			{
				dispatcher.dispatchEvent(new RefreshTreeEvent(currentProject.jarOutput.path.fileBridge.parent));
            	success("Build success");
			}
			else if(isNaN(exitCode))
			{
				error("Build terminated");
			}
			else
			{
				error("The process exited with code " + exitCode);
			}
			stopBuild();
		}
	}
}