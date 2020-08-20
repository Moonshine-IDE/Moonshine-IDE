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

class MoonshineVScrollBarThumbSkin extends ProgrammaticSkin {
	public function new() {
		super();
	}

	override private function update():Void {
		this.graphics.clear();

		// fill
		this.graphics.beginFill(0x616161);
		this.graphics.drawRect(1.0, 0.0, this.actualWidth / 2.0, this.actualHeight);
		this.graphics.endFill();
		this.graphics.beginFill(0x585858);
		this.graphics.drawRect(this.actualWidth / 2.0, 0.0, this.actualWidth / 2.0, this.actualHeight);
		this.graphics.endFill();

		// left border
		this.graphics.beginFill(0x3A3A3A);
		this.graphics.drawRect(0.0, 0.0, 1.0, this.actualHeight);
		this.graphics.endFill();

		// grip
		var startX = (this.actualWidth / 2.0) - 4.0;
		var endX = startX + 8.0;
		this.graphics.lineStyle(1.0, 0x444444, 1.0, false);
		this.graphics.moveTo(startX, (this.actualHeight / 2.0) - 4.0);
		this.graphics.lineTo(endX, (this.actualHeight / 2.0) - 4.0);
		this.graphics.moveTo(startX, this.actualHeight / 2.0);
		this.graphics.lineTo(endX, this.actualHeight / 2.0);
		this.graphics.moveTo(startX, (this.actualHeight / 2.0) + 4.0);
		this.graphics.lineTo(endX, (this.actualHeight / 2.0) + 4.0);
		this.graphics.endFill();
		this.graphics.lineStyle(1.0, 0x777777, 0.3, false);
		this.graphics.moveTo(startX, (this.actualHeight / 2.0) - 3.0);
		this.graphics.lineTo(endX, (this.actualHeight / 2.0) - 3.0);
		this.graphics.moveTo(startX, (this.actualHeight / 2.0) + 1.0);
		this.graphics.lineTo(endX, (this.actualHeight / 2.0) + 1.0);
		this.graphics.moveTo(startX, (this.actualHeight / 2.0) + 5.0);
		this.graphics.lineTo(endX, (this.actualHeight / 2.0) + 5.0);
		this.graphics.endFill();
	}
}
