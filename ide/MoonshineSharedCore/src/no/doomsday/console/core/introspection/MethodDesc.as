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
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class MethodDesc
	{
		// <method name="hitTestObject" declaredBy="flash.display::DisplayObject" returnType="Boolean">
		public var name:String;
		public var declaredBy:String;
		public var returnType:String;
		public var params:Vector.<ParamDesc> = new Vector.<ParamDesc>();
		public function MethodDesc(xml:XML) 
		{
			name = xml.@name;
			declaredBy = xml.@declaredBy;
			returnType = xml.@returnType;
			for each(var n:XML in xml..parameter) {
				params.push(new ParamDesc(n));
			}
		}
		
	}

}