/*
Moonshine changes
-------
- Added Github-flavored markdown code blocks
- Added ...rest:Array to escapeCharacters_callback() params

Actiondown
-------
Copyright © 2010 Ben Beaumont
http://www.dogcatfishdish.com/
https://github.com/bbeaumont/Actiondown


Original license
-------

Copyright © 2004, John Gruber
http://daringfireball.net/
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.
Neither the name "Markdown" nor the names of its contributors may
be used to endorse or promote products derived from this software
without specific prior written permission.


This software is provided by the copyright holders and contributors "as
is" and any express or implied warranties, including, but not limited
to, the implied warranties of merchantability and fitness for a
particular purpose are disclaimed. In no event shall the copyright owner
or contributors be liable for any direct, indirect, incidental, special,
exemplary, or consequential damages (including, but not limited to,
procurement of substitute goods or services; loss of use, data, or
profits; or business interruption) however caused and on any theory of
liability, whether in contract, strict liability, or tort (including
negligence or otherwise) arising in any way out of the use of this
software, even if advised of the possibility of such damage.
*/

package com.dogcatfishdish.markdown 
{
	
	public class Markdown 
	{
		private static var g_urls:Array = [];
		private static var g_titles:Array = [];
		private static var g_html_blocks:Array = [];
		private static var g_list_level:int = 0;
		private static var g_gh_code_blocks:Array = [];
		
		public static function MakeHtml(text:String):String 
		{
			if(!text)
			{
				return text;
			}
			g_urls = [];
			g_titles = [];
			g_html_blocks = [];
			g_gh_code_blocks = [];
			
			text = text.replace(/~/g,"~T");
			text = text.replace(/\$/g,"~D");
			text = text.replace(/\r\n/g,"\n");
			text = text.replace(/\r/g,"\n");
			text = "\n\n" + text + "\n\n";
			text = _Detab(text);
			text = text.replace(/^[ \t]+$/mg,"");
			text = _HashHTMLBlocks(text);
			text = _StripLinkDefinitions(text);			
			text = _RunBlockGamut(text);		
			text = _UnescapeSpecialChars(text);
			text = text.replace(/~D/g,"$$");
			text = text.replace(/~T/g,"~");
			
			return text;
		}
		
		private static function _StripLinkDefinitions(text:String):String 
		{
			text = text.replace(/^[ ]{0,3}\[(.+)\]:[ \t]*\n?[ \t]*<?(\S+?)>?[ \t]*\n?[ \t]*(?:(\n*)["(](.+?)[")][ \t]*)?(?:\n+|\Z)/gm,
				function (wholeMatch:String, m1:String, m2:String, m3:String, m4:String, ...rest:Array):String 
				{
					m1 = m1.toLowerCase();
					g_urls[m1] = _EncodeAmpsAndAngles(m2);  // Link IDs are case-insensitive
					if (m3) 
					{
						return m3 + m4;
					} 
					else if (m4) 
					{
						g_titles[m1] = m4.replace(/"/g, "&quot;");
					}

					return "";
				}
			);
			
			return text;
		}
		
		private static function _HashHTMLBlocks(text:String):String 
		{

			text = text.replace(/\n/g,"\n\n");

			var block_tags_a:String = "p|div|h[1-6]|blockquote|pre|table|dl|ol|ul|script|noscript|form|fieldset|iframe|math|ins|del"
			var block_tags_b:String = "p|div|h[1-6]|blockquote|pre|table|dl|ol|ul|script|noscript|form|fieldset|iframe|math"

			text = text.replace(/^(<(p|div|h[1-6]|blockquote|pre|table|dl|ol|ul|script|noscript|form|fieldset|iframe|math|ins|del)\b[^\r]*?\n<\/\2>[ \t]*(?=\n+))/gm, hashElement);
			text = text.replace(/^(<(p|div|h[1-6]|blockquote|pre|table|dl|ol|ul|script|noscript|form|fieldset|iframe|math)\b[^\r]*?.*<\/\2>[ \t]*(?=\n+)\n)/gm, hashElement);
			text = text.replace(/(\n[ ]{0,3}(<(hr)\b([^<>])*?\/?>)[ \t]*(?=\n{2,}))/g, hashElement);
			text = text.replace(/(\n\n[ ]{0,3}<!(--[^\r]*?--\s*)+>[ \t]*(?=\n{2,}))/g, hashElement);
			text = text.replace(/(?:\n\n)([ ]{0,3}(?:<([?%])[^\r]*?\2>)[ \t]*(?=\n{2,}))/g, hashElement);
			text = text.replace(/\n\n/g,"\n");
			return text;
		}
		
		private static function _RunBlockGamut(text:String):String 
		{
			text = _DoHeaders(text);

			var key:String = hashBlock("<hr />");
			text = text.replace(/^[ ]{0,2}([ ]?\*[ ]?){3,}[ \t]*$/gm, key);
			text = text.replace(/^[ ]{0,2}([ ]?\-[ ]?){3,}[ \t]*$/gm, key);
			text = text.replace(/^[ ]{0,2}([ ]?\_[ ]?){3,}[ \t]*$/gm, key);	
			text = _DoLists(text);
			text = _DoGithubCodeBlocks(text);
			text = _DoCodeBlocks(text);
			text = _DoBlockQuotes(text);
			text = _HashHTMLBlocks(text);
			text = _FormParagraphs(text);
			
			return text;
		}
		
		private static function _RunSpanGamut(text:String):String 
		{
			text = _DoCodeSpans(text);
			text = _EscapeSpecialCharsWithinTagAttributes(text);
			text = _EncodeBackslashEscapes(text);
			text = _DoImages(text);
			text = _DoAnchors(text);
			text = _DoAutoLinks(text);
			text = _EncodeAmpsAndAngles(text);
			text = _DoItalicsAndBold(text);
			text = text.replace(/  +\n/g," <br />\n");
			
			return text;
		}
		
		private static function _EscapeSpecialCharsWithinTagAttributes(text:String):String 
		{
			text = text.replace(/(<[a-z\/!$]("[^"]*"|'[^']*'|[^'">])*>|<!(--.*?--\s*)+>)/gi, 
				function(wholeMatch:String, ...rest:Array):String 
				{
					var tag:String = wholeMatch.replace(/(.)<\/?code>(?=.)/g,"$1`");
					tag = escapeCharacters(tag,"\\`*_");
					return tag;
				}
			);
			
			return text;
		}
		
		private static function _DoAnchors(text:String):String 
		{
			text = text.replace(/(\[((?:\[[^\]]*\]|[^\[\]])*)\][ ]?(?:\n[ ]*)?\[(.*?)\])()()()()/g, writeAnchorTag);
			text = text.replace(/(\[((?:\[[^\]]*\]|[^\[\]])*)\]\([ \t]*()<?(.*?)>?[ \t]*((['"])(.*?)\6[ \t]*)?\))/g, writeAnchorTag);
			text = text.replace(/(\[([^\[\]]+)\])()()()()()/g, writeAnchorTag);
			
			return text;
		}
		
		private static function _DoImages(text:String):String 
		{
			text = text.replace(/(!\[(.*?)\][ ]?(?:\n[ ]*)?\[(.*?)\])()()()()/g, writeImageTag);
			text = text.replace(/(!\[(.*?)\]\s?\([ \t]*()<?(\S+?)>?[ \t]*((['"])(.*?)\6[ \t]*)?\))/g, writeImageTag);
			
			return text;
		}
		
		private static function _DoHeaders(text:String):String 
		{
			text = text.replace(/^(.+)[ \t]*\n=+[ \t]*\n+/gm,
				function(wholeMatch:String, m1:String, ...rest:Array):String
				{
					return hashBlock("<h1>" + _RunSpanGamut(m1) + "</h1>");
				}
			);
			
			text = text.replace(/^(.+)[ \t]*\n-+[ \t]*\n+/gm,
				function(matchFound:String, m1:String, ...rest:Array):String
				{
					return hashBlock("<h2>" + _RunSpanGamut(m1) + "</h2>");
				}
			);

			text = text.replace(/^(\#{1,6})[ \t]*(.+?)[ \t]*\#*\n+/gm,
				function(wholeMatch:String, m1:String, m2:String, ...rest:Array):String 
				{
					var h_level:uint = m1.length;
					return hashBlock("<h" + h_level + ">" + _RunSpanGamut(m2) + "</h" + h_level + ">");
				}
			);
			
			return text;
		}
		
		private static function _DoLists(text:String):String 
		{
			var whole_list:RegExp = /^(([ ]{0,3}([*+-]|\d+[.])[ \t]+)[^\r]+?(~0|\n{2,}(?=\S)(?![ \t]*(?:[*+-]|\d+[.])[ \t]+)))/g;
			
			if (g_list_level > 0) {

				text = text.replace(whole_list, 
					function(wholeMatch:String, m1:String, m2:String, ...rest:Array):String 
					{
						var list:String = m1;
						var list_type:String = (m2.search(/[*+-]/g)>-1) ? "ul" : "ol";
						list = list.replace(/\n{2,}/g,"\n\n\n");
						var result:String = _ProcessListItems(list);
						result = result.replace(/\s+$/,"");
						result = "<"+list_type+">" + result + "</"+list_type+">\n";
						return result;
					}
				);
			} 
			else 
			{
				whole_list = /(\n\n|^\n?)(([ ]{0,3}([*+-]|\d+[.])[ \t]+)[^\r]+?(~0|\n{2,}(?=\S)(?![ \t]*(?:[*+-]|\d+[.])[ \t]+)))/g;
				text = text.replace(whole_list,
					function(wholeMatch:String, m1:String, m2:String, m3:String, ...rest:Array):String 
					{
						var runup:String = m1;
						var list:String = m2;
						
						var list_type:String = (m3.search(/[*+-]/g)>-1) ? "ul" : "ol";
	
						list = list.replace(/\n{2,}/g,"\n\n\n");
						var result:String = _ProcessListItems(list);
	
						result = runup + "<"+list_type+">\n" + result + "</"+list_type+">\n";	
						return result;
					}
				);

			}

			text = text.replace(/~0/,"");
			
			return text;
		}

		private static function _ProcessListItems(list_str:String):String 
		{	
			g_list_level++;

			list_str = list_str.replace(/\n{2,}$/,"\n");
			list_str += "~0";
			list_str = list_str.replace(/(\n)?(^[ \t]*)([*+-]|\d+[.])[ \t]+([^\r]+?(\n{1,2}))(?=\n*(~0|\2([*+-]|\d+[.])[ \t]+))/gm,
				function(wholeMatch:String, m1:String, m2:String, m3:String, m4:String, ...rest:Array):String 
				{
					var item:String = m4;
					var leading_line:String = m1;
					var leading_space:String = m2;
					
					if (leading_line || (item.search(/\n{2,}/)>-1)) 
					{
						item = _RunBlockGamut(_Outdent(item));
					}
					else 
					{
						item = _DoLists(_Outdent(item));
						item = item.replace(/\n$/,"");
						item = _RunSpanGamut(item);
					}
					
					return  "<li>" + item + "</li>\n";
				}
			);

			list_str = list_str.replace(/~0/g,"");
			
			g_list_level--;
			
			return list_str;
		}

		private static function _DoGithubCodeBlocks(text:String):String
		{
			text += "~0";
			text = text.replace(/(?:^|\n)(?: {0,3})(```+|~~~+)(?: *)([^\s`~]*)\n([\s\S]*?)\n(?: {0,3})\1/g,
				function (wholeMatch:String, delim:String, language:String, codeblock:String, ...rest:Array):String {

					codeblock = _EncodeCode( _Outdent(codeblock));
					codeblock = _Detab(codeblock);
					codeblock = codeblock.replace(/^\n+/g,""); // trim leading newlines
					codeblock = codeblock.replace(/\n+$/g,""); // trim trailing whitespace

					codeblock = "<pre><code" + (language ? " class=\"" + language + " language-" + language + "\"" : "") + ">" + codeblock + "</code></pre>";

					codeblock = hashBlock(codeblock);

					// Since GHCodeblocks can be false positives, we need to
					// store the primitive text and the parsed text in a global var,
					// and then return a token
					return '\n\n~G' + (g_gh_code_blocks.push({text: wholeMatch, codeblock: codeblock}) - 1) + 'G\n\n';
				});

			text = text.replace(/~0/,"");
			
			return text;
		}
			
		private static function _DoCodeBlocks(text:String):String 
		{
			text += "~0";
			text = text.replace(/(?:\n\n|^)((?:(?:[ ]{4}|\t).*\n+)+)(\n*[ ]{0,3}[^ \t\n]|(?=~0))/g,
				function(wholeMatch:String, m1:String, m2:String, ...rest:Array):String 
				{
					var codeblock:String = m1;
					var nextChar:String = m2;
					
					codeblock = _EncodeCode( _Outdent(codeblock));
					codeblock = _Detab(codeblock);
					codeblock = codeblock.replace(/^\n+/g,""); // trim leading newlines
					codeblock = codeblock.replace(/\n+$/g,""); // trim trailing whitespace
					
					codeblock = "<pre><code>" + codeblock + "\n</code></pre>";
					
					return hashBlock(codeblock) + nextChar;
				}
			);

			text = text.replace(/~0/,"");
			
			return text;
		}
		
		private static function _DoCodeSpans(text:String):String 
		{
			text = text.replace(/(^|[^\\])(`+)([^\r]*?[^`])\2(?!`)/gm,
				function(wholeMatch:String, m1:String, m2:String, m3:String, m4:String, ...rest:Array):String 
				{
					var c:String = m3;
					c = c.replace(/^([ \t]*)/g,"");	// leading whitespace
					c = c.replace(/[ \t]*$/g,"");	// trailing whitespace
					c = _EncodeCode(c);
					return m1 + "<code>" + c + "</code>";
				}
			);
			
			return text;
		}
		
		private static function _EncodeCode(text:String):String 
		{
			text = text.replace(/&/g,"&amp;");
			text = text.replace(/</g,"&lt;");
			text = text.replace(/>/g,"&gt;");
			text = escapeCharacters(text,"\*_{}[]\\", false);
			
			return text;
		}
		
		private static function _DoItalicsAndBold(text:String):String 
		{
			text = text.replace(/(\*\*|__)(?=\S)([^\r]*?\S[*_]*)\1/g, "<strong>$2</strong>");
			
			text = text.replace(/(\*|_)(?=\S)([^\r]*?\S)\1/g, "<em>$2</em>");
			
			return text;
		}
		
		private static function _DoBlockQuotes(text:String):String 
		{
			text = text.replace(/((^[ \t]*>[ \t]?.+\n(.+\n)*\n*)+)/gm,
				function(wholeMatch:String, m1:String, ...rest:Array):String
				{
					var bq:String = m1;
					bq = bq.replace(/^[ \t]*>[ \t]?/gm,"~0");	// trim one level of quoting
					bq = bq.replace(/~0/g,"");
					bq = bq.replace(/^[ \t]+$/gm,"");
					bq = _RunBlockGamut(bq);	
					bq = bq.replace(/(^|\n)/g,"$1  ");
					bq = bq.replace(
						/(\s*<pre>[^\r]+?<\/pre>)/gm,
						function(wholeMatch:String, m1:String, ...rest:Array):String 
						{
							var pre:String = m1;
							// attacklab: hack around Konqueror 3.5.4 bug:
							pre = pre.replace(/^  /mg,"~0");
							pre = pre.replace(/~0/g,"");
							return pre;
						}
					);
					
					return hashBlock("<blockquote>\n" + bq + "\n</blockquote>");
				}
			);
			return text;			
		}

		
		private static function _FormParagraphs(text:String):String 
		{
			text = text.replace(/^\n+/g,"");
			text = text.replace(/\n+$/g,"");
			
			var grafs:Array = text.split(/\n{2,}/g);
			var grafsOut:Array = [ ];
			
			var end:int = grafs.length;
			for (var i:int = 0; i < end; i++) 
			{
				var str:String = grafs[i];

				if (str.search(/~(K|G)(\d+)\1/g) >= 0) 
				{
					grafsOut.push(str);
				}
				else if (str.search(/\S/) >= 0) 
				{
					str = _RunSpanGamut(str);
					str = str.replace(/^([ \t]*)/g,"<p>");
					str += "</p>"
					grafsOut.push(str);
				}	
			}

			end = grafsOut.length;
			for (i = 0; i < end; i++) 
			{
				var reg:RegExp = /~(K|G)(\d+)\1/g;
				var res:Object = reg.exec(grafsOut[i]);
				var codeFlag:Boolean = false;
				var blockText:String = "";
				
				while(res != null) {
					var delim:String = res[1];
					var num:int = int(res[2]);
					if(delim == "K")
					{
						blockText = g_html_blocks[num];
					}
					else
					{
						if(codeFlag)
						{
							blockText = _EncodeCode(g_gh_code_blocks[num].text);
						}
						else
						{
							blockText = g_gh_code_blocks[num].codeblock;
						}
					}
					blockText = blockText.replace(/\$/g,"$$$$"); // Escape any dollar signs
					grafsOut[i] = grafsOut[i].replace(/~(K|G)\d+\1/, blockText);
					// Check if grafsOut[i] is a pre->code
					if (/^<pre\b[^>]*>\s*<code\b[^>]*>/.test(grafsOut[i])) {
						codeFlag = true;
					}
					//create a new object so that the state is reset
					reg = /~(K|G)(\d+)\1/g;
					res = reg.exec(grafsOut[i]);
					
				}	
			}
			
			return grafsOut.join("\n\n");
		}
		
		private static function _EncodeAmpsAndAngles(text:String):String 
		{
			text = text.replace(/&(?!#?[xX]?(?:[0-9a-fA-F]+|\w+);)/g,"&amp;");
			text = text.replace(/<(?![a-z\/?\$!])/gi,"&lt;");
			
			return text;
		}
		
		private static function _EncodeBackslashEscapes(text:String):String 
		{
			text = text.replace(/\\(\\)/g, escapeCharacters_callback);
			text = text.replace(/\\([`*_{}\[\]()>#+-.!])/g, escapeCharacters_callback);
			
			return text;
		}
		
		private static function _DoAutoLinks(text:String):String {
			
			text = text.replace(/<((https?|ftp|dict):[^'">\s]+)>/gi,"<a href=\"$1\">$1</a>");
			text = text.replace(/<(?:mailto:)?([-.\w]+\@[-a-z0-9]+(\.[-a-z0-9]+)*\.[a-z]+)>/gi,
				function(wholeMatch:String, m1:String, ...rest:Array):String 
				{
					return _EncodeEmailAddress( _UnescapeSpecialChars(m1) );
				}
			);
			
			return text;
		}
		
		private static function _EncodeEmailAddress(text:String):String 
		{
			function char2hex(ch:String):String 
			{
				var hexDigits:String = '0123456789ABCDEF';
				var dec:Number = ch.charCodeAt(0);
				return(hexDigits.charAt(dec>>4) + hexDigits.charAt(dec&15));
			}
			
			var encode:Array = [
				function(ch:String):String {return "&#"+ch.charCodeAt(0)+";";},
				function(ch:String):String {return "&#x"+char2hex(ch)+";";},
				function(ch:String):String {return ch;}
			];
			
			var addr:String = "mailto:" + addr;
			
			addr = addr.replace(/./g, 
				function(ch:String, ...rest:Array):String 
				{
					if (ch == "@") 
					{
						ch = encode[Math.floor(Math.random()*2)](ch);
					} 
					else if (ch !=":") 
					{
						var r:Number = Math.random();
						ch =  (
							r > .9  ?	encode[2](ch)   :
							r > .45 ?	encode[1](ch)   :
							encode[0](ch)
						);
					}
					return ch;
				}
			);
			
			addr = "<a href=\"" + addr + "\">" + addr + "</a>";
			addr = addr.replace(/">.+:/g,"\">");
			
			return addr;
		}
		
		private static function _UnescapeSpecialChars(text:String):String 
		{
			text = text.replace(/~E(\d+)E/g,
				function(wholeMatch:String, m1:String, ...rest:Array):String 
				{
					var charCodeToReplace:int = parseInt(m1);
					return String.fromCharCode(charCodeToReplace);
				}
			);
			return text;
		}
		
		private static function _Outdent(text:String):String 
		{
			text = text.replace(/^(\t|[ ]{1,4})/gm,"~0");
			text = text.replace(/~0/g,"")
			
			return text;
		}
		
		private static function _Detab(text:String):String 
		{
			text = text.replace(/\t(?=\t)/g,"    ");
			text = text.replace(/\t/g,"~A~B");
			text = text.replace(/~B(.+?)~A/g,
				function(wholeMatch:String, m1:String, m2:String, ...rest:Array):String 
				{
					var leadingText:String = m1;
					var numSpaces:int = 4 - leadingText.length % 4;
					
					for (var i:int = 0; i < numSpaces; i++) 
					{
						leadingText += " ";	
					}
					
					return leadingText;
				}
			);

			text = text.replace(/~A/g,"    ");
			text = text.replace(/~B/g,"");
			
			return text;
		}

		private static function hashElement(wholeMatch:String, m1:String, ...rest:Array):String 
		{
			var blockText:String = m1;
			blockText = blockText.replace(/\n\n/g,"\n");
			blockText = blockText.replace(/^\n/,"");
			blockText = blockText.replace(/\n+$/g,"");
			blockText = "\n\n~K" + (g_html_blocks.push(blockText) - 1) + "K\n\n";
			
			return blockText;
		}
		
		private static function writeAnchorTag(wholeMatch:String, m1:String, m2:String, m3:String, m4:String, m5:String, m6:String, m7:String = '', ...rest:Array):String 
		{
			var whole_match:String = m1;
			var link_text:String   = m2;
			var link_id:String = m3.toLowerCase();
			var url:String = m4;
			var title:String = m7;
			
			if (url == "") {
				if (link_id == "") {
					link_id = link_text.toLowerCase().replace(/ ?\n/g," ");
				}
				url = "#" + link_id;
				
				if (g_urls[link_id] != undefined) {
					url = g_urls[link_id];
					if (g_titles[link_id] != undefined) {
						title = g_titles[link_id];
					}
				}
				else {
					if (whole_match.search(/\(\s*\)$/m)>-1) {
						url = "";
					} else {
						return whole_match;
					}
				}
			}	
			
			url = escapeCharacters(url,"*_");
			var result:String = "<a href=\"" + url + "\"";
			
			if (title != "") {
				title = title.replace(/"/g,"&quot;");
				title = escapeCharacters(title,"*_");
				result +=  " title=\"" + title + "\"";
			}
			
			result += ">" + link_text + "</a>";
			
			return result;
		}
		
		private static function writeImageTag(wholeMatch:String, m1:String, m2:String, m3:String, m4:String, m5:String, m6:String, m7:String = '', ...rest:Array):String 
		{
			var whole_match:String = m1;
			var alt_text:String = m2;
			var link_id:String = m3.toLowerCase();
			var url:String = m4;
			var title:String = m7;
			
			if (url == "") 
			{
				if (link_id == "") 
				{
					link_id = alt_text.toLowerCase().replace(/ ?\n/g," ");
				}
				url = "#"+link_id;
				
				if (g_urls[link_id] != undefined) 
				{
					url = g_urls[link_id];
					if (g_titles[link_id] != undefined) 
					{
						title = g_titles[link_id];
					}
				}
				else 
				{
					return whole_match;
				}
			}	
			
			alt_text = alt_text.replace(/"/g,"&quot;");
			url = escapeCharacters(url,"*_");
			
			var result:String = "<img src=\"" + url + "\" alt=\"" + alt_text + "\"";
			
			title = title.replace(/"/g,"&quot;");
			title = escapeCharacters(title,"*_");
			result +=  " title=\"" + title + "\"";
			
			result += " />";
			
			return result;
		}
		
		private static function hashBlock(text:String):String 
		{
			text = text.replace(/(^\n+|\n+$)/g,"");
			return "\n\n~K" + (g_html_blocks.push(text)-1) + "K\n\n";
		}
		
		private static function escapeCharacters(text:String, charsToEscape:String, afterBackslash:Boolean = false):String 
		{
			var regexString:String = "([" + charsToEscape.replace(/([\[\]\\])/g,"\\$1") + "])";
			
			if (afterBackslash) 
			{
				regexString = "\\\\" + regexString;
			}
			
			var regex:RegExp = new RegExp(regexString,"g");
			text = text.replace(regex,escapeCharacters_callback);
			
			return text;
		}
		
		private static function escapeCharacters_callback(wholeMatch:String, m1:String, ...rest:Array):String 
		{
			var charCodeToEscape:Number = m1.charCodeAt(0);
			return "~E" + charCodeToEscape + "E";
		}
	}
}