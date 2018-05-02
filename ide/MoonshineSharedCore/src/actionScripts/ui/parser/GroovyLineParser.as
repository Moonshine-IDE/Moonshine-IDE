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
package actionScripts.ui.parser
{
	public class GroovyLineParser extends LineParser
	{
		public static const GROOVY_CODE:int =						0x1;
		public static const GROOVY_STRING1:int =					0x2;
		public static const GROOVY_STRING2:int =					0x3;
		public static const GROOVY_STRING3:int =					0x4;
		public static const GROOVY_COMMENT:int =					0x5;
		public static const GROOVY_MULTILINE_COMMENT:int =			0x6;
		public static const GROOVY_KEYWORD:int =					0xA;
		public static const GROOVY_PACKAGE_CLASS_KEYWORDS:int =		0xD;
		public static const GROOVY_ANNOTATION:int =					0xE;

		public function GroovyLineParser():void
		{
			context = GROOVY_CODE;
			defaultContext = GROOVY_CODE;
			
			wordBoundaries = /([\s,(){}\[\]\-+*%\/="'~!&|<>?:;.]+)/g;
		
			patterns = [
				[GROOVY_STRING1, 				/^\"(?:\\\\|\\\"|[^\n])*?(?:\"|\\\n|(?=\n))/			], // " 
				[GROOVY_STRING2, 				/^\'\'\'.*?(?:\'\'\'|\n)/								], // '''
				[GROOVY_STRING3, 				/^\'(?:\\\\|\\\'|[^\n])*?(?:\'|\\\n|(?=\n))/			], // '
				[GROOVY_COMMENT, 				/^\/\/.*/												], // //
				[GROOVY_MULTILINE_COMMENT, 		/^\/\*.*?(?:\*\/|\n)/									], // /*
                [GROOVY_ANNOTATION,				/^@\w+(\(((["']\w+["'])|(\[(["']\w+["'])(,\s+(["']\w+["']))+\]))\))?/	], // @Annotation()
			];
			
			endPatterns = [
				[GROOVY_STRING1,				/(?:^|[^\\])(\"|(?=\n))/		], // "
				[GROOVY_STRING2,				/\'\'\'/						], // '''
				[GROOVY_STRING3,				/(?:^|[^\\])(\'|(?=\n))/		], // '
				[GROOVY_MULTILINE_COMMENT,		/\*\//							], // */
			];
			
			keywords = [
				[GROOVY_KEYWORD,
					[
						'as',
						'assert',
						'boolean',
						'break',
						'byte',
						'case',
						'catch',
						'char',
						'const',
						'continue',
						'def',
						'default',
						'do',
						'double',
						'else',
						'enum',
						'extends',
						'false',
						'finally',
						'float',
						'for',
						'goto',
						'if',
						'implements',
						'import',
						'in',
						'int',
						'instanceof',
						'long',
						'new',
						'null',
						'private',
						'protected',
						'public',
						'return',
						'short',
						'static',
						'super',
						'switch',
						'this',
						'throw',
						'throws',
						'trait',
						'true',
						'try',
						'void',
						'while'
					]
				],
				[GROOVY_PACKAGE_CLASS_KEYWORDS, ['package', 'class', 'interface']]
			];
			
			super();
		}

	}
}