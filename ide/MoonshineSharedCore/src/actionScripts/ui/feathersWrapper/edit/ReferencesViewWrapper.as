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
package actionScripts.ui.feathersWrapper.edit
{
	import actionScripts.interfaces.IViewWithTitle;
	import actionScripts.ui.FeathersUIWrapper;
	
	import feathers.core.FeathersControl;
	
	import moonshine.plugin.references.view.ReferencesView;
	
	public class ReferencesViewWrapper extends FeathersUIWrapper implements IViewWithTitle
	{
		public function ReferencesViewWrapper(feathersUIControl:FeathersControl=null)
		{
			super(feathersUIControl);
		}
		
		public function get title():String
		{
			return ReferencesView(feathersUIControl).title;
		}
		
		override public function get className():String
		{
			//className may be used by LayoutModifier
			return "ReferencesView";
		}
	}
}