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
package actionScripts.ui.feathersWrapper.help
{
	import flash.events.Event;
	
	import spark.components.Alert;
	
	import actionScripts.interfaces.IViewWithTitle;
	import actionScripts.ui.FeathersUIWrapper;
	import actionScripts.ui.IContentWindow;
	
	import moonshine.plugin.help.events.GettingStartedViewEvent;
	import moonshine.plugin.help.view.GettingStartedView;
	
	public class GettingStartedViewWrapper extends FeathersUIWrapper implements IViewWithTitle, IContentWindow
	{
		private static const LABEL:String = "Getting Started Haxe";
		
		//--------------------------------------------------------------------------
		//
		//  CLASS API
		//
		//--------------------------------------------------------------------------
		
		public function GettingStartedViewWrapper(feathersUIControl:GettingStartedView=null)
		{
			super(feathersUIControl);
		}
		
		override public function initialize():void
		{
			super.initialize();
			this.feathersUIControl.addEventListener(
				GettingStartedView.EVENT_DOWNLOAD_3RDPARTY_SOFTWARE, onDownload3rdPartySoftware,
				false, 0, true);
			this.feathersUIControl.addEventListener(
				GettingStartedViewEvent.EVENT_DO_NOT_SHOW, onDoNotShowCheckboxChanged,
				false, 0, true
			);
		}
		
		//--------------------------------------------------------------------------
		//
		//  INTERFACE API
		//
		//--------------------------------------------------------------------------
		
		public function get title():String 		{	return LABEL;	}
		public function get label():String 		{	return LABEL;	}
		public function get longLabel():String 	{	return LABEL;	}
		public function save():void				{}
		public function isChanged():Boolean 	{	return false;	}
		public function isEmpty():Boolean		{	return false;	}
		
		//--------------------------------------------------------------------------
		//
		//  PUBLIC API
		//
		//--------------------------------------------------------------------------
		
		public function dispose():void
		{
			this.feathersUIControl.removeEventListener(GettingStartedViewEvent.EVENT_DO_NOT_SHOW, onDoNotShowCheckboxChanged);
			this.feathersUIControl.removeEventListener(GettingStartedView.EVENT_DOWNLOAD_3RDPARTY_SOFTWARE, onDownload3rdPartySoftware);
		}
		
		//--------------------------------------------------------------------------
		//
		//  PRIVATE API
		//
		//--------------------------------------------------------------------------
		
		private function onDoNotShowCheckboxChanged(event:GettingStartedViewEvent):void
		{
			Alert.show(event.data.toString());
		}
		
		private function onDownload3rdPartySoftware(event:Event):void
		{
			Alert.show("3rd Party Software Download Requested");
		}
	}
}