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
	import moonshine.plugin.help.view.TourDeFlexContentsView;
	import actionScripts.ui.IContentWindow;
	import actionScripts.ui.IPanelWindow;
	import actionScripts.ui.LayoutModifier;
	import actionScripts.ui.tabview.CloseTabEvent;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.ui.FeathersUIWrapper;
	import moonshine.plugin.help.events.HelpViewEvent;
	import actionScripts.events.OpenFileEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.ui.tabview.TabEvent;
	import actionScripts.ui.editor.BasicTextEditor;

	public class HelpPlugin extends PluginBase implements IPlugin
	{
		public static const EVENT_TOURDEFLEX:String = "EVENT_TOURDEFLEX";
		public static const EVENT_AS3DOCS:String = "EVENT_AS3DOCS";
		public static const EVENT_ABOUT:String = "EVENT_ABOUT";
		public static const EVENT_CHECK_MINIMUM_SDK_REQUIREMENT:String = "EVENT_CHECK_MINIMUM_SDK_REQUIREMENT";
		public static const EVENT_APACHE_SDK_DOWNLOADER_REQUEST:String = "EVENT_APACHE_SDK_DOWNLOADER_REQUEST";
		public static const EVENT_ENSURE_JAVA_PATH:String = "EVENT_ENSURE_JAVA_PATH";
		public static const EVENT_PRIVACY_POLICY:String = "EVENT_PRIVACY_POLICY";
		private static const THIRD_PARTY_WARNING_TEXT:String = "<!--\n\nThis example or component has been developed by a 3rd party and is hosted outside of the Tour De Flex site and may contain links to non ASF sites.\nIt's code may not be Open Source or may be under a license other than the Apache license so please check carefully before using it.\nNeither the ASF or the Apache Flex PMC can endorse or recommend using this example but you may still find it useful.\n\n-->";
		
		public static var ABOUT_SUBSCRIBE_ID_TO_WORKER:String;
		
		override public function get name():String			{ return "Help Plugin"; }
		override public function get author():String		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String	{ return "Help Plugin."; }

		private var tourDeFlexView:TourDeFlexContentsView;
		private var docsView:AS3DocsView;

		override public function activate():void
		{
			super.activate();
			
			if (ConstantsCoreVO.IS_AIR) dispatcher.addEventListener(EVENT_TOURDEFLEX, handleTourDeFlexConfigure);
			
			dispatcher.addEventListener(EVENT_ABOUT, abouthShowHandler);
			dispatcher.addEventListener(EVENT_AS3DOCS, as3DocHandler);
			dispatcher.addEventListener(CloseTabEvent.EVENT_TAB_CLOSED, tabClosedHandler);
			dispatcher.addEventListener(EVENT_PRIVACY_POLICY, privacyPolicyHandler);
			dispatcher.addEventListener(EVENT_PRIVACY_POLICY, privacyPolicyHandler);
			dispatcher.addEventListener(TabEvent.EVENT_TAB_SELECT, tabSelectHandler);
		}

		override public function deactivate():void
		{
			dispatcher.removeEventListener(EVENT_TOURDEFLEX, handleTourDeFlexConfigure);
			dispatcher.removeEventListener(EVENT_ABOUT, abouthShowHandler);
			dispatcher.removeEventListener(EVENT_AS3DOCS, as3DocHandler);
			dispatcher.removeEventListener(CloseTabEvent.EVENT_TAB_CLOSED, tabClosedHandler);
			dispatcher.removeEventListener(EVENT_PRIVACY_POLICY, privacyPolicyHandler);
			dispatcher.removeEventListener(TabEvent.EVENT_TAB_SELECT, tabSelectHandler);

			super.deactivate();
		}

		protected function handleTourDeFlexConfigure(event:Event):void
		{
			if (!tourDeFlexView)
			{
				tourDeFlexView = new TourDeFlexContentsView();
				tourDeFlexView.addEventListener(HelpViewEvent.OPEN_FILE, tourDeFlexView_openFileHandler);
				tourDeFlexView.addEventListener(HelpViewEvent.OPEN_LINK, tourDeFlexView_openLinkHandler);
				tourDeFlexView.addEventListener(Event.CLOSE, tourDeFlexView_closeHandler);
				var tourDeFlexViewWrapper:TourDeFlexContentsViewWrapper = new TourDeFlexContentsViewWrapper(tourDeFlexView);
				tourDeFlexViewWrapper.percentWidth = 100.0;
				tourDeFlexViewWrapper.percentHeight = 100.0;
				LayoutModifier.addToSidebar(tourDeFlexViewWrapper, event);
			}
			else
			{
				tourDeFlexView_closeHandler(event);
			}
		}
		
		private function tabSelectHandler(event:Event):void
		{
			if(!tourDeFlexView)
			{
				return;
			}
			var textEditor:BasicTextEditor = model.activeEditor as BasicTextEditor;
			var activeFilePath:String = null;
			if(textEditor && textEditor.currentFile)
			{
				activeFilePath = textEditor.currentFile.fileBridge.nativePath;
			}
			tourDeFlexView.activeFilePath = activeFilePath;
		}
		
		protected function as3DocHandler(event:Event):void
		{
			if (!docsView)
			{
				docsView = new AS3DocsView();
				docsView.addEventListener(HelpViewEvent.OPEN_LINK, as3DocsView_openLinkHandler);
				docsView.addEventListener(Event.CLOSE, as3DocsView_closeHandler);
				var docsViewWrapper:AS3DocsViewWrapper = new AS3DocsViewWrapper(docsView);
				docsViewWrapper.percentWidth = 100.0;
				docsViewWrapper.percentHeight = 100.0;
				LayoutModifier.addToSidebar(docsViewWrapper, event);
			}
			else
			{
				as3DocsView_closeHandler(event);
			}
		}

		private function tourDeFlexView_openFileHandler(event:HelpViewEvent):void
		{
			var link:String = event.link;
			var application:String = event.data;
			var tmpFileLocation:FileLocation;
			if(application.indexOf("_ThirdParty.txt") != -1)
			{
				// Since we can't use same 'opened' file to open in multiple tabs.
				// we need some extra works here
				tmpFileLocation = model.fileCore.resolveApplicationStorageDirectoryPath(application);
				if (!tmpFileLocation.fileBridge.exists)
				{
					tmpFileLocation.fileBridge.save(THIRD_PARTY_WARNING_TEXT);
				}
				if (tmpFileLocation.fileBridge.exists)
				{
					dispatcher.dispatchEvent(
							new OpenFileEvent(OpenFileEvent.OPEN_FILE, [tmpFileLocation], -1, null, true, link)
					);
				}
			}
			else
			{
				tmpFileLocation = model.fileCore.resolveApplicationDirectoryPath("tourDeFlex/"+application+".mxml");
				if (tmpFileLocation.fileBridge.exists)
				{
					dispatcher.dispatchEvent( 
						new OpenFileEvent(OpenFileEvent.OPEN_FILE, [tmpFileLocation], -1, null, true, link)
					);
				}
			}
		}

		private function tourDeFlexView_openLinkHandler(event:HelpViewEvent):void
		{
			navigateToURL(new URLRequest(event.link), "_blank");
		}

		protected function tourDeFlexView_closeHandler(event:Event):void
		{
			tourDeFlexView.removeEventListener(HelpViewEvent.OPEN_LINK, tourDeFlexView_openLinkHandler);
			tourDeFlexView.removeEventListener(Event.CLOSE, tourDeFlexView_closeHandler);
			var tourDeFlexViewWrapper:IPanelWindow = IPanelWindow(tourDeFlexView.parent);
			LayoutModifier.removeFromSidebar(tourDeFlexViewWrapper);

			tourDeFlexView = null;
		}

		private function as3DocsView_openLinkHandler(event:HelpViewEvent):void
		{
			navigateToURL(new URLRequest(event.link), "_blank");
		}

		protected function as3DocsView_closeHandler(event:Event):void
		{
			docsView.removeEventListener(HelpViewEvent.OPEN_LINK, as3DocsView_openLinkHandler);
			docsView.removeEventListener(Event.CLOSE, as3DocsView_closeHandler);
			var docsViewWrapper:IPanelWindow = IPanelWindow(docsView.parent);
			LayoutModifier.removeFromSidebar(docsViewWrapper);

			docsView = null;
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
				if (!tmpEvent.tab || (tmpEvent.tab is IPanelWindow)) Object(tourDeFlexView).refresh();
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
import actionScripts.interfaces.IViewWithTitle;
import moonshine.plugin.help.view.AS3DocsView;
import moonshine.plugin.help.view.TourDeFlexContentsView;

//IPanelWindow used by LayoutModifier.addToSidebar() and removeFromSidebar()
class AS3DocsViewWrapper extends FeathersUIWrapper implements IPanelWindow, IViewWithTitle {
	public function AS3DocsViewWrapper(feathersUIControl:AS3DocsView)
	{
		super(feathersUIControl);
	}

	public function get title():String
	{
		return AS3DocsView(feathersUIControl).title;
	}

	override public function get className():String
	{
		//className used by LayoutModifier.attachSidebarSections
		return "AS3DocsView";
	}
}

//IPanelWindow used by LayoutModifier.addToSidebar() and removeFromSidebar()
class TourDeFlexContentsViewWrapper extends FeathersUIWrapper implements IPanelWindow, IViewWithTitle {
	public function TourDeFlexContentsViewWrapper(feathersUIControl:TourDeFlexContentsView)
	{
		super(feathersUIControl);
	}

	public function get title():String
	{
		return TourDeFlexContentsView(feathersUIControl).title;
	}

	override public function get className():String
	{
		//className used by LayoutModifier.attachSidebarSections
		return "TourDeFlexContentsView";
	}
}