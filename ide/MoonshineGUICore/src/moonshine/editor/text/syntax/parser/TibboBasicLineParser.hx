/*
	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License

	No warranty of merchantability or fitness of any kind.
	Use this software at your own risk.
 */

package moonshine.editor.text.syntax.parser;

/**
	Parses lines of Tibbo Basic code to determine how the syntax is highlighted.
**/
class TibboBasicLineParser extends LineParser {
	public static final BASIC_CODE:Int = 0x1;
	public static final BASIC_STRING:Int = 0x2;
	public static final BASIC_COMMENT:Int = 0x3;
	public static final BASIC_KEYWORD:Int = 0x4;
	public static final BASIC_VARIABLE_KEYWORD:Int = 0x5;
	public static final BASIC_PROCEDURE_KEYWORD:Int = 0x6;
	public static final BASIC_TYPE_KEYWORD:Int = 0x7;
	public static final BASIC_VALUE_KEYWORD:Int = 0x8;
	public static final BASIC_SIMPLE_TYPE_KEYWORD:Int = 0x9;

	/**
		Creates a new `TibboLineParser` object.
	**/
	public function new() {
		super();

		context = BASIC_CODE;
		_defaultContext = BASIC_CODE;

		wordBoundaries = ~/([\s,(){}\[\]\-+*%\/="'~!&|<>?:;.]+)/g;

		// order matters
		patterns = [
			// "
			new LineParserPattern(BASIC_STRING, ~/^"(?:\\\\|\\"|[^\n])*?(?:"|\\\n|(?=\n))/),
			// '
			new LineParserPattern(BASIC_COMMENT, ~/^'.*/),
		];

		endPatterns = [new LineParserPattern(BASIC_STRING, ~/(?:^|[^\\])("|(?=\n))/),];

		keywords = [
			BASIC_VARIABLE_KEYWORD => ['dim', 'const'],
			BASIC_PROCEDURE_KEYWORD => ['sub', 'function'],
			BASIC_TYPE_KEYWORD => ['enum', 'type'],
			BASIC_KEYWORD => [
				'and', 'as', 'byref', 'byval', 'case', 'countof', 'declare', 'do', 'doevents', 'else', 'else', 'end', 'exit', 'for', 'get', 'goto', 'if',
				'include', 'includepp', 'loop', 'mod', 'next', 'not', 'object', 'or', 'property', 'public', 'ref', 'select', 'set', 'shl', 'shr', 'sizeof',
				'step', 'syscall', 'then', 'to', 'until', 'wend', 'while', 'xor'
			],
			BASIC_SIMPLE_TYPE_KEYWORD => [
				'char', 'byte', 'short', 'integer', 'word', 'long', 'dword', 'real', 'float', 'string', 'boolean'
			],
			BASIC_VALUE_KEYWORD => ['true', 'false']
		];
		caseSensitiveKeywords = false;
	}
}
