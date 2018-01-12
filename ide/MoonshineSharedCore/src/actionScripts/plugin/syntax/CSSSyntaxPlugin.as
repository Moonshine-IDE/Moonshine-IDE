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
	import actionScripts.ui.parser.CSSContextSwitchLineParser;
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
			
			formats[CSSContextSwitchLineParser.CSS_TEXT] =					new ElementFormat(fontDescription, fontSize, 0x011282);
			formats[CSSContextSwitchLineParser.CSS_PROPERTY] =				new ElementFormat(fontDescription, fontSize, 0x202020);
			formats[CSSContextSwitchLineParser.CSS_VALUE] =
			formats[CSSContextSwitchLineParser.CSS_MEDIA] =					new ElementFormat(fontDescription, fontSize, 0x97039C);
			formats[CSSContextSwitchLineParser.CSS_BRACEOPEN] =
			formats[CSSContextSwitchLineParser.CSS_BRACECLOSE] =
			formats[CSSContextSwitchLineParser.CSS_COLON1] =
			formats[CSSContextSwitchLineParser.CSS_COLON2] =
			formats[CSSContextSwitchLineParser.CSS_COLON3] =					new ElementFormat(fontDescription, fontSize, 0x000000);
			formats[CSSContextSwitchLineParser.CSS_STRING1] =
			formats[CSSContextSwitchLineParser.CSS_STRING2] =
			formats[CSSContextSwitchLineParser.CSS_STRING3] =
			formats[CSSContextSwitchLineParser.CSS_STRING4] =				new ElementFormat(fontDescription, fontSize, 0xca2323);
			formats[CSSContextSwitchLineParser.CSS_COMMENT1] =
			formats[CSSContextSwitchLineParser.CSS_COMMENT2] =
			formats[CSSContextSwitchLineParser.CSS_COMMENT3] =				new ElementFormat(fontDescription, fontSize, 0x39c02f);
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
				event.editor.setParserAndStyles(new CSSContextSwitchLineParser(), formats);
			}
		}
		
	}
}