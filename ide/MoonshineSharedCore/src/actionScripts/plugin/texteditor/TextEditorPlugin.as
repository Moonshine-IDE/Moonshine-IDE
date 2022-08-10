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
package actionScripts.plugin.texteditor
{
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.settings.ISettingsProvider;
	import actionScripts.plugin.settings.vo.DropDownListSetting;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.NumericStepperSetting;
	import actionScripts.plugin.texteditor.events.TextEditorSettingsEvent;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.Settings;

	import mx.collections.ArrayList;
	
	public class TextEditorPlugin extends PluginBase implements ISettingsProvider
	{
		public static const SYNTAX_COLOR_SCHEME_LIGHT:String = "Light";
		public static const SYNTAX_COLOR_SCHEME_DARK:String = "Dark";
		public static const SYNTAX_COLOR_SCHEME_MONOKAI:String = "Monokai";

		override public function get name():String 			{return "Text Editor";}
		override public function get author():String 		{return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team";}
		override public function get description():String 	{return "Provides text editor customization options.";}

        public function get fontSize():int
        {
            return Settings.font.defaultFontSize;
        }

        public function set fontSize(value:int):void
        {
            if (Settings.font.defaultFontSize != value)
            {
				Settings.font.defaultFontSize = value;
			    dispatcher.dispatchEvent(new TextEditorSettingsEvent(TextEditorSettingsEvent.FONT_SIZE_CHANGE));
			}
        }

        public function get syntaxColorScheme():String
        {
			if (!model || !model.syntaxColorScheme) {
				// default value
				return SYNTAX_COLOR_SCHEME_LIGHT;
			}
			return model.syntaxColorScheme;
        }

        public function set syntaxColorScheme(value:String):void
        {
            if (model.syntaxColorScheme != value)
            {
                model.syntaxColorScheme = value;
			    dispatcher.dispatchEvent(new TextEditorSettingsEvent(TextEditorSettingsEvent.SYNTAX_COLOR_SCHEME_CHANGE));
            }
        }

		public function getSettingsList():Vector.<ISetting>
		{
			return new <ISetting>[
				new NumericStepperSetting(this, "fontSize", "Font Size", 6, 100, 1, 1),
				new DropDownListSetting(this, "syntaxColorScheme", "Syntax Color Scheme",
					new ArrayList([SYNTAX_COLOR_SCHEME_LIGHT, SYNTAX_COLOR_SCHEME_DARK, SYNTAX_COLOR_SCHEME_MONOKAI])),
			];
		}
				
		override public function activate():void
		{ 
			super.activate();

			model.syntaxColorScheme = syntaxColorScheme;
			// dispatcher.addEventListener(EditorPluginEvent.EVENT_EDITOR_OPEN, handleEditorOpen);
		}

		override public function deactivate():void
		{ 
			super.deactivate();
			// dispatcher.removeEventListener(EditorPluginEvent.EVENT_EDITOR_OPEN, handleEditorOpen);
		}
	}
}