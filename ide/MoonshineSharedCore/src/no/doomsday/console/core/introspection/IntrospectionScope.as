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
package no.doomsday.console.core.introspection 
{
	import no.doomsday.console.core.text.autocomplete.AutocompleteDictionary;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class IntrospectionScope
	{
		public var autoCompleteDict:AutocompleteDictionary = new AutocompleteDictionary();
		public var children:Vector.<ChildScopeDesc>;
		public var accessors:Vector.<AccessorDesc>;
		public var methods:Vector.<MethodDesc>;
		public var variables:Vector.<VariableDesc>;
		public var obj:Object;
		public function IntrospectionScope() 
		{
			
		}
		
	}

}