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

package moonshine.plugin.symbols.view;

import moonshine.lsp.DocumentSymbol;
import moonshine.lsp.SymbolInformation;
import feathers.core.FeathersControl;
import feathers.skins.CircleSkin;
import feathers.text.TextFormat;
import moonshine.editor.text.lsp.views.theme.CompletionItemIconStyles;
import moonshine.lsp.CompletionItem;
import moonshine.lsp.SymbolKind;
import openfl.text.TextField;

/**
	Displays an icon for the "kind" of a completion item.
**/
@:styleContext
class SymbolIcon extends FeathersControl {
	private static final TEXT_MAP:Map<SymbolKind, String> = [
		SymbolKind.Function => "F", SymbolKind.Interface => "I",  SymbolKind.Class => "C",    SymbolKind.Variable => "V",   SymbolKind.Field => "F",
		   SymbolKind.Event => "E",  SymbolKind.Property => "P", SymbolKind.Method => "M", SymbolKind.Constructor => "C", SymbolKind.Constant => "C",
	];
	private static final COLOR_MAP:Map<SymbolKind, UInt> = [
		SymbolKind.Function => 0x3382dd, SymbolKind.Interface => 0x5B4AE4, SymbolKind.Class => 0xa848da, SymbolKind.Variable => 0x6d5a9c,
		SymbolKind.Field => 0x6d5a1b, SymbolKind.Event => 0xC28627, SymbolKind.Property => 0x3E8854, SymbolKind.Method => 0x3382dd,
		SymbolKind.Constructor => 0x3382dd, SymbolKind.Constant => 0x6d5a9c,
	];

	/**
		Creates a new `CompletionItemIcon` object.
	**/
	public function new() {
		super();
	}

	private var _textField:TextField;
	private var _backgroundSkin:CircleSkin;

	private var _data:Any;

	/**
		The completion item associated with this icon.
	**/
	@:flash.property
	public var data(get, set):Any /* SymbolInformation | DocumentSymbol */;

	private function get_data():Any {
		return _data;
	}

	private function set_data(value:Any):Any {
		if (_data == value) {
			return _data;
		}
		_data = value;
		setInvalid(DATA);
		return _data;
	}

	/**
		The text format of the icon character.
	**/
	@:style
	public var textFormat:AbstractTextFormat = new TextFormat("_sans", 12, 0x000000, true);

	/**
		A mapping of completion item kinds to background colors.
	**/
	@:style
	public var colorMap:Map<SymbolKind, UInt> = COLOR_MAP;

	override private function initialize():Void {
		super.initialize();

		if (_backgroundSkin == null) {
			_backgroundSkin = new CircleSkin();
			addChild(_backgroundSkin);
		}

		if (_textField == null) {
			_textField = new TextField();
			_textField.autoSize = LEFT;
			_textField.mouseEnabled = false;
			_textField.selectable = false;
			addChild(_textField);
		}
	}

	override private function update():Void {
		var dataInvalid = isInvalid(DATA);
		var stylesInvalid = isInvalid(STYLES);

		if (dataInvalid || stylesInvalid) {
			_textField.defaultTextFormat = textFormat;
			if (_data != null) {
				var kind = if ((_data is DocumentSymbol)) {
					cast(_data, DocumentSymbol).kind;
				} else {
					cast(_data, SymbolInformation).kind;
				}
				var fillColor = colorMap.exists(kind) ? colorMap.get(kind) : 0x999999;
				_backgroundSkin.fill = SolidColor(fillColor);
				_textField.text = TEXT_MAP.exists(kind) ? TEXT_MAP.get(kind) : "";
			} else {
				_backgroundSkin.fill = SolidColor(0x999999);
				_textField.text = "";
			}
		}

		measure();

		layoutContent();
	}

	private function measure():Void {
		saveMeasurements(16.0, 16.0, 16.0, 16.0);
	}

	private function layoutContent():Void {
		_backgroundSkin.x = 0.0;
		_backgroundSkin.y = 0.0;
		_backgroundSkin.width = actualWidth;
		_backgroundSkin.height = actualHeight;

		_textField.x = (actualWidth - _textField.width) / 2.0;
		_textField.y = (actualHeight - _textField.height) / 2.0;
	}
}
