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


package moonshine.style;

import feathers.graphics.FillStyle;
import feathers.skins.ProgrammaticSkin;
import openfl.display.InterpolationMethod;
import openfl.display.SpreadMethod;
import openfl.geom.Matrix;

class MoonshineButtonSkin extends ProgrammaticSkin {
	public function new() {
		super();
	}

	public var outerBorderSize:Float = 1.0;
	public var innerBorderSize:Float = 1.0;
	public var outerBorderRadius:Float = 0.0;
	public var innerBorderRadius:Float = 0.0;
	public var outerBorderFill:FillStyle;
	public var innerBorderFill:FillStyle;

	public var borderRadius:Float = 0.0;
	public var fill:FillStyle;

	override private function update():Void {
		var offset = 0.0;
		this.graphics.clear();
		if (this.outerBorderFill != null) {
			var outerBorderEllipseSize = this.outerBorderRadius * 2.0;
			outerBorderEllipseSize = Math.min(outerBorderEllipseSize, Math.min(this.actualWidth, this.actualHeight));
			this.applyFillStyle(this.outerBorderFill);
			this.graphics.drawRoundRect(offset, offset, this.actualWidth - (2.0 * offset), this.actualHeight - (2.0 * offset), outerBorderEllipseSize);
			offset += this.outerBorderSize;
		}
		if (this.innerBorderFill != null) {
			var innerBorderEllipseSize = this.innerBorderRadius * 2.0;
			innerBorderEllipseSize = Math.min(innerBorderEllipseSize, Math.min(this.actualWidth, this.actualHeight));
			this.applyFillStyle(this.innerBorderFill);
			this.graphics.drawRoundRect(offset, offset, this.actualWidth - (2.0 * offset), this.actualHeight - (2.0 * offset), innerBorderEllipseSize);
			offset += this.innerBorderSize;
		}
		if (this.fill != null) {
			var borderEllipseSize = this.borderRadius * 2.0;
			borderEllipseSize = Math.min(borderEllipseSize, Math.min(this.actualWidth, this.actualHeight));
			this.applyFillStyle(this.fill);
			this.graphics.drawRoundRect(offset, offset, this.actualWidth - (2.0 * offset), this.actualHeight - (2.0 * offset), borderEllipseSize);
		}
	}

	private function applyFillStyle(fillStyle:FillStyle):Void {
		if (fillStyle == null) {
			return;
		}
		switch (fillStyle) {
			case None:
				{
					return;
				}
			case SolidColor(color, alpha):
				{
					if (alpha == null) {
						alpha = 1.0;
					}
					this.graphics.beginFill(color, alpha);
				}
			case Gradient(type, colors, alphas, ratios, matrixCallback, spreadMethod, interpolationMethod, focalPointRatio):
				{
					var callback:(Float, Float, ?Float, ?Float, ?Float) -> Matrix = matrixCallback;
					if (callback == null) {
						callback = getDefaultGradientMatrix;
					}
					if (spreadMethod == null) {
						spreadMethod = SpreadMethod.PAD;
					}
					if (interpolationMethod == null) {
						interpolationMethod = InterpolationMethod.RGB;
					}
					if (focalPointRatio == null) {
						focalPointRatio = 0.0;
					}
					var matrix = callback(this.actualWidth, this.actualHeight, 0.0, 0.0, 0.0);
					this.graphics.beginGradientFill(type, #if flash cast #end colors, alphas, ratios, matrix, spreadMethod, interpolationMethod,
						focalPointRatio);
				}
			case Bitmap(bitmapData, matrix, repeat, smooth):
				{
					if (repeat == null) {
						repeat = true;
					}
					if (smooth == null) {
						smooth = false;
					}
					this.graphics.beginBitmapFill(bitmapData, matrix, repeat, smooth);
				}
		}
	}

	private function getDefaultGradientMatrix(width:Float, height:Float, ?radians:Float = 0.0, ?tx:Float = 0.0, ?ty:Float = 0.0):Matrix {
		var matrix = new Matrix();
		matrix.createGradientBox(width, height, radians, tx, ty);
		return matrix;
	}
}
