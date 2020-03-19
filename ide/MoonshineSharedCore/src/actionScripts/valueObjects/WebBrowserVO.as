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
	public class WebBrowserVO
	{	
		public var isDefault:Boolean;
		
		public function WebBrowserVO(name:String=null, debugAdapterType:String=null,isDefault:Boolean=false)
		{
			this.name = name;
			this.debugAdapterType = debugAdapterType;
			this.isDefault = isDefault;
		}
		
		private var _name:String;
		public function get name():String {	return _name; }
		public function set name(value:String):void {	_name = value;	}
		
		private var _debugAdapterType:String;
		public function get debugAdapterType():String {	return _debugAdapterType; }
		public function set debugAdapterType(value:String):void {	_debugAdapterType = value;	}
	}
}