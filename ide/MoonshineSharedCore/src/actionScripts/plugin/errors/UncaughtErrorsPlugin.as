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
package actionScripts.plugin.errors
{
	import flash.events.ErrorEvent;
	import flash.events.UncaughtErrorEvent;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	
	import actionScripts.plugin.IMenuPlugin;
	import actionScripts.plugin.PluginBase;
	import actionScripts.ui.menu.vo.MenuItem;
	
	public class UncaughtErrorsPlugin extends PluginBase implements IMenuPlugin
	{
		override public function get name():String { return "Uncaught Error Handlers Plugin"; }
		override public function get author():String { return "Moonshine Project Team"; }
		override public function get description():String { return "Catch any uncaught errors in the application"; }
		
		public function UncaughtErrorsPlugin() {}
		
		override public function activate():void
		{
			super.activate();
			
			// add event listeners
			FlexGlobals.topLevelApplication.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, uncaughtErrorHandler);
		}
		
		override public function deactivate():void
		{
			super.deactivate();
			// remove event listeners
		}
		
		public function getMenu():MenuItem
		{
			// shall be a place to menu to open list of details
			return null;
		}
		
		private function uncaughtErrorHandler(event:UncaughtErrorEvent):void
		{
			// print to console only for now
			if (event.error is Error)
			{
				error(Error(event.error).getStackTrace());
			}
			else if (event.error is ErrorEvent)
			{
				error(ErrorEvent(event.error).text);
			}
			else
			{
				// a non-Error, non-ErrorEvent type was thrown and uncaught
				error(event.toString());
			}
		}
	}
}