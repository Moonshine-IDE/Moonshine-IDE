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
	import actionScripts.ui.parser.CSSLineParser;
	import actionScripts.valueObjects.Settings;
	
	public class CSSSyntaxPlugin extends PluginBase implements  ISettingsProvider, IEditorPlugin
	{
		private var formats:Object = {};
		
		override public function get name():String 			{return "CSS Syntax Plugin";}
		override public function get author():String 		{return "Moonshine Project Team";}
		override public function get description():String 	{return "Provides highlighting for CSS.";}
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
			
		public function CSSSyntaxPlugin()
		{
			
		}
		
		private function init():void
		{
			var fontDescription:FontDescription = Settings.font.defaultFontDescription;
			var fontSize:Number = Settings.font.defaultFontSize;
			
			formats[CSSLineParser.CSS_TEXT] =					new ElementFormat(fontDescription, fontSize, 0x011282);
			formats[CSSLineParser.CSS_PROPERTY] =				new ElementFormat(fontDescription, fontSize, 0x202020);
			formats[CSSLineParser.CSS_VALUE] =
			formats[CSSLineParser.CSS_MEDIA] =					new ElementFormat(fontDescription, fontSize, 0x97039C);
			formats[CSSLineParser.CSS_BRACEOPEN] =
			formats[CSSLineParser.CSS_BRACECLOSE] =
			formats[CSSLineParser.CSS_COLON1] =
			formats[CSSLineParser.CSS_COLON2] =
			formats[CSSLineParser.CSS_COLON3] =					new ElementFormat(fontDescription, fontSize, 0x000000);
			formats[CSSLineParser.CSS_STRING1] =
			formats[CSSLineParser.CSS_STRING2] =
			formats[CSSLineParser.CSS_STRING3] =
			formats[CSSLineParser.CSS_STRING4] =				new ElementFormat(fontDescription, fontSize, 0xca2323);
			formats[CSSLineParser.CSS_COMMENT1] =
			formats[CSSLineParser.CSS_COMMENT2] =
			formats[CSSLineParser.CSS_COMMENT3] =				new ElementFormat(fontDescription, fontSize, 0x39c02f);
			formats['lineNumber'] =								new ElementFormat(fontDescription, fontSize, 0x888888);
			formats['breakPointLineNumber'] =					new ElementFormat(fontDescription, fontSize, 0xffffff);
			formats['breakPointBackground'] =					0xdea5dd;
			formats['tracingLineColor']=						0xc6dbae;
			
			dispatcher.addEventListener(EditorPluginEvent.EVENT_EDITOR_OPEN, handleEditorOpen);
		}
		
		private function handleEditorOpen(event:EditorPluginEvent):void
		{
			if (event.fileExtension == "css")
			{
				event.editor.setParserAndStyles(new CSSLineParser(), formats);
			}
		}
		
	}
}