/*
	Copyright 2020 Prominic.NET, Inc.

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

package moonshine.style;

import feathers.skins.ProgrammaticSkin;

class MoonshineHScrollBarThumbSkin extends ProgrammaticSkin {
	public function new() {
		super();
	}

	override private function update():Void {
		this.graphics.clear();

		// fill
		this.graphics.beginFill(0x616161);
		this.graphics.drawRect(0.0, 1.0, this.actualWidth, this.actualHeight / 2.0);
		this.graphics.endFill();
		this.graphics.beginFill(0x585858);
		this.graphics.drawRect(0.0, this.actualHeight / 2.0, this.actualWidth, this.actualHeight / 2.0);
		this.graphics.endFill();

		// top border
		this.graphics.beginFill(0x3A3A3A);
		this.graphics.drawRect(0.0, 0.0, this.actualWidth, 1.0);
		this.graphics.endFill();

		// grip
		var startY = (this.actualHeight / 2.0) - 4.0;
		var endY = startY + 8.0;
		this.graphics.lineStyle(1.0, 0x444444, 1.0, false);
		this.graphics.moveTo((this.actualWidth / 2.0) - 4.0, startY);
		this.graphics.lineTo((this.actualWidth / 2.0) - 4.0, endY);
		this.graphics.moveTo(this.actualWidth / 2.0, startY);
		this.graphics.lineTo(this.actualWidth / 2.0, endY);
		this.graphics.moveTo((this.actualWidth / 2.0) + 4.0, startY);
		this.graphics.lineTo((this.actualWidth / 2.0) + 4.0, endY);
		this.graphics.endFill();
		this.graphics.lineStyle(1.0, 0x777777, 0.3, false);
		this.graphics.moveTo((this.actualWidth / 2.0) - 3.0, startY);
		this.graphics.lineTo((this.actualWidth / 2.0) - 3.0, endY);
		this.graphics.moveTo((this.actualWidth / 2.0) + 1.0, startY);
		this.graphics.lineTo((this.actualWidth / 2.0) + 1.0, endY);
		this.graphics.moveTo((this.actualWidth / 2.0) + 5.0, startY);
		this.graphics.lineTo((this.actualWidth / 2.0) + 5.0, endY);
		this.graphics.endFill();
	}
}
