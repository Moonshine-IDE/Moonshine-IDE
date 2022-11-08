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
package actionScripts.plugins.haxelsp
{
	import actionScripts.languageServer.ILanguageServerManager;
	import actionScripts.plugin.PluginBase;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.plugin.haxe.hxproject.vo.HaxeProjectVO;

	public class HaxeLanguageServerPlugin extends PluginBase
	{
		override public function get name():String 			{return "Haxe Language Server Plugin";}
		override public function get author():String 		{return ConstantsCoreVO.MOONSHINE_IDE_LABEL + " Project Team";}
		override public function get description():String 	{return "Haxe code intelligence provided by a language server";}
		
		public function HaxeLanguageServerPlugin()
		{
			super();
		}
		
		override public function activate():void
		{
			model.languageServerCore.registerLanguageServerProvider(HaxeProjectVO, createLanguageServerManager);
		}
		
		override public function deactivate():void
		{
			model.languageServerCore.unregisterLanguageServerProvider(HaxeProjectVO);
		}

		private function createLanguageServerManager(project:HaxeProjectVO):ILanguageServerManager
		{
			return new HaxeLanguageServerManager(project);
		}
	}
}