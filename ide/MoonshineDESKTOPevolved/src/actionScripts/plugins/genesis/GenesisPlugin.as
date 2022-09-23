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
package actionScripts.plugins.genesis
{
	import actionScripts.plugins.build.ConsoleBuildPluginBase;
	import actionScripts.events.GenesisEvent;
	import actionScripts.plugins.genesis.utils.ImportGenesisCatalog;
	import actionScripts.valueObjects.ConstantsCoreVO;

	import components.popup.ImportGenesisPopup;

	import flash.display.DisplayObject;

	import flash.events.Event;

	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;

	import mx.managers.PopUpManager;

	public class GenesisPlugin extends ConsoleBuildPluginBase
	{
		public static var NAMESPACE:String = "actionScripts.plugins.genesis::GenesisPlugin";

		override public function get name():String			{ return "Genesis"; }
		override public function get author():String		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL + " Project Team"; }
		override public function get description():String	{ return "Access to Genesis support from Moonshine-IDE"; }
		
		private var importGenesisPopup:ImportGenesisPopup;

		override public function activate():void
		{
			super.activate();

			dispatcher.addEventListener(GenesisEvent.IMPORT_GENESIS_PROJECT, onImportGenesisEvent, false, 0, true);
		}
		
		override public function deactivate():void
		{
			super.deactivate();

			dispatcher.removeEventListener(GenesisEvent.IMPORT_GENESIS_PROJECT, onImportGenesisEvent);
		}

		private function onImportGenesisEvent(event:Event):void
		{
			if (!importGenesisPopup)
			{
				importGenesisPopup = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, ImportGenesisPopup) as ImportGenesisPopup;
				importGenesisPopup.addEventListener(CloseEvent.CLOSE, onImportGenesisPopupClosed);
				importGenesisPopup.addEventListener(ImportGenesisPopup.EVENT_FORM_SUBMIT, onImportGenesisPopupSubmit);
				PopUpManager.centerPopUp(importGenesisPopup);
			}
		}

		private function onImportGenesisPopupSubmit(event:Event):void
		{
			var url:String = importGenesisPopup.url;
			new ImportGenesisCatalog(url);
		}

		private function onImportGenesisPopupClosed(event:CloseEvent):void
		{
			importGenesisPopup.removeEventListener(CloseEvent.CLOSE, onImportGenesisPopupClosed);
			importGenesisPopup.removeEventListener(ImportGenesisPopup.EVENT_FORM_SUBMIT, onImportGenesisPopupSubmit);
			importGenesisPopup = null;
		}
	}
}