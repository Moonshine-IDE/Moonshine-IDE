/**

Copyright (C) 2016-present Prominic.NET, Inc.
 
This program is free software: you can redistribute it and/or modify
it under the terms of the Server Side Public License, version 1,
as published by MongoDB, Inc.
 
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
Server Side Public License for more details.

You should have received a copy of the Server Side Public License
along with this program. If not, see
http://www.mongodb.com/licensing/server-side-public-license.

As a special exception, the copyright holders give permission to link the
code of portions of this program with the OpenSSL library under certain
conditions as described in each individual source file and distribute
linked combinations including the program with the OpenSSL library. You
must comply with the Server Side Public License in all respects for
all of the code used other than as permitted herein. If you modify file(s)
with this exception, you may extend this exception to your version of the
file(s), but you are not obligated to do so. If you do not wish to do so,
delete this exception statement from your version. If you delete this
exception statement from all source files in the program, then also delete
it in the license file.

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
