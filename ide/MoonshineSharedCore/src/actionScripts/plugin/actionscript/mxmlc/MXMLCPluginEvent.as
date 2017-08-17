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
package actionScripts.plugin.actionscript.mxmlc
{
	import flash.events.Event;
	
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.core.compiler.CompilerEventBase;
	
	/**
	 * ...
	 * @author SmilyOrg
	 */
	public class MXMLCPluginEvent extends CompilerEventBase 
	{
		public var sdk:FileLocation;
		public function MXMLCPluginEvent(type:String, sdk:FileLocation = null, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			this.sdk = sdk;
		} 
		
		public override function clone():Event
		{ 
			return new MXMLCPluginEvent(type, sdk, bubbles, cancelable);
		} 
		
		public override function toString():String
		{ 
			return formatToString("MXMLCPluginEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
	}
}