package actionScripts.plugin.console.view;

import moonshine.editor.text.syntax.parser.LineParserPattern;
import moonshine.editor.text.syntax.parser.HaxeLineParser;

class ConsoleLineParser extends HaxeLineParser 
{
    public static final CL_WARNING:Int = 0x4;

    public function new()
    {
        super();

        patterns = [
			// #conditional
			
			// "
			new LineParserPattern(HaxeLineParser.HX_STRING1, ~/^"(?:\\\\|\\"|[^\n])*?(?:"|\\\n|(?=\n))/),
			// '
			new LineParserPattern(HaxeLineParser.HX_STRING2, ~/^'(?:\\\\|\\'|[^\n])*?(?:'|\\\n|(?=\n))/),
			// //
			new LineParserPattern(CL_WARNING, ~/^OpenJDK.*?(?:\*\/|\n)/),
			// /*
			new LineParserPattern(HaxeLineParser.HX_MULTILINE_COMMENT, ~/^\/\*.*?(?:\*\/|\n)/),
			// ~/pattern/
			
		];
    }    

	public var nowContext = 0x3;

	override public function parse(sourceCode:String):Array<Int> {
		/*initializeKeywordSet();
		result = [];

		for (endPattern in endPatterns) {
			if (endPattern.type == context) {
				result.push(0);
				result.push(context);
				findContextEnd(sourceCode, endPattern.expression);
				break;
			}
		}

		if (result.length == 0) {
			splitOnContext(sourceCode);
		}*/


		

		return [0, 0, sourceCode.length];
	}
}