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
package moonshine.plugin.problems.view;

import moonshine.theme.assets.DiagnosticInfoIcon;
import moonshine.theme.assets.DiagnosticWarningIcon;
import moonshine.theme.assets.DiagnosticErrorIcon;
import openfl.display.DisplayObject;
import openfl.display.Bitmap;
import feathers.core.FeathersControl;
import moonshine.lsp.DiagnosticSeverity;

/**
	Displays an icon for the "severity" of a diagnostic.
**/
@:styleContext
class DiagnosticSeverityIcon extends FeathersControl {
	/**
		Creates a new `DiagnosticSeverityIcon` object.
	**/
	public function new() {
		super();
	}
	
	private var _currentIcon:DisplayObject;

	private var _severity:DiagnosticSeverity = Error;

	/**
		The severity of the diagnostic.
	**/
	@:flash.property
	public var severity(get, set):DiagnosticSeverity;

	private function get_severity():DiagnosticSeverity {
		return _severity;
	}

	private function set_severity(value:DiagnosticSeverity):DiagnosticSeverity {
		if (_severity == value) {
			return _severity;
		}
		_severity = value;
		setInvalid(DATA);
		return _severity;
	}

	override private function update():Void {
		var dataInvalid = isInvalid(DATA);

		if (dataInvalid) {
			refreshIcon();
		}

		measure();

		layoutContent();
	}

	private function measure():Void {
		saveMeasurements(16.0, 16.0, 16.0, 16.0);
	}
	
	private function refreshIcon():Void {
		var iconClass:Class<Dynamic> = switch(_severity) {
			case Error: DiagnosticErrorIcon;
			case Warning: DiagnosticWarningIcon;
			default: DiagnosticInfoIcon;
		}
		
		if (Std.isOfType(this._currentIcon, iconClass)) {
			// the existing icon is correct, so keep it as-is
			return;
		}
		
		if (_currentIcon != null) {
			removeChild(_currentIcon);
			_currentIcon = null;
		}
		var bitmapData = Type.createInstance(iconClass, []);
		_currentIcon = new Bitmap(bitmapData);
		addChild(_currentIcon);
	}

	private function layoutContent():Void {
		_currentIcon.x = 0.0;
		_currentIcon.y = 0.0;
		_currentIcon.width = 16.0;
		_currentIcon.height = 16.0;
	}
}
