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
package actionScripts.controllers
{
	import flash.events.Event;
	
	import actionScripts.events.AddTabEvent;
	import actionScripts.locator.IDEModel;

	public class AddTabCommand implements ICommand
	{
		private var model:IDEModel = IDEModel.getInstance();
		
		public function execute(event:Event):void
		{
			var e:AddTabEvent = AddTabEvent(event);
			// Remove empty 'New' editor or splashscreen
			// Update - Moon-103 implementation want splash screen to be open so adding one more clause to check if tab is splashscreen 
			if (model.activeEditor && model.activeEditor.isEmpty() && (model.activeEditor.name.substr(0,12).toString()!="SplashScreen"))
			{
				var index:int = model.editors.getItemIndex(model.activeEditor);
				
				if (index > -1) model.editors.removeItemAt(index);
			}
			
			model.editors.addItem(e.tab);
		}
		
	}
}