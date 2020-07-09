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
package actionScripts.utils
{
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import flash.net.SharedObject;
	
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;
	
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.LanguageServerUnzipperEvent;
	import actionScripts.locator.IDEModel;
	
	import components.popup.LanguageServerUnzipProgressPopup;

	public class LanguageServerUnzipper extends EventDispatcher
	{
		private var model:IDEModel = IDEModel.getInstance();
		private var progressPopup:LanguageServerUnzipProgressPopup;
		
		public function LanguageServerUnzipper()
		{
			var cookie:SharedObject = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_LOCAL);
			if (cookie.data.hasOwnProperty('revision') && cookie.data['revision'] == model.revision)
			{
				notifyCompletion();
				return;
			}
			
			startUnzip();
		}
		
		protected function notifyCompletion():void
		{
			GlobalEventDispatcher.getInstance().dispatchEvent(new LanguageServerUnzipperEvent(LanguageServerUnzipperEvent.EVENT_LANGUAGE_SERVER_UNZIP_COMPLETES));
		}
		
		protected function startUnzip():void
		{
			progressPopup = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, LanguageServerUnzipProgressPopup, true) as LanguageServerUnzipProgressPopup;
			PopUpManager.centerPopUp(progressPopup);
		}
	}
}