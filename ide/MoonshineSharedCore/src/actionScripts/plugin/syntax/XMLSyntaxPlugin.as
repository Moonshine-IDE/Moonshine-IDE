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
	import actionScripts.ui.parser.XMLLineParser;
	import actionScripts.valueObjects.Settings;
	
	public class XMLSyntaxPlugin extends PluginBase implements  ISettingsProvider, IEditorPlugin
	{
		private var formats:Object = {};
		
		override public function get name():String 			{return "XML Syntax Plugin";}
		override public function get author():String 		{return "Moonshine Project Team";}
		override public function get description():String 	{return "Provides highlighting for XML.";}
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
			
		public function XMLSyntaxPlugin()
		{
			
		}
		
		private function init():void
		{
			var fontDescription:FontDescription = Settings.font.defaultFontDescription;
			var fontSize:Number = Settings.font.defaultFontSize;
			
			formats[XMLLineParser.XML_TEXT] =					new ElementFormat(fontDescription, fontSize, 0x3322dd);
			formats[XMLLineParser.XML_TAG] =					new ElementFormat(fontDescription, fontSize, 0x202020);
			formats[XMLLineParser.XML_COMMENT] =				new ElementFormat(fontDescription, fontSize, 0x39c02f);
			formats[XMLLineParser.XML_CDATA] =					new ElementFormat(fontDescription, fontSize, 0x9b0000);
			formats[XMLLineParser.XML_ATTR_NAME] =				new ElementFormat(fontDescription, fontSize, 0x404040);
			formats[XMLLineParser.XML_ATTR_VAL1] =
			formats[XMLLineParser.XML_ATTR_VAL2] =				new ElementFormat(fontDescription, fontSize, 0xca2323);
			formats[XMLLineParser.XML_ATTR_OPER] =
			formats[XMLLineParser.XML_BACKETOPEN] =
			formats[XMLLineParser.XML_BACKETCLOSE] =			new ElementFormat(fontDescription, fontSize, 0x4e022f);
			formats['lineNumber'] =								new ElementFormat(fontDescription, fontSize, 0x888888);
			formats['breakPointLineNumber'] =					new ElementFormat(fontDescription, fontSize, 0xffffff);
			formats['breakPointBackground'] =					0xdea5dd;
			formats['tracingLineColor']=						0xc6dbae;
			
			dispatcher.addEventListener(EditorPluginEvent.EVENT_EDITOR_OPEN, handleEditorOpen);
		}
		
		private function handleEditorOpen(event:EditorPluginEvent):void
		{
			if (event.fileExtension == "xml")
			{
				event.editor.setParserAndStyles(new XMLLineParser(), formats);
			}
		}
		
	}
}