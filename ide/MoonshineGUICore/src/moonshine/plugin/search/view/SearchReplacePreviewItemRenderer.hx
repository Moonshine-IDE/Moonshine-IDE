/*
	Copyright 2022 Prominic.NET, Inc.

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License

	Author: Prominic.NET, Inc.
	No warranty of merchantability or fitness of any kind.
	Use this software at your own risk.
 */

package moonshine.plugin.search.view;

import openfl.events.Event;
import feathers.controls.Check;
import feathers.controls.Label;
import feathers.controls.dataRenderers.ItemRenderer;

class SearchReplacePreviewItemRenderer extends ItemRenderer {
	public function new() {
		super();
	}

	private var check:Check;
	private var label:Label;

	override private function initialize():Void {
		super.initialize();

		if (check == null) {
			check = new Check();
			check.showText = false;
			check.addEventListener(Event.CHANGE, check_changeHandler);
			icon = check;
		}
	}

	override private function update():Void {
		var dataInvalid = isInvalid(DATA);

		if (dataInvalid) {
			if (_data != null) {
				check.selected = _data.isSelected;
			} else {
				check.selected = false;
			}
		}
		super.update();
	}

	private function check_changeHandler(event:Event):Void {
		if (_validating) {
			return;
		}
		_data.isSelected = check.selected;
		setInvalid(DATA);
	}
}
