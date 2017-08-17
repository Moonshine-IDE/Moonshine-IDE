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
package no.doomsday.console.utilities.math 
{
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class MathUtils
	{
		
		public function MathUtils() 
		{
			
		}
		public static function random(from:Number = 0, to:Number = 1, round:Boolean = false):Number {
			var v:Number = from + Math.random() * (to - from);
			return round ? Math.round(v) : v;
		}
		public static function add(a:Number, b:Number):Number {
			return a + b;
		}
		public static function subtract(a:Number, b:Number):Number {
			return a - b;
		}
		public static function divide(a:Number, b:Number):Number {
			return a / b;
		}
		public static function multiply(a:Number, b:Number):Number {
			return a * b;
		}
		
	}

}