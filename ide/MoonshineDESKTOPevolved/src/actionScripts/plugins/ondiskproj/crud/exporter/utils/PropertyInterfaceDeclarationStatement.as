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
	public class PropertyInterfaceDeclarationStatement
	{
		protected static var stringProperty:String =
				"\t\tfunction get %propertyName%():String;\n" +
				"\t\tfunction set %propertyName%(value:String):void;";

		protected static var intProperty:String =
				"\t\tfunction get %propertyName%():int;\n" +
				"\t\tfunction set %propertyName%(value:int):void;";

		protected static var numberProperty:String =
				"\t\tfunction get %propertyName%():Number;\n" +
				"\t\tfunction set %propertyName%(value:Number):void;";

		protected static var dateProperty:String =
				"\t\tfunction get %propertyName%():Date;\n" +
				"\t\tfunction set %propertyName%(value:Date):void;";

		protected static var arrayListProperty:String =
				"\t\tfunction get %propertyName%():ArrayList;\n" +
				"\t\tfunction set %propertyName%(value:ArrayList):void;";

		protected static var arrayProperty:String =
				"\t\tfunction get %propertyName%():Array;\n" +
				"\t\tfunction set %propertyName%(value:Array):void;";

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
