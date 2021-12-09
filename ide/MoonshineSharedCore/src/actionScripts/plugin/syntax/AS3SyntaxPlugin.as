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
	import actionScripts.events.EditorPluginEvent;
	import actionScripts.plugin.IEditorPlugin;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.settings.ISettingsProvider;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.Settings;

	import haxe.IMap;

	import moonshine.editor.text.syntax.format.AS3SyntaxFormatBuilder;
	import moonshine.editor.text.syntax.format.SyntaxColorSettings;
	import moonshine.editor.text.syntax.format.SyntaxFontSettings;
	import moonshine.editor.text.syntax.parser.AS3LineParser;
	import moonshine.editor.text.TextEditor;
	import moonshine.editor.text.utils.AutoClosingPair;
	
	public class AS3SyntaxPlugin extends PluginBase implements  ISettingsProvider, IEditorPlugin
	{
		override public function get name():String 			{return "AS3 Syntax Plugin";}
		override public function get author():String 		{return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team";}
		override public function get description():String 	{return "Provides highlighting for AS3.";}
		public function getSettingsList():Vector.<ISetting>		{return new Vector.<ISetting>();}
				
		override public function activate():void
		{ 
			super.activate();
			dispatcher.addEventListener(EditorPluginEvent.EVENT_EDITOR_OPEN, handleEditorOpen);
		}

		override public function deactivate():void
		{ 
			super.deactivate();
			dispatcher.removeEventListener(EditorPluginEvent.EVENT_EDITOR_OPEN, handleEditorOpen);
		}
		
		private function handleEditorOpen(event:EditorPluginEvent):void
		{
			if (event.fileExtension == "as")
			{
				var formatBuilder:AS3SyntaxFormatBuilder = new AS3SyntaxFormatBuilder();
				formatBuilder.setFontSettings(new SyntaxFontSettings(Settings.font.defaultFontFamily, Settings.font.defaultFontSize));
				formatBuilder.setColorSettings(new SyntaxColorSettings());
				var formats:IMap = formatBuilder.build();
				var textEditor:TextEditor = event.editor;
				textEditor.brackets = [["{", "}"], ["[", "]"], ["(", ")"]];
				textEditor.autoClosingPairs = [
					new AutoClosingPair("{", "}"),
					new AutoClosingPair("[", "]"),
					new AutoClosingPair("(", ")"),
					new AutoClosingPair("'", "'"),
					new AutoClosingPair("\"", "\"")
				];
				textEditor.setParserAndTextStyles(new AS3LineParser(), formats);
				textEditor.embedFonts = Settings.font.defaultFontEmbedded;
			}
		}
		
	}
}