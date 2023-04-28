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

package actionScripts.utils;

import StringTools;
import haxe.Rest;

class HtmlFormatter {

    /*
        HTML encode replacements. Use %s for substitution.
    */
    // TODO: Check if this function works properly
	public static function sprintf(str:String, ...rest:Any):String {
		var repl:Int = 0;
		var reg = ~/%[%sxd]/g;
        
        //return reg.replace( str, xreplace( "a", repl, ...rest ) );

		return reg.map(str, function(xreg:EReg):String {
			var token = xreg.matched(0);
			switch (token) {
				case "%x":
					return repl < rest.length ? StringTools.htmlEscape(rest[repl++]) : "";
				case "%s":
					return repl < rest.length ? rest[repl++] : "";
				case "%d":
					return repl < rest.length ? Std.string(rest[repl++]) : "";
				default:
					return "%";
			}
		});

        /*
        
        return str.replace(
            ~/%[%sxd]/g,
            function ():String {
                var token:String = arguments[0];
                switch (token) {
                    case "%x":
                        return repl < replacements.length ? TextUtil.htmlEscape(replacements[repl++]) : "";
                    case "%s":
                        return repl < replacements.length ? replacements[repl++] : "";
                    case "%d":
                        return repl < replacements.length ? Number(replacements[repl++]).toString() : "";
                    default:
                        return "%";
                }
            }
        );
        */
    }

	static function xreplace(token:String, repl:Int = 0, ...rest:String):String {
		switch (token) {
			case "%x":
				return repl < rest.length ? StringTools.htmlEscape(rest[repl++]) : "";
			case "%s":
				return repl < rest.length ? rest[repl++] : "";
			case "%d":
				return repl < rest.length ? Std.string(rest[repl++]) : "";
			default:
				return "%";
		}

		return "%";
	}
    
    // sprintf shorthand to remove ... syntaxing
	public static function sprintfa(str:String, replacements:Array<Any>):String {
		if (replacements == null)
			return str;

		// return sprintf.apply( HtmlFormatter, replacements );
		var s = replacements.shift();
		return sprintf(s, ...replacements);
	}

}
