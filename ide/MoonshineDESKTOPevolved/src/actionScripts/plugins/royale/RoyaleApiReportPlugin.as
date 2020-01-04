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
package actionScripts.plugins.royale
{
	import actionScripts.locator.IDEWorker;
	import actionScripts.plugin.IPlugin;
	import actionScripts.plugin.PluginBase;
	import actionScripts.valueObjects.ConstantsCoreVO;

	import mx.utils.UIDUtil;

	public class RoyaleApiReportPlugin extends PluginBase implements IPlugin
	{
		override public function get name():String			{ return "Apache Royale Api Report Plugin."; }
		override public function get author():String		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String	{ return "Apache Royale Api Report Plugin."; }

		private var worker:IDEWorker = IDEWorker.getInstance();
		private var queue:Vector.<Object> = new Vector.<Object>();
		private var subscribeIdToWorker:String;

		public function RoyaleApiReportPlugin():void
		{
			super();
		}

		override public function activate():void
		{
			super.activate();

			subscribeIdToWorker = this.name + UIDUtil.createUID();
		}

		override public function deactivate():void
		{
			super.deactivate();
		}
	}
}