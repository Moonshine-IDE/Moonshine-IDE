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
package actionScripts.utils
{
    public class SerializeUtil
    {
        /**
         * Serializes a Boolean value into True or False strings.
         */
        public static function serializeBoolean(b:Boolean):String
        {
            return b ? "True" : "False";
        }

        /**
         * Serialize a String value so it's empty when null
         */
        public static function serializeString(str:String):String
        {
            return str ? str : "";
        }

        /**
         * Serialize a delimited String value
         */
        public static function serializeDelimitedString(collection:Vector.<String>, delimiter:String = "\n"):String
        {
            if(!collection || collection.length == 0)
            {
                return "";
            }
            return collection.join(delimiter);
        }

        /**
         * Serialize key-value pairs to FD-like XML elements using a template element
         *  Example:
         *		<option accessible="True" />
         *		<option allowSourcePathOverlap="True" />
         *		<option benchmark="True" />
         *		<option es="True" />
         *		<option locale="" />
         */
        public static function serializePairs(pairs:Object, template:XML):XMLList
        {
            var list:XML = <xml/>;
            for (var key:String in pairs) {
                var node:XML = template.copy();
                node.@[key] = pairs[key];
                list.appendChild(node);
            }
            return list.children();
        }

        public static function serializeObjectPairs(pairs:Object, template:XML):XMLList
        {
            var list:XML = <xml/>;

            var node:XML = template.copy();
            var hasProperties:Boolean = false;

            for (var key:String in pairs)
            {
                node.@[key] = pairs[key];
                hasProperties = true;
            }

            if (hasProperties)
            {
                list.appendChild(node);
            }

            return list.children();
        }

        /**
         * Deserializes True and False strings to true and false Boolean values.
         */
        public static function deserializeBoolean(o:Object):Boolean
        {
            var str:String = o.toString();
            return str.toLowerCase() == "true";
        }

        /**
         * Deserialize a String value so it's null when empty
         */
        public static function deserializeString(o:Object):String
        {
            var str:String = o.toString();
            if (str.length == 0) return null;
            if (str == "null") return null;
            return str;
        }

        /**
         * Deserialize a delimited String value
         */
        public static function deserializeDelimitedString(o:Object, delimiter:String = "\n"):Vector.<String>
        {
            var str:String = deserializeString(o);
            if(str == null)
            {
                return null;
            }
            var parts:Array = str.split(delimiter);

            //convert to vector
            var result:Vector.<String> = new <String>[];
            for(var i:int = 0, count:int = parts.length; i < count; i++)
            {
                var part:String = parts[i] as String;
                result[i] = part;
            }

            return result;
        }
    }
}
