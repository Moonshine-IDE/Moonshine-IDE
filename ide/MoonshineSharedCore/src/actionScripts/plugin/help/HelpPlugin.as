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
package actionScripts.plugin.help
{
	import flash.events.Event;
	
	import mx.core.IFlexDisplayObject;
	
	import actionScripts.events.AddTabEvent;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.IPlugin;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.help.view.AS3DocsView;
	import actionScripts.ui.IContentWindow;
	import actionScripts.ui.IPanelWindow;
	import actionScripts.ui.LayoutModifier;
	import actionScripts.ui.tabview.CloseTabEvent;
	import actionScripts.valueObjects.ConstantsCoreVO;
	
	import components.popup.JavaPathSetupPopup;
	import components.popup.SDKUnzipConfirmPopup;
	
	public class HelpPlugin extends PluginBase implements IPlugin
	{
		public static const EVENT_TOURDEFLEX:String = "EVENT_TOURDEFLEX";
		public static const EVENT_AS3DOCS:String = "EVENT_AS3DOCS";
		public static const EVENT_ABOUT:String = "EVENT_ABOUT";
		public static const EVENT_CHECK_MINIMUM_SDK_REQUIREMENT:String = "EVENT_CHECK_MINIMUM_SDK_REQUIREMENT";
		public static const EVENT_APACHE_SDK_DOWNLOADER_REQUEST:String = "EVENT_APACHE_SDK_DOWNLOADER_REQUEST";
		public static const EVENT_ENSURE_JAVA_PATH:String = "EVENT_ENSURE_JAVA_PATH";
		
		override public function get name():String			{ return "Help Plugin"; }
		override public function get author():String		{ return "Moonshine Project Team"; }
		override public function get description():String	{ return "Help Plugin. Esc exits."; }
		
		private var tourdeContentView: IPanelWindow;
		private var idemodel:IDEModel = IDEModel.getInstance();
		private var as3DocsPanel:IPanelWindow = new AS3DocsView();
		private var sdkUnzipView:SDKUnzipConfirmPopup;
		private var javaPathDetection:JavaPathSetupPopup;
		
		private var panelCollectedValues:int;
		private var totalPanelCollection:int = 2; // tourde, usefullinks
		
		override public function activate():void
		{
			super.activate();
			
			if (ConstantsCoreVO.IS_AIR) dispatcher.addEventListener(EVENT_TOURDEFLEX, handleTourDeFlexConfigure);
			
			dispatcher.addEventListener(EVENT_ABOUT, handleAboutShow);
			dispatcher.addEventListener(EVENT_AS3DOCS, handleAS3DocsShow);
			dispatcher.addEventListener(CloseTabEvent.EVENT_TAB_CLOSED, handleTreeRefresh);
		}
		
		protected function handleTourDeFlexConfigure(event:Event):void
		{
			panelCollectedValues++;
			if (!LayoutModifier.isTourDeFlex && (panelCollectedValues <= totalPanelCollection)) 
			{
				LayoutModifier.setButNotSaveValue(LayoutModifier.TOURDE_FLEX_FIELD, true);
				return;
			}
			
			tourdeContentView = idemodel.flexCore.getTourDeView();
			IDEModel.getInstance().mainView.addPanel(tourdeContentView);
			LayoutModifier.isTourDeFlex = true;
		}
		
		protected function handleAS3DocsShow(event:Event):void
		{
			panelCollectedValues++;
			if (!LayoutModifier.isUsefulLinks && (panelCollectedValues <= totalPanelCollection)) 
			{
				LayoutModifier.setButNotSaveValue(LayoutModifier.USEFULLINKS_FIELD, true);
				return;
			}
			
			as3DocsPanel.height = 110;
			IDEModel.getInstance().mainView.addPanel(as3DocsPanel);
			LayoutModifier.isUsefulLinks = true;
		}
		
		protected function handleAboutShow(event:Event):void
		{
			// Show About Panel in Tab
			for each (var tab:IContentWindow in model.editors)
			{
				if (tab["className"] == "AboutScreen") 
				{
					model.activeEditor = tab;
					return;
				}
			}
			
			var aboutScreen: IFlexDisplayObject = model.aboutCore.getNewAbout(null);
			GlobalEventDispatcher.getInstance().dispatchEvent(
				new AddTabEvent(aboutScreen as IContentWindow)
			);
		}
		
		private function handleTreeRefresh(event:CloseTabEvent):void
		{
			if (!event.tab || (event.tab is IPanelWindow)) Object(tourdeContentView).refresh();
		}
		
		/**
		 * In case of Windows we'll open
		 * integrated SDK Downloader view
		 */
		private function onApacheSDKDownloader(event:Event):void
		{
			if (!model.sdkInstallerView)
			{
				model.sdkInstallerView = model.flexCore.getSDKInstallerView();
				Object(model.sdkInstallerView).requestedSDKDownloadVersion = ConstantsCoreVO.REQUIRED_FLEXJS_SDK_VERION_MINIMUM;
				model.sdkInstallerView.addEventListener(CloseTabEvent.EVENT_TAB_CLOSED, onDefineSDKClosed, false, 0, true);
			}
			else
			{
				model.activeEditor = (model.sdkInstallerView as IContentWindow);
				return;
			}
			
			GlobalEventDispatcher.getInstance().dispatchEvent(
				new AddTabEvent(model.sdkInstallerView as IContentWindow)
			);
		}
		
		/**
		 * On SDK Downloader view closed
		 */
		private function onDefineSDKClosed(event:CloseTabEvent):void
		{
			model.sdkInstallerView.removeEventListener(CloseTabEvent.EVENT_TAB_CLOSED, onDefineSDKClosed);
			model.sdkInstallerView = null;
		}
	}
}