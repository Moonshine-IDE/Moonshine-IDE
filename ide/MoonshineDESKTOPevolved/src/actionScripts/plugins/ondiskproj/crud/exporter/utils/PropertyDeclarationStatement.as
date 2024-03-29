////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugins.ondiskproj.crud.exporter.utils
{
	public class PropertyDeclarationStatement
	{
		protected static var stringProperty:String = "\t\tprivate var _%propertyName%:String;\n" +
				"\t\tpublic function get %propertyName%():String\n" +
				"\t\t{\n" +
				"\t\t\t\treturn _%propertyName%;\n" +
				"\t\t}\n" +
				"\t\tpublic function set %propertyName%(value:String):void\n" +
				"\t\t{\n" +
				"\t\t\t\t_%propertyName% = value;\n" +
				"\t\t}";
		protected static var intProperty:String = "\t\tprivate var _%propertyName%:int;\n" +
				"\t\tpublic function get %propertyName%():int\n" +
				"\t\t{\n" +
				"\t\t\t\treturn _%propertyName%;\n" +
				"\t\t}\n" +
				"\t\tpublic function set %propertyName%(value:int):void\n" +
				"\t\t{\n" +
				"\t\t\t\t_%propertyName% = value;\n" +
				"\t\t}";
		protected static var numberProperty:String = "\t\tprivate var _%propertyName%:Number;\n" +
				"\t\tpublic function get %propertyName%():Number\n" +
				"\t\t{\n" +
				"\t\t\t\treturn _%propertyName%;\n" +
				"\t\t}\n" +
				"\t\tpublic function set %propertyName%(value:Number):void\n" +
				"\t\t{\n" +
				"\t\t\t\t_%propertyName% = value;\n" +
				"\t\t}";
		protected static var dateProperty:String = "\t\tprivate var _%propertyName%:Date;\n" +
				"\t\tpublic function get %propertyName%():Date\n" +
				"\t\t{\n" +
				"\t\t\t\treturn _%propertyName%;\n" +
				"\t\t}\n" +
				"\t\tpublic function set %propertyName%(value:Date):void\n" +
				"\t\t{\n" +
				"\t\t\t\t_%propertyName% = value;\n" +
				"\t\t}";
		protected static var arrayListProperty:String = "\t\tprivate var _%propertyName%:ArrayList = new ArrayList();\n" +
				"\t\tpublic function get %propertyName%():ArrayList\n" +
				"\t\t{\n" +
				"\t\t\t\treturn _%propertyName%;\n" +
				"\t\t}\n" +
				"\t\tpublic function set %propertyName%(value:ArrayList):void\n" +
				"\t\t{\n" +
				"\t\t\t\t_%propertyName% = value;\n" +
				"\t\t}";
		protected static var arrayProperty:String = "\t\tprivate var _%propertyName%:Array = [];\n" +
				"\t\tpublic function get %propertyName%():Array\n" +
				"\t\t{\n" +
				"\t\t\t\treturn _%propertyName%;\n" +
				"\t\t}\n" +
				"\t\tpublic function set %propertyName%(value:Array):void\n" +
				"\t\t{\n" +
				"\t\t\t\t_%propertyName% = value;\n" +
				"\t\t}";

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

		public static function getArray(field:String):String
		{
			return arrayProperty.replace(/%propertyName%/ig, field);
		}
	}
}
