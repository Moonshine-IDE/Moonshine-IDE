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
	public class JavaLineParser extends LineParser
	{
		public static const JAVA_CODE:int =						0x1;
		public static const JAVA_STRING1:int =					0x2;
		public static const JAVA_STRING2:int =					0x3;
		public static const JAVA_COMMENT:int =					0x4;
		public static const JAVA_MULTILINE_COMMENT:int =		0x5;
		public static const JAVA_KEYWORD:int =					0xA;
		public static const JAVA_PACKAGE_CLASS_KEYWORDS:int =	0xD;
		public static const JAVA_ANNOTATION:int =				0xE;

		public function JavaLineParser():void
		{
			context = JAVA_CODE;
			defaultContext = JAVA_CODE;
			
			wordBoundaries = /([\s,(){}\[\]\-+*%\/="'~!&|<>?:;.]+)/g;
		
			patterns = [
				[JAVA_STRING1, 				/^\"(?:\\\\|\\\"|[^\n])*?(?:\"|\\\n|(?=\n))/		], // " 
				[JAVA_STRING2, 				/^\'(?:\\\\|\\\'|[^\n])*?(?:\'|\\\n|(?=\n))/		], // '
				[JAVA_COMMENT, 				/^\/\/.*/											], // //
				[JAVA_MULTILINE_COMMENT, 	/^\/\*.*?(?:\*\/|\n)/								], // /*
                [JAVA_ANNOTATION,			/^@\w+(\(((["']\w+["'])|({(["']\w+["'])(,\s+(["']\w+["']))+}))\))?/	],
			];
			
			endPatterns = [
				[JAVA_STRING1,				/(?:^|[^\\])(\"|(?=\n))/	], // "
				[JAVA_STRING2,				/(?:^|[^\\])(\'|(?=\n))/	], // '
				[JAVA_MULTILINE_COMMENT,	/\*\//						], // */
			];
			
			keywords = [
				[JAVA_KEYWORD,
					[
						'abstract',
						'continue',
						'for',
						'new',
						'switch',
						'assert',
						'default',
						'goto',
						'synchronized',
						'boolean',
						'do',
						'if',
						'private',
						'this',
						'break',
						'double',
						'implements',
						'protected',
						'throw',
						'byte',
						'else',
						'import',
						'public',
						'throws',
						'case',
						'enum',
						'instanceof',
						'return',
						'transient',
						'catch',
						'extends',
						'int',
						'short',
						'try',
						'char',
						'final',
						'static',
						'void',
						'finally',
						'long',
						'strictfp',
						'volatile',
						'const',
						'float',
						'native',
						'super',
						'while'
					]
				],
				[JAVA_PACKAGE_CLASS_KEYWORDS, ['package', 'class', 'interface']]
			];
			
			super();
		}

	}
}