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
package actionScripts.valueObjects
{
	public class GenericSelectableObject
	{
		private var _data:Object;
		public function get data():Object
		{
			return _data;
		}
		public function set data(value:Object):void
		{
			_data = value;
		}
		
		private var _isSelected:Boolean;
		public function get isSelected():Boolean
		{
			return _isSelected;
		}
		public function set isSelected(value:Boolean):void
		{
			_isSelected = value;
		}
		
		public function GenericSelectableObject(isSelcted:Boolean, data:Object)
		{
			this.isSelected = isSelcted;
			this.data = data;
		}
	}
}