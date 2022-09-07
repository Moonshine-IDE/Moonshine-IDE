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
