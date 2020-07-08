package moonshine.style;

import openfl.geom.Matrix;
import feathers.core.MeasureSprite;
import feathers.graphics.FillStyle;
import openfl.display.InterpolationMethod;
import openfl.display.SpreadMethod;

class MoonshineButtonSkin extends MeasureSprite {
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
			this.applyFillStyle(this.outerBorderFill);
			this.graphics.drawRoundRect(offset, offset, this.actualWidth - (2.0 * offset), this.actualHeight - (2.0 * offset), this.outerBorderRadius);
			offset += this.outerBorderSize;
		}
		if (this.innerBorderFill != null) {
			this.applyFillStyle(this.innerBorderFill);
			this.graphics.drawRoundRect(offset, offset, this.actualWidth - (2.0 * offset), this.actualHeight - (2.0 * offset), this.innerBorderRadius);
			offset += this.innerBorderSize;
		}
		if (this.fill != null) {
			this.applyFillStyle(this.fill);
			this.graphics.drawRoundRect(offset, offset, this.actualWidth - (2.0 * offset), this.actualHeight - (2.0 * offset), this.borderRadius);
		}
	}

	private function applyFillStyle(fillStyle:FillStyle):Void {
		if (fillStyle == null) {
			return;
		}
		switch (fillStyle) {
			case SolidColor(color, alpha):
				{
					if (alpha == null) {
						alpha = 1.0;
					}
					this.graphics.beginFill(color, alpha);
				}
			case Gradient(type, colors, alphas, ratios, radians, spreadMethod, interpolationMethod, focalPointRatio):
				{
					if (radians == null) {
						radians = 0.0;
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
					var matrix = getGradientMatrix(radians);
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

	private function getGradientMatrix(radians:Float):Matrix {
		var matrix = new Matrix();
		matrix.createGradientBox(this.actualWidth, this.actualHeight, radians);
		return matrix;
	}
}
