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
package actionScripts.plugin.preInitialization
{
	import actionScripts.events.LanguageServerUnzipperEvent;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.PluginManager;
	import actionScripts.valueObjects.ConstantsCoreVO;
	
	public class PreInitializationTasksPlugin extends PluginBase
	{
		override public function get name():String			{ return "Pre-initialization Tasks Plugin"; }
		override public function get author():String		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String	{ return "Running any pre-initialization tasks before registering normal plugins"; }
		
		public var pluginManager:PluginManager;
		
		public function PreInitializationTasksPlugin()
		{
		}
		
		public function initializePlugin():void
		{
			startLanguageServerUnzip();
		}
		
		private function startLanguageServerUnzip():void
		{
			dispatcher.addEventListener(LanguageServerUnzipperEvent.EVENT_LANGUAGE_SERVER_UNZIP_COMPLETES, onLanguageServerUnzipCompletes, false, 0, true);
			model.flexCore.unzipLanguageServerFiles();
		}
		
		private function onLanguageServerUnzipCompletes(event:LanguageServerUnzipperEvent):void
		{
			dispatcher.removeEventListener(LanguageServerUnzipperEvent.EVENT_LANGUAGE_SERVER_UNZIP_COMPLETES, onLanguageServerUnzipCompletes);
			
			pluginManager.registerPostInitializationPlugins();
			this.deactivate();
		}
	}
}