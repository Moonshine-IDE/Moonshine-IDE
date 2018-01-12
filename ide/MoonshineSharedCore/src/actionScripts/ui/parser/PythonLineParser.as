////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.ui.parser
{
    public class PythonLineParser extends LineParser
    {
        public static const PY_CODE:int =					0x1;
        public static const PY_STRING1:int =				0x2;
        public static const PY_STRING2:int =				0x3;
        public static const PY_COMMENT:int =				0x4;
        public static const PY_MULTILINE_COMMENT:int =		0x5;
        public static const PY_KEYWORD:int =				0x6;
        public static const PY_FUNCTION_KEYWORD:int =		0xA;
        public static const PY_PACKAGE_CLASS_KEYWORDS:int =	0xB;

        public function PythonLineParser():void
        {
            context = PY_CODE;
            defaultContext = PY_CODE;

            wordBoundaries = /([\s,(){}\[\]\-+*%\/="'~!&|<>?:;.]+)/g;

            patterns = [
                [PY_MULTILINE_COMMENT, 	/^""".*?(?:"""|\n)/						],
                [PY_STRING1, 			/^\"(?:\\\\|\\\"|[^\n])*?(?:\"|\\\n|(?=\n))/	],
                [PY_STRING2, 			/^\'(?:\\\\|\\\'|[^\n])*?(?:\'|\\\n|(?=\n))/	],
                [PY_COMMENT, 			/^#.*/											]
            ];

            endPatterns = [
                [PY_STRING1,			/(?:^|[^\\])(\"|(?=\n))/	],
                [PY_STRING2,			/(?:^|[^\\])(\'|(?=\n))/	],
                [PY_MULTILINE_COMMENT,	/"""/						]
            ];

            keywords = [
                [PY_KEYWORD,
                    ['and', 'del', 'for', 'is', 'raise', 'assert', 'elif', 'from',
                        'lambda', 'return', 'break', 'else', 'global', 'not', 'try',
                        'except', 'if', 'or', 'while', 'continue', 'exec',
                        'import', 'pass', 'yield', 'finally', 'in', 'print']
                ],
                [PY_FUNCTION_KEYWORD, ['def']],
                [PY_PACKAGE_CLASS_KEYWORDS, ['class']]
            ];

            super();
        }
    }
}
