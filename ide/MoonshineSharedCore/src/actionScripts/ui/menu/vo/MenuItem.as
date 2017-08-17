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
package actionScripts.ui.menu.vo
{
	import __AS3__.vec.Vector;
	
	public class MenuItem extends Object
	{
		public function MenuItem(label:String , items:Array=null, event:String=null,
								 mac_key:*=null, mac_mod:Array=null,
								 win_key:*=null, win_mod:Array=null,
								 lnx_key:*=null, lnx_mod:Array=null,
								 parent:Array=null)
		{
			this.label = label;

			if(!label)
			{
				isSeparator = true;
			}
			
			if (items) 
			{
				this.items = Vector.<MenuItem>(items);
			}
			
			this.event = event;
			
			this.mac_key = mac_key;
			this.mac_mod = mac_mod;
			
			this.win_key = win_key;
			this.win_mod = win_mod;
			
			this.lnx_key = lnx_key;
			this.lnx_mod = lnx_mod;
		}
		
		
		public var label:String;
		
		public var items:Vector.<MenuItem>;
		
		public var event:String;
		
		public var mac_key:*;
		public var mac_mod:Array;
		
		public var win_key:*;
		public var win_mod:Array;

		public var lnx_key:*;
		public var lnx_mod:Array;
		
		public var data:*;
		
		public var isSeparator:Boolean;
		public var parents:Array; 
	}
}