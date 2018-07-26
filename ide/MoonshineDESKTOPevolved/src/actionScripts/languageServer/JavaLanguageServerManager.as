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
package actionScripts.languageServer
{
    import actionScripts.events.GlobalEventDispatcher;
    import actionScripts.languageServer.LanguageClient;
    import actionScripts.locator.IDEModel;
    import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
    import actionScripts.valueObjects.Settings;

    import flash.desktop.NativeProcess;
    import flash.desktop.NativeProcessStartupInfo;
    import flash.filesystem.File;
    import actionScripts.valueObjects.ProjectVO;

	public class JavaLanguageServerManager implements ILanguageServerManager
	{
		private static const LANGUAGE_SERVER_JAR_PATH:String = "elements/org.eclipse.equinox.launcher_1.5.100.v20180611-1436.jar";
		private static const LANGUAGE_ID_JAVA:String = "java";

		private var _project:JavaProjectVO;
		private var _languageClient:LanguageClient;
		private var _model:IDEModel = IDEModel.getInstance();
		private var _dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var _shellInfo:NativeProcessStartupInfo;
		private var _nativeProcess:NativeProcess;
		private var _cmdFile:File;
		private var _javaPath:File;

		public function JavaLanguageServerManager(project:JavaProjectVO, javaPath:String)
		{
			_javaPath = new File(javaPath);

			var javaFileName:String = (Settings.os == "win") ? "java.exe" : "java";
			_cmdFile = _javaPath.resolvePath(javaFileName);
			if(!_cmdFile.exists)
			{
				_cmdFile = _javaPath.resolvePath("bin/" + javaFileName);
			}

			_project = project;
		}

		public function get project():ProjectVO
		{
			return _project;
		}
	}
}
