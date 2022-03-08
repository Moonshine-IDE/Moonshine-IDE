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
package actionScripts.plugins.ondiskproj.crud.exporter.utils
{
	public class PropertyDeclarationStatement
	{
		protected static var stringProperty:String = "private var _%propertyName%:String;\n" +
				"public function get %propertyName%():String\n" +
				"{\n" +
				"\treturn _%propertyName%;\n" +
				"}\n" +
				"public function set %propertyName%(value:String):void\n" +
				"{\n" +
				"\t_%propertyName% = value;\n" +
				"}";
		protected static var intProperty:String = "private var _%propertyName%:int;\n" +
				"public function get %propertyName%():int\n" +
				"{\n" +
				"\treturn _%propertyName%;\n" +
				"}\n" +
				"public function set %propertyName%(value:int):void\n" +
				"{\n" +
				"\t_%propertyName% = value;\n" +
				"}";
		protected static var numberProperty:String = "private var _%propertyName%:Number;\n" +
				"public function get %propertyName%():Number\n" +
				"{\n" +
				"\treturn _%propertyName%;\n" +
				"}\n" +
				"public function set %propertyName%(value:Number):void\n" +
				"{\n" +
				"\t_%propertyName% = value;\n" +
				"}";
		protected static var dateProperty:String = "private var _%propertyName%:Date;\n" +
				"public function get %propertyName%():Date\n" +
				"{\n" +
				"\treturn _%propertyName%;\n" +
				"}\n" +
				"public function set %propertyName%(value:Date):void\n" +
				"{\n" +
				"\t_%propertyName% = value;\n" +
				"}";
		protected static var arrayListProperty:String = "private var _%propertyName%:ArrayList;\n" +
				"public function get %propertyName%():ArrayList\n" +
				"{\n" +
				"\treturn _%propertyName%;\n" +
				"}\n" +
				"public function set %propertyName%(value:ArrayList):void\n" +
				"{\n" +
				"\t_%propertyName% = value;\n" +
				"}";

		public static function getString(field:String):String
		{
			return stringProperty.replace(/%propertyName%/ig, field);
		}

		public static function getInt(field:String):String
		{
			return intProperty.replace(/%propertyName%/ig, field);
		}

		public static function getNumber(field:String):String
		{
			return numberProperty.replace(/%propertyName%/ig, field);
		}

		public static function getDate(field:String):String
		{
			return dateProperty.replace(/%propertyName%/ig, field);
		}

		public static function getArrayList(field:String):String
		{
			return arrayListProperty.replace(/%propertyName%/ig, field);
		}
	}
}
