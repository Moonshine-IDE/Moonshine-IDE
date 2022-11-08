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
package actionScripts.plugins.as3lsp
{
	import actionScripts.languageServer.ILanguageServerManager;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.valueObjects.ConstantsCoreVO;

	public class AS3LanguageServerPlugin extends PluginBase
	{
		override public function get name():String 			{return "AS3 Language Server Plugin";}
		override public function get author():String 		{return ConstantsCoreVO.MOONSHINE_IDE_LABEL + " Project Team";}
		override public function get description():String 	{return "AS3 project importing, exporting & scaffolding.";}
		
		public function AS3LanguageServerPlugin()
		{
			super();
		}
		
		override public function activate():void
		{
			model.languageServerCore.registerLanguageServerProvider(AS3ProjectVO, createLanguageServerManager);
		}
		
		override public function deactivate():void
		{
			model.languageServerCore.unregisterLanguageServerProvider(AS3ProjectVO);
		}

		private function createLanguageServerManager(project:AS3ProjectVO):ILanguageServerManager
		{
			return new ActionScriptLanguageServerManager(project);
		}
	}
}