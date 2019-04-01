////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
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
// Author: Prominic.NET, Inc.
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugins.browser
{
	import com.tuarua.FreSwift;
	import com.tuarua.WebViewANE;
	import com.tuarua.webview.Settings;
	
	import flash.display.Stage;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.core.FlexGlobals;
	
	import actionScripts.events.AddTabEvent;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.locator.IDEModel;
	import actionScripts.ui.IContentWindow;
	import actionScripts.valueObjects.ConstantsCoreVO;
	
	import components.popup.WebViewANEhtmlView;

	public class WebViewUtils
	{
		private var freSwiftANE:FreSwift = new FreSwift();
		private var htmlView:WebViewANEhtmlView;
		private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		
		private static var instance:WebViewUtils;
		public static function getInstance():WebViewUtils
		{	
			if (!instance) instance = new WebViewUtils();
			return instance;
		}
		
		private var _webview:WebViewANE;
		public function get webview():WebViewANE
		{
			return _webview;
		}
		
		public function getWebViewBySize(width:Number, height:Number):WebViewANE
		{
			if (!_webview)
			{
				var stage:Stage = FlexGlobals.topLevelApplication.stage;
				var viewport:Rectangle = new Rectangle((stage.nativeWindow.width - width)/2, (stage.nativeWindow.height - height)/2, width, height);
				
				var settings:Settings = new Settings();
				settings.persistRequestHeaders = true;
				settings.contextMenu.enabled = true;
				settings.useTransparentBackground = true;
				
				_webview = new WebViewANE();
				_webview.init(stage, viewport, null, settings);
			}
			
			return _webview;
		}
		
		public function openHTMLbyUrl(value:String):void
		{
			if (ConstantsCoreVO.IS_EXTERNAL_BROWSER)
			{
				if (!htmlView)
				{
					htmlView = new WebViewANEhtmlView();
					htmlView.loadURL = value;
					dispatcher.dispatchEvent(new AddTabEvent(htmlView as IContentWindow));
				}
				else
				{
					IDEModel.getInstance().activeEditor = htmlView as IContentWindow;
				}
			}
			else
			{
				navigateToURL(new URLRequest(value), "_blank");
			}
		}
	}
}