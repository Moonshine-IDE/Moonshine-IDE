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
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.core.IFlexDisplayObject;
	import mx.resources.ResourceManager;
	
	import actionScripts.events.AddTabEvent;
	import actionScripts.plugin.IPlugin;
	import actionScripts.plugin.PluginBase;
	import moonshine.plugin.help.view.AS3DocsView;
	import actionScripts.ui.IContentWindow;
	import actionScripts.ui.IPanelWindow;
	import actionScripts.ui.LayoutModifier;
	import actionScripts.ui.tabview.CloseTabEvent;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.ui.FeathersUIWrapper;

	public class HelpPlugin extends PluginBase implements IPlugin
	{
		public static const EVENT_TOURDEFLEX:String = "EVENT_TOURDEFLEX";
		public static const EVENT_AS3DOCS:String = "EVENT_AS3DOCS";
		public static const EVENT_ABOUT:String = "EVENT_ABOUT";
		public static const EVENT_CHECK_MINIMUM_SDK_REQUIREMENT:String = "EVENT_CHECK_MINIMUM_SDK_REQUIREMENT";
		public static const EVENT_APACHE_SDK_DOWNLOADER_REQUEST:String = "EVENT_APACHE_SDK_DOWNLOADER_REQUEST";
		public static const EVENT_ENSURE_JAVA_PATH:String = "EVENT_ENSURE_JAVA_PATH";
		public static const EVENT_PRIVACY_POLICY:String = "EVENT_PRIVACY_POLICY";
		
		public static var ABOUT_SUBSCRIBE_ID_TO_WORKER:String;
		
		override public function get name():String			{ return "Help Plugin"; }
		override public function get author():String		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String	{ return "Help Plugin."; }

		private var tourdeContentView: IPanelWindow;

		override public function activate():void
		{
			super.activate();
			
			if (ConstantsCoreVO.IS_AIR) dispatcher.addEventListener(EVENT_TOURDEFLEX, handleTourDeFlexConfigure);
			
			dispatcher.addEventListener(EVENT_ABOUT, abouthShowHandler);
			dispatcher.addEventListener(EVENT_AS3DOCS, as3DocHandler);
			dispatcher.addEventListener(CloseTabEvent.EVENT_TAB_CLOSED, tabClosedHandler);
			dispatcher.addEventListener(EVENT_PRIVACY_POLICY, privacyPolicyHandler);
		}

		protected function handleTourDeFlexConfigure(event:Event):void
		{
            tourdeContentView = model.flexCore.getTourDeView();
			LayoutModifier.addToSidebar(tourdeContentView, event);
		}
		
		protected function as3DocHandler(event:Event):void
		{
			var docsView:AS3DocsView = new AS3DocsView();
			docsView.addEventListener(Event.CLOSE, as3DocsView_closeHandler);
			var docsViewWrapper:AS3DocsViewWrapper = new AS3DocsViewWrapper(docsView);
			docsViewWrapper.percentWidth = 100.0;
			docsViewWrapper.percentHeight = 100.0;
			LayoutModifier.addToSidebar(docsViewWrapper, event);
		}

		protected function as3DocsView_closeHandler(event:Event):void
		{
			var docsView:AS3DocsView = AS3DocsView(event.currentTarget);
			docsView.removeEventListener(Event.CLOSE, as3DocsView_closeHandler);
			var docsViewWrapper:AS3DocsViewWrapper = AS3DocsViewWrapper(docsView.parent);
			LayoutModifier.removeFromSidebar(docsViewWrapper);
		}
		
		protected function abouthShowHandler(event:Event):void
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
			dispatcher.dispatchEvent(new AddTabEvent(aboutScreen as IContentWindow));
		}
		
		private function tabClosedHandler(event:Event):void
		{
			if (event is CloseTabEvent)
			{
				var tmpEvent:CloseTabEvent = event as CloseTabEvent;
				if (!tmpEvent.tab || (tmpEvent.tab is IPanelWindow)) Object(tourdeContentView).refresh();
			}
		}

        private function privacyPolicyHandler(event:Event):void
		{
			var url:String = ResourceManager.getInstance().getString('resources', 'PRIVACY_POLICY_URL');
			navigateToURL(new URLRequest(url));
        }
	}
}

import actionScripts.ui.FeathersUIWrapper;
import actionScripts.ui.IPanelWindow;
import feathers.core.FeathersControl;

//IPanelWindow used by LayoutModifier.addToSidebar() and removeFromSidebar()
class AS3DocsViewWrapper extends FeathersUIWrapper implements IPanelWindow {
	public function AS3DocsViewWrapper(feathersUIControl:FeathersControl)
	{
		super(feathersUIControl);
	}

	override public function get className():String
	{
		//className used by LayoutModifier.attachSidebarSections
		return "AS3DocsView";
	}
}