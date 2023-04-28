////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
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