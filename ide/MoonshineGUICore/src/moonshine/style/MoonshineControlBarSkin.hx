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
