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
package actionScripts.plugin.settings.validators
{
	public class StringValidator implements IValidator
	{
		public function StringValidator(minLength:Number
										=-1,maxLength:Number=-1,noSpaces:Boolean = false,
		restrictChars:Object=null,badChars:Object=null)
		{
		}
		/**
		 * 
		 * @param content
		 * @param rules
		 * Rules can be one be any of the following
		 * minValue - minimun string length
		 * maxValue
		 * noSpaces
		 * restrictChars
		 * badChars
		 * @return 
		 * 
		 */		
		public function validate(content:Object, rules:Object=null):Boolean
		{
			return false;
		}
	}
}