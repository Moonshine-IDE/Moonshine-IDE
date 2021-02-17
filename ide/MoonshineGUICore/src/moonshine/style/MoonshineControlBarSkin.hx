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
import openfl.geom.Matrix;

class MoonshineControlBarSkin extends ProgrammaticSkin {
	public function new() {
		super();
	}

	override private function update():Void {
		this.graphics.clear();

		var cornerRadius = 7.0;

		// top shadow
		var matrix = new Matrix();
		matrix.createGradientBox(this.actualWidth, 10.0, 90.0 * Math.PI / 180.0);
		this.graphics.beginGradientFill(LINEAR, [0x2F2F2F, 0x444444], [1.0, 1.0], [0x00, 0xFF], matrix);
		this.graphics.drawRect(0.0, 0.0, this.actualWidth, 10.0);
		this.graphics.endFill();

		// main fill
		this.graphics.beginFill(0x444444);
		this.graphics.moveTo(0.0, 10.0);
		this.graphics.lineTo(this.actualWidth, 10.0);
		this.graphics.lineTo(this.actualWidth, this.actualHeight - cornerRadius);
		this.graphics.curveTo(this.actualWidth, this.actualHeight, this.actualWidth - cornerRadius, this.actualHeight);
		this.graphics.lineTo(cornerRadius, this.actualHeight);
		this.graphics.curveTo(0.0, this.actualHeight, 0.0, this.actualHeight - cornerRadius);
		this.graphics.lineTo(0.0, 10.0);
		this.graphics.endFill();
	}
}
