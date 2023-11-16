package actionScripts.plugin.console.view;

import moonshine.editor.text.syntax.parser.ILineParser;
import moonshine.editor.text.syntax.parser.LineParserPattern;
import moonshine.editor.text.syntax.parser.HaxeLineParser;

class ConsoleLineParser implements ILineParser
{
    public static final CL_ERROR:Int = 0x1;
	public static final CL_WARNING:Int = 0x2;
	public static final CL_SUCCESS:Int = 0x3;

	private var errorLines:Array<Int> = [];
	private var warningLines:Array<Int> = [];
	private var successLines:Array<Int> = [];

	@:flash.property
	public var defaultContext(get, never):Int;
	private function get_defaultContext():Int
	{
		return 0x0;	
	}

	public function new() {}

	public function setContext(newContext:Int):Void {}

	public function reset():Void
	{
		this.errorLines = [];
		this.warningLines = [];
		this.successLines = [];	
	}

	public function setErrorAtLine(lineIndex:Int):Void
	{
		this.errorLines.push(lineIndex);
	}

	public function setWarningAtLine(lineIndex:Int):Void
	{
		this.warningLines.push(lineIndex);
	}

	public function setSuccessAtLine(lineIndex:Int):Void
	{
		this.successLines.push(lineIndex);
	}

	public function parse(sourceCode:String, startLine:Int, startChar:Int, endLine:Int, endChar:Int):Array<Int>
	{
		if (this.errorLines.indexOf(startLine) != -1)
		{
			return [0, CL_ERROR];
		}
		if (this.warningLines.indexOf(startLine) != -1)
		{
			return [0, CL_WARNING];
		}
		if (this.successLines.indexOf(startLine) != -1)
		{
			return [0, CL_SUCCESS];
		}

		return [0, 0];
	}
}