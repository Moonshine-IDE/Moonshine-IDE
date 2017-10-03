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
	import actionScripts.valueObjects.Settings;
	
	public class JSSyntaxPlugin extends PluginBase implements  ISettingsProvider, IEditorPlugin
	{
		private var formats:Object = {};
		
		override public function get name():String 			{return "JS Syntax Plugin";}
		override public function get author():String 		{return "Moonshine Project Team";}
		override public function get description():String 	{return "Provides highlighting for JS.";}
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
			
		public function JSSyntaxPlugin()
		{
			
		}
		
		private function init():void
		{
			var fontDescription:FontDescription = Settings.font.defaultFontDescription;
			var fontSize:Number = Settings.font.defaultFontSize;
			
			formats[0] = /* default, parser fault */			new ElementFormat(fontDescription, fontSize, 0xFF0000);
			formats[AS3LineParser.AS_CODE] =					new ElementFormat(fontDescription, fontSize, 0x101010);
			formats[AS3LineParser.AS_STRING1] = 				
			formats[AS3LineParser.AS_STRING2] = 				new ElementFormat(fontDescription, fontSize, 0xca2323);
			formats[AS3LineParser.AS_COMMENT] =					 
			formats[AS3LineParser.AS_MULTILINE_COMMENT] = 		new ElementFormat(fontDescription, fontSize, 0x39c02f);
			formats[AS3LineParser.AS_REGULAR_EXPRESSION] = 		new ElementFormat(fontDescription, fontSize, 0x9b0000);
			formats[AS3LineParser.AS_KEYWORD] = 				new ElementFormat(fontDescription, fontSize, 0x0082cd);
			formats[AS3LineParser.AS_VAR_KEYWORD] =				new ElementFormat(fontDescription, fontSize, 0x6d5a9c);
			formats[AS3LineParser.AS_FUNCTION_KEYWORD] =		new ElementFormat(fontDescription, fontSize, 0x3382dd);
			formats[AS3LineParser.AS_PACKAGE_CLASS_KEYWORDS] = 	new ElementFormat(fontDescription, fontSize, 0xa848da);
			formats['lineNumber'] =								new ElementFormat(fontDescription, fontSize, 0x888888);
			formats['breakPointLineNumber'] =					new ElementFormat(fontDescription, fontSize, 0xffffff);
			formats['breakPointBackground'] =					0xdea5dd;
			formats['tracingLineColor']=						0xc6dbae;
			
			dispatcher.addEventListener(EditorPluginEvent.EVENT_EDITOR_OPEN, handleEditorOpen);
		}
		
		private function handleEditorOpen(event:EditorPluginEvent):void
		{
			if (event.fileExtension == "js")
			{
				event.editor.setParserAndStyles(new AS3LineParser(), formats);
			}
		}
		
	}
}