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
	public class AS3LineParser extends LineParser
	{
		public static const AS_CODE:int =					0x1;
		public static const AS_STRING1:int =				0x2;
		public static const AS_STRING2:int =				0x3;
		public static const AS_COMMENT:int =				0x4;
		public static const AS_MULTILINE_COMMENT:int =		0x5;
		public static const AS_REGULAR_EXPRESSION:int =		0x6;
		public static const AS_KEYWORD:int =				0xA;
		public static const AS_VAR_KEYWORD:int =			0xB;
		public static const AS_FUNCTION_KEYWORD:int =		0xC;
		public static const AS_PACKAGE_CLASS_KEYWORDS:int =	0xD;
		
		public function AS3LineParser():void
		{
			context = AS_CODE;
			defaultContext = AS_CODE;
			
			wordBoundaries = /([\s,(){}\[\]\-+*%\/="'~!&|<>?:;.]+)/g;
		
			// TODO: Add patterns for multiline strings
			patterns = [
				[AS_STRING1, 			/^\"(?:\\\\|\\\"|[^\n])*?(?:\"|\\\n|(?=\n))/		], //" 
				[AS_STRING2, 			/^\'(?:\\\\|\\\'|[^\n])*?(?:\'|\\\n|(?=\n))/		],
				[AS_COMMENT, 			/^\/\/.*/									],
				[AS_MULTILINE_COMMENT, 	/^\/\*.*?(?:\*\/|\n)/						],
				[AS_REGULAR_EXPRESSION,	/^\/(?:\\\\|\\\/|\[(?:\\\\|\\\]|.)+?\]|[^*\/])(?:\\\\|\\\/|\[(?:\\\\|\\\]|.)+?\]|.)*?\/[gismx]*/	]
			];
			
			endPatterns = [
				[AS_STRING1,			/(?:^|[^\\])(\"|(?=\n))/					],
				[AS_STRING2,			/(?:^|[^\\])(\'|(?=\n))/					],
				[AS_MULTILINE_COMMENT,	/\*\//										]
			];
			
			keywords = [
				[AS_KEYWORD,
					['is', 'if', 'in', 'as', 'new', 'for', 'use', 'set', 'get', 'try', 
					'null', 'true', 'void', 'else', 'each', 'case', 'this', 'break', 'false', 
					'const', 'catch', 'class', 'return', 'switch', 'static', 
					'import', 'private', 'public', 'extends', 'override', 'inherits', 
					'internal', 'implements', 'package', 'protected', 'namespace']
				],
				[AS_VAR_KEYWORD, ['var']],
				[AS_FUNCTION_KEYWORD, ['function']],
				[AS_PACKAGE_CLASS_KEYWORDS, ['package', 'class', 'interface']]
			];
			
			super();
		}

	}
}