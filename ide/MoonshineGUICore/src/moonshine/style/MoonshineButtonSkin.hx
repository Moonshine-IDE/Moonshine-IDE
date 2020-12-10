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
