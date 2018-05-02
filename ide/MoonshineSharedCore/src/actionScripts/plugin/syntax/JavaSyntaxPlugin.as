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
	import actionScripts.ui.parser.JavaLineParser;
	
	public class JavaSyntaxPlugin extends PluginBase implements  ISettingsProvider, IEditorPlugin
	{
		private var formats:Object = {};

		override public function get name():String 			{return "Java Syntax Plugin";}
		override public function get author():String 		{return "Moonshine Project Team";}
		override public function get description():String 	{return "Provides highlighting for Java.";}
		public function getSettingsList():Vector.<ISetting>		{return new Vector.<ISetting>();}
		
		override public function activate():void
		{ 
			super.activate();
			init();
		}
		
		private function init():void
		{
			var fontDescription:FontDescription = Settings.font.defaultFontDescription;
			var fontSize:Number = Settings.font.defaultFontSize;
			
			formats[0] = /* default, parser fault */				new ElementFormat(fontDescription, fontSize, 0xFF0000);
			formats[JavaLineParser.JAVA_CODE] =						new ElementFormat(fontDescription, fontSize, 0x101010);
			formats[JavaLineParser.JAVA_STRING1] = 				
			formats[JavaLineParser.JAVA_STRING2] = 					new ElementFormat(fontDescription, fontSize, 0xca2323);
			formats[JavaLineParser.JAVA_COMMENT] =					 
			formats[JavaLineParser.JAVA_MULTILINE_COMMENT] =		new ElementFormat(fontDescription, fontSize, 0x39c02f);
			formats[JavaLineParser.JAVA_KEYWORD] = 					new ElementFormat(fontDescription, fontSize, 0x0082cd);
			formats[JavaLineParser.JAVA_PACKAGE_CLASS_KEYWORDS] = 	new ElementFormat(fontDescription, fontSize, 0xa848da);
			formats['lineNumber'] =									new ElementFormat(fontDescription, fontSize, 0x888888);
			formats['breakPointLineNumber'] =						new ElementFormat(fontDescription, fontSize, 0xffffff);
			formats['breakPointBackground'] =						0xdea5dd;
			formats['tracingLineColor'] =							0xc6dbae;
			formats[JavaLineParser.JAVA_ANNOTATION] =				new ElementFormat(fontDescription, fontSize, 0x808000);

			dispatcher.addEventListener(EditorPluginEvent.EVENT_EDITOR_OPEN, handleEditorOpen);
		}
		
		private function handleEditorOpen(event:EditorPluginEvent):void
		{
			if (event.fileExtension == "java")
			{
				event.editor.setParserAndStyles(new JavaLineParser(), formats);
			}
		}
		
	}
}