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
package actionScripts.plugin.settings.vo
{
	[Bindable] public class LinkOnlySettingVO
	{
		public var label:String;
		public var event:String;
		
		private var _isBusy:Boolean;
		public function get isBusy():Boolean
		{
			return _isBusy;
		}
		public function set isBusy(value:Boolean):void
		{
			_isBusy = value;
		}

		public function LinkOnlySettingVO(label:String, event:String=null)
		{
			this.label = label;
			this.event = event;
		}
	}
}