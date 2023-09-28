/*
	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License

	No warranty of merchantability or fitness of any kind.
	Use this software at your own risk.
 */

package moonshine.editor.text.syntax.format;

import moonshine.editor.text.syntax.parser.TibboBasicLineParser;
import openfl.text.TextFormat;

/**
	Builds the set of text styles for the Tibbo Basic language.
**/
class TibboBasicSyntaxFormatBuilder {
	private var _colorSettings:SyntaxColorSettings;
	private var _fontSettings:SyntaxFontSettings;

	/**
		Creates a new `TibboBasicSyntaxFormatBuilder` object.
	**/
	public function new() {}

	/**
		Specifies the `SyntaxColorSettings` to use when creating the
		`TextFormat` objects.
	**/
	public function setColorSettings(settings:SyntaxColorSettings):TibboBasicSyntaxFormatBuilder {
		_colorSettings = settings;
		return this;
	}

	/**
		Specifies the `SyntaxFontSettings` to use when creating the
		`TextFormat` objects.
	**/
	public function setFontSettings(settings:SyntaxFontSettings):TibboBasicSyntaxFormatBuilder {
		_fontSettings = settings;
		return this;
	}

	/**
		Creates a mapping of language text styles to `TextFormat` objects.
	**/
	public function build():Map<Int, TextFormat> {
		var formats:Map<Int, TextFormat> = [];
		formats.set(0 /* default, parser fault */, getTextFormat(_colorSettings.invalidColor));
		formats.set(TibboBasicLineParser.BASIC_CODE, getTextFormat(_colorSettings.foregroundColor));
		formats.set(TibboBasicLineParser.BASIC_STRING, getTextFormat(_colorSettings.stringColor));
		formats.set(TibboBasicLineParser.BASIC_COMMENT, getTextFormat(_colorSettings.commentColor));
		formats.set(TibboBasicLineParser.BASIC_KEYWORD, getTextFormat(_colorSettings.keywordColor));
		formats.set(TibboBasicLineParser.BASIC_VARIABLE_KEYWORD, getTextFormat(_colorSettings.fieldKeywordColor));
		formats.set(TibboBasicLineParser.BASIC_PROCEDURE_KEYWORD, getTextFormat(_colorSettings.methodKeywordColor));
		formats.set(TibboBasicLineParser.BASIC_TYPE_KEYWORD, getTextFormat(_colorSettings.typeKeywordColor));
		formats.set(TibboBasicLineParser.BASIC_VALUE_KEYWORD, getTextFormat(_colorSettings.valueColor));
		formats.set(TibboBasicLineParser.BASIC_SIMPLE_TYPE_KEYWORD, getTextFormat(_colorSettings.typeNameColor));
		return formats;
	}

	private function getTextFormat(fontColor:UInt):TextFormat {
		var format = new TextFormat(_fontSettings.fontFamily, _fontSettings.fontSize, fontColor);
		format.tabStops = _fontSettings.tabStops;
		return format;
	}
}
