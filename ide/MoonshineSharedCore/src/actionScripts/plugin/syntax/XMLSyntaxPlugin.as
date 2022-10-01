////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2016-present Prominic.NET, Inc.
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

	import moonshine.editor.text.syntax.format.SyntaxColorSettings;
	import moonshine.editor.text.syntax.format.SyntaxFontSettings;
	import moonshine.editor.text.syntax.format.XMLSyntaxFormatBuilder;
	import moonshine.editor.text.syntax.parser.XMLLineParser;
	import moonshine.editor.text.TextEditor;
	import moonshine.editor.text.utils.AutoClosingPair;
	import actionScripts.plugin.texteditor.events.TextEditorSettingsEvent;
	import actionScripts.ui.editor.BasicTextEditor;
	import actionScripts.plugin.texteditor.TextEditorPlugin;
	
	public class XMLSyntaxPlugin extends PluginBase implements  ISettingsProvider, IEditorPlugin
	{
		private static const FILE_EXTENSION_XML:String = "xml";
		private static const FILE_EXTENSION_AS3PROJ:String = "as3proj";
		private static const FILE_EXTENSION_VEDITORPROJ:String = "veditorproj";
		private static const FILE_EXTENSION_JAVAPROJ:String = "javaproj";
		private static const FILE_EXTENSION_HXPROJ:String = "hxproj";
		private static const FILE_EXTENSION_GRAILSPROJ:String = "grailsproj";

		override public function get name():String 			{return "XML Syntax Plugin";}
		override public function get author():String 		{return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team";}
		override public function get description():String 	{return "Provides highlighting for XML.";}
		public function getSettingsList():Vector.<ISetting>		{return new Vector.<ISetting>();}
				
		override public function activate():void
		{ 
			super.activate();
			dispatcher.addEventListener(EditorPluginEvent.EVENT_EDITOR_OPEN, handleEditorOpen);
			dispatcher.addEventListener(TextEditorSettingsEvent.SYNTAX_COLOR_SCHEME_CHANGE, handleSyntaxColorChange);
			dispatcher.addEventListener(TextEditorSettingsEvent.FONT_SIZE_CHANGE, handleFontSizeChange);
		}

		override public function deactivate():void
		{ 
			super.deactivate();
			dispatcher.removeEventListener(EditorPluginEvent.EVENT_EDITOR_OPEN, handleEditorOpen);
			dispatcher.removeEventListener(TextEditorSettingsEvent.SYNTAX_COLOR_SCHEME_CHANGE, handleSyntaxColorChange);
			dispatcher.removeEventListener(TextEditorSettingsEvent.FONT_SIZE_CHANGE, handleFontSizeChange);
		}
		
		private function isExpectedType(type:String):Boolean
		{
			return type == FILE_EXTENSION_XML
				|| type == FILE_EXTENSION_AS3PROJ
				|| type == FILE_EXTENSION_VEDITORPROJ
				|| type == FILE_EXTENSION_JAVAPROJ
				|| type == FILE_EXTENSION_HXPROJ
				|| type == FILE_EXTENSION_GRAILSPROJ;
		}

		private function getColorSettings():SyntaxColorSettings
		{
			var colorSettings:SyntaxColorSettings;
			switch(model.syntaxColorScheme)
			{
				case TextEditorPlugin.SYNTAX_COLOR_SCHEME_DARK:
					return SyntaxColorSettings.defaultDark();
				case TextEditorPlugin.SYNTAX_COLOR_SCHEME_MONOKAI:
					return SyntaxColorSettings.monokai();
				default: // light
					return SyntaxColorSettings.defaultLight();
			}
		}

		private function applySyntaxColorSettings(textEditor:TextEditor, colorSettings:SyntaxColorSettings):void
		{
			var formatBuilder:XMLSyntaxFormatBuilder = new XMLSyntaxFormatBuilder();
			formatBuilder.setFontSettings(new SyntaxFontSettings(Settings.font.defaultFontFamily, Settings.font.defaultFontSize));
			formatBuilder.setColorSettings(colorSettings);
			var formats:IMap = formatBuilder.build();
			textEditor.setParserAndTextStyles(new XMLLineParser(), formats);
			textEditor.embedFonts = Settings.font.defaultFontEmbedded;
		}

		private function initializeTextEditor(textEditor:TextEditor):void
		{
			var colorSettings:SyntaxColorSettings = getColorSettings();
			applySyntaxColorSettings(textEditor, colorSettings);
			textEditor.brackets = [["<!--", "-->"], ["<", ">"], ["{", "}"], ["(", ")"]];
			textEditor.autoClosingPairs = [
				new AutoClosingPair("{", "}"),
				new AutoClosingPair("[", "]"),
				new AutoClosingPair("(", ")"),
				new AutoClosingPair("'", "'"),
				new AutoClosingPair("\"", "\""),
				new AutoClosingPair("<!--", "-->"),
				new AutoClosingPair("<![CDATA[", "]]>")
			];
			textEditor.blockComment = ["<!--", "-->"];
		}
		
		private function handleEditorOpen(event:EditorPluginEvent):void
		{
			if (isExpectedType(event.fileExtension))
			{
				var textEditor:TextEditor = event.editor;
				initializeTextEditor(textEditor);
			}
		}

		private function applyFontAndSyntaxSettingsToAll():void
		{
			var colorSettings:SyntaxColorSettings = getColorSettings();
			var editorCount:int = model.editors.length;
			for(var i:int = 0; i < editorCount; i++)
			{
				var editor:BasicTextEditor = model.editors.getItemAt(i) as BasicTextEditor;
				if (!editor)
				{
					continue;
				}
				if (editor.currentFile && isExpectedType(editor.currentFile.fileBridge.extension))
				{
					applySyntaxColorSettings(editor.getEditorComponent(), colorSettings);
				}
			}
		}

		private function handleSyntaxColorChange(event:TextEditorSettingsEvent):void
		{
			applyFontAndSyntaxSettingsToAll();
		}

		private function handleFontSizeChange(event:TextEditorSettingsEvent):void
		{
			applyFontAndSyntaxSettingsToAll();
		}
	}
}