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
package actionScripts.ui.feathersWrapper.gettingStarted
{
	import actionScripts.interfaces.IViewWithTitle;
	import actionScripts.ui.FeathersUIWrapper;
	import actionScripts.ui.IContentWindow;
	
	import feathers.core.FeathersControl;
	
	public class GettingStartedViewWrapper extends FeathersUIWrapper implements IViewWithTitle, IContentWindow
	{
		private static const LABEL:String = "Getting Started Haxe";
		
		public function GettingStartedViewWrapper(feathersUIControl:FeathersControl=null)
		{
			super(feathersUIControl);
		}
		
		public function get title():String
		{
			return LABEL;
		}
		
		public function get label():String
		{
			return LABEL;
		}
		
		public function get longLabel():String
		{
			return LABEL;
		}
		
		public function save():void
		{
		}
		
		public function isChanged():Boolean
		{
			return false;
		}
		
		public function isEmpty():Boolean
		{
			return false;
		}
	}
}