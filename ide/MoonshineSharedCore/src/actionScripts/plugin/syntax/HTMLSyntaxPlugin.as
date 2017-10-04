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
package actionScripts.plugin.syntax
{
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	
	import actionScripts.events.EditorPluginEvent;
	import actionScripts.plugin.IEditorPlugin;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.settings.ISettingsProvider;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.ui.parser.AS3LineParser;
	import actionScripts.ui.parser.CSSLineParser;
	import actionScripts.ui.parser.XMLLineParser;
	import actionScripts.ui.parser.context.ContextSwitch;
	import actionScripts.ui.parser.context.InlineParser;
	import actionScripts.ui.parser.context.InlineParserManager;
	import actionScripts.valueObjects.Settings;
	
	public class HTMLSyntaxPlugin extends PluginBase implements  ISettingsProvider, IEditorPlugin
	{
		private static const SCRIPT_MASK:int =		0x1000;
		private static const SCRIPT_OPEN_TAG:int =	0x11;
		private static const SCRIPT_CLOSE_TAG:int =	0x12;
		
		private static const STYLE_MASK:int =		0x2000;
		private static const STYLE_OPEN_TAG:int =	0x21;
		private static const STYLE_CLOSE_TAG:int =	0x22;
		
		private var formats:Object = {};
		
		override public function get name():String 			{return "HTML Syntax Plugin";}
		override public function get author():String 		{return "Moonshine Project Team";}
		override public function get description():String 	{return "Provides highlighting for HTML.";}
		public function getSettingsList():Vector.<ISetting>		{return new Vector.<ISetting>();}
		
		
		override public function activate():void
		{ 
			super.activate();
			init();
		}
		override public function deactivate():void
		{
			super.deactivate();
		}
			
		public function HTMLSyntaxPlugin()
		{
			
		}
		
		private function init():void
		{
			var fontDescription:FontDescription = Settings.font.defaultFontDescription;
			var fontSize:Number = Settings.font.defaultFontSize;
			
			formats['lineNumber'] =								new ElementFormat(fontDescription, fontSize, 0x888888);
			formats['breakPointLineNumber'] =					new ElementFormat(fontDescription, fontSize, 0xffffff);
			formats['breakPointBackground'] =					0xdea5dd;
			formats['tracingLineColor']=						0xc6dbae;
			
			formats[XMLLineParser.XML_TEXT] =					new ElementFormat(fontDescription, fontSize, 0x101010);
			formats[XMLLineParser.XML_TAG] =
			formats[SCRIPT_OPEN_TAG] =
			formats[SCRIPT_CLOSE_TAG] =
			formats[STYLE_OPEN_TAG] =
			formats[STYLE_CLOSE_TAG] =							new ElementFormat(fontDescription, fontSize, 0x003DF5);
			formats[XMLLineParser.XML_COMMENT] =				new ElementFormat(fontDescription, fontSize, 0x39c02f);
			formats[XMLLineParser.XML_CDATA] =					new ElementFormat(fontDescription, fontSize, 0x606060);
			formats[XMLLineParser.XML_ATTR_NAME] =				new ElementFormat(fontDescription, fontSize, 0x101010);
			formats[XMLLineParser.XML_ATTR_VAL1] =
			formats[XMLLineParser.XML_ATTR_VAL2] =				new ElementFormat(fontDescription, fontSize, 0xca2323);
			formats[XMLLineParser.XML_ATTR_OPER] =
			formats[XMLLineParser.XML_BACKETOPEN] =
			formats[XMLLineParser.XML_BACKETCLOSE] =			new ElementFormat(fontDescription, fontSize, 0x000a94);
			
			formats[SCRIPT_MASK | AS3LineParser.AS_CODE] =						new ElementFormat(fontDescription, fontSize, 0x101010);
			formats[SCRIPT_MASK | AS3LineParser.AS_STRING1] = 				
			formats[SCRIPT_MASK | AS3LineParser.AS_STRING2] = 					new ElementFormat(fontDescription, fontSize, 0xca2323);
			formats[SCRIPT_MASK | AS3LineParser.AS_COMMENT] =					 
			formats[SCRIPT_MASK | AS3LineParser.AS_MULTILINE_COMMENT] = 		new ElementFormat(fontDescription, fontSize, 0x39c02f);
			formats[SCRIPT_MASK | AS3LineParser.AS_REGULAR_EXPRESSION] = 		new ElementFormat(fontDescription, fontSize, 0x9b0000);
			formats[SCRIPT_MASK | AS3LineParser.AS_KEYWORD] = 					new ElementFormat(fontDescription, fontSize, 0x0082cd);
			formats[SCRIPT_MASK | AS3LineParser.AS_VAR_KEYWORD] =				new ElementFormat(fontDescription, fontSize, 0x6d5a9c);
			formats[SCRIPT_MASK | AS3LineParser.AS_FUNCTION_KEYWORD] =			new ElementFormat(fontDescription, fontSize, 0x3382dd);
			formats[SCRIPT_MASK | AS3LineParser.AS_PACKAGE_CLASS_KEYWORDS] = 	new ElementFormat(fontDescription, fontSize, 0xa848da);
			
			formats[STYLE_MASK | CSSLineParser.CSS_TEXT] =					new ElementFormat(fontDescription, fontSize, 0x011282);
			formats[STYLE_MASK | CSSLineParser.CSS_PROPERTY] =				new ElementFormat(fontDescription, fontSize, 0x202020);
			formats[STYLE_MASK | CSSLineParser.CSS_VALUE] =
			formats[STYLE_MASK | CSSLineParser.CSS_MEDIA] =					new ElementFormat(fontDescription, fontSize, 0x97039C);
			formats[STYLE_MASK | CSSLineParser.CSS_BRACEOPEN] =
			formats[STYLE_MASK | CSSLineParser.CSS_BRACECLOSE] =
			formats[STYLE_MASK | CSSLineParser.CSS_COLON1] =
			formats[STYLE_MASK | CSSLineParser.CSS_COLON2] =
			formats[STYLE_MASK | CSSLineParser.CSS_COLON3] =				new ElementFormat(fontDescription, fontSize, 0x000000);
			formats[STYLE_MASK | CSSLineParser.CSS_STRING1] =
			formats[STYLE_MASK | CSSLineParser.CSS_STRING2] =
			formats[STYLE_MASK | CSSLineParser.CSS_STRING3] =
			formats[STYLE_MASK | CSSLineParser.CSS_STRING4] =				new ElementFormat(fontDescription, fontSize, 0xca2323);
			formats[STYLE_MASK | CSSLineParser.CSS_COMMENT1] =
			formats[STYLE_MASK | CSSLineParser.CSS_COMMENT2] =
			formats[STYLE_MASK | CSSLineParser.CSS_COMMENT3] =				new ElementFormat(fontDescription, fontSize, 0x39c02f);
			
			dispatcher.addEventListener(EditorPluginEvent.EVENT_EDITOR_OPEN, handleEditorOpen);
		}
		
		private function handleEditorOpen(event:EditorPluginEvent):void
		{
			if (event.fileExtension == "html"
				|| event.fileExtension == "htm")
			{
				var lineParser:XMLLineParser = new XMLLineParser();
				
				// Add inline parsers
				lineParser.parserManager = new InlineParserManager(
					Vector.<InlineParser>([
						new InlineParser(SCRIPT_MASK, new AS3LineParser()),
						new InlineParser(STYLE_MASK, new CSSLineParser())
					])
				);
				// Inline script context switches
				lineParser.switchManager.addSwitch(new ContextSwitch(Vector.<int>([XMLLineParser.XML_TEXT]), SCRIPT_OPEN_TAG, /<script(?:>|\s>|\s[^>]*[^>\/]>)/i), true);
				lineParser.switchManager.addSwitch(new ContextSwitch(Vector.<int>([SCRIPT_OPEN_TAG]), SCRIPT_MASK));
				lineParser.switchManager.addSwitch(new ContextSwitch(Vector.<int>([SCRIPT_MASK]), SCRIPT_CLOSE_TAG, /<\/script\s*>/i));
				lineParser.switchManager.addSwitch(new ContextSwitch(Vector.<int>([SCRIPT_CLOSE_TAG]), XMLLineParser.XML_TEXT));
				// Inline style context switches
				lineParser.switchManager.addSwitch(new ContextSwitch(Vector.<int>([XMLLineParser.XML_TEXT]), STYLE_OPEN_TAG, /<style(?:>|\s>|\s[^>]*[^>\/]>)/i), true);
				lineParser.switchManager.addSwitch(new ContextSwitch(Vector.<int>([STYLE_OPEN_TAG]), STYLE_MASK));
				lineParser.switchManager.addSwitch(new ContextSwitch(Vector.<int>([STYLE_MASK]), STYLE_CLOSE_TAG, /<\/style\s*>/i));
				lineParser.switchManager.addSwitch(new ContextSwitch(Vector.<int>([STYLE_CLOSE_TAG]), XMLLineParser.XML_TEXT));
				
				event.editor.setParserAndStyles(lineParser, formats);
			}
		}
		
	}
}