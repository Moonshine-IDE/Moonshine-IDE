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
package no.doomsday.utilities.monitoring 
{
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import no.doomsday.console.core.gui.Window;
	import no.doomsday.console.core.introspection.ScopeManager;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class Monitor extends Window
	{
		private var _scope:Dictionary = new Dictionary(true);
		public var properties:Array;
		public var outObj:Object = { };
		public function Monitor(scope:Object, properties:Array) 
		{
			super("Monitor", new Rectangle(0, 0, 300, 100));
			_scope["scope"] = scope;
			this.properties = properties;
		}
		public function get scope():*{
			return _scope["scope"];
		}
		public function update():void {
			outObj.name = scope.name ? scope.name : String(typeof scope);
			for (var i:int = 0; i < properties.length; i++) 
			{
				outObj[properties[i]] = scope[properties[i]];
			}
		}
		public override function toString():String {
			return outObj.toString();
		}
		
	}

}