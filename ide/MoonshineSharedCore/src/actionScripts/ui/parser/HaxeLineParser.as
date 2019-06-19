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
	public class HaxeLineParser extends LineParser
	{
		public static const HX_CODE:int =					0x1;
		public static const HX_STRING1:int =				0x2;
		public static const HX_STRING2:int =				0x3;
		public static const HX_COMMENT:int =				0x4;
		public static const HX_MULTILINE_COMMENT:int =		0x5;
		public static const HX_REGULAR_EXPRESSION:int =		0x6;
		public static const HX_KEYWORD:int =				0xA;
		public static const HX_VAR_KEYWORD:int =			0xB;
		public static const HX_FUNCTION_KEYWORD:int =		0xC;
		public static const HX_PACKAGE_CLASS_KEYWORDS:int =	0xD;
		public static const HX_METADATA:int               = 0xE;
		public static const HX_FIELD:int 	              = 0xF;
		public static const HX_FUNCTIONS:int              = 0x11;

		public function HaxeLineParser():void
		{
			context = HX_CODE;
			defaultContext = HX_CODE;
			
			wordBoundaries = /([\s,(){}\[\]\-+*%\/="'~!&|<>?:;.]+)/g;
		
			// TODO: Add patterns for multiline strings
			patterns = [
				[HX_STRING1, 			/^\"(?:\\\\|\\\"|[^\n])*?(?:\"|\\\n|(?=\n))/		], //" 
				[HX_STRING2, 			/^\'(?:\\\\|\\\'|[^\n])*?(?:\'|\\\n|(?=\n))/		],
				[HX_COMMENT, 			/^\/\/.*/									],
				[HX_MULTILINE_COMMENT, 	/^\/\*.*?(?:\*\/|\n)/						],
				[HX_REGULAR_EXPRESSION,	/^\/(?:\\\\|\\\/|\[(?:\\\\|\\\]|.)+?\]|[^*\/])(?:\\\\|\\\/|\[(?:\\\\|\\\]|.)+?\]|.)*?\/[gismx]*/	],
                [HX_METADATA, /^\[(?:(Bindable|Event|Exclude|Style|ResourceBundle|IconFile|DefaultProperty|Inspectable|SkinState|Effect|SkinPart)(?:\([^\)]*\))?)\]/],
				[HX_FIELD, /^\s+\w+(?=:\w+(\s*=\s*[^;]+)?;)/],
				[HX_FUNCTIONS, /^\s+\w+(?=\((\s*|.+)\):([^:]+)$)/]
			];
			
			endPatterns = [
				[HX_STRING1,			/(?:^|[^\\])(\"|(?=\n))/					],
				[HX_STRING2,			/(?:^|[^\\])(\'|(?=\n))/					],
				[HX_MULTILINE_COMMENT,	/\*\//										]
			];
			
			keywords = [
				[HX_KEYWORD,
					['abstract', 'break', 'case', 'cast', 'catch', 'continue',
					'default', 'do', 'dynamic', 'else', 'extends', 'extern',
					'false', 'for', 'if', 'implements', 'import', 'in',
					'inline', 'macro', 'new', 'null', 'override', 'private',
					'public', 'return', 'static', 'switch', 'this', 'throw',
					'true', 'try', 'typedef', 'untyped', 'using', 'while']
				],
				[HX_VAR_KEYWORD, ['var']],
				[HX_FUNCTION_KEYWORD, ['function']],
				[HX_PACKAGE_CLASS_KEYWORDS, ['package', 'class', 'interface', 'enum']]
			];
			
			super();
		}

	}
}