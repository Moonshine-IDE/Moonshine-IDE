package moonshine.theme;

import openfl.text.TextFormat;

using moonshine.theme.MoonshineTypography.TypoUtils;

class MoonshineTypography {
	public static final DEFAULT_FONT_NAME:String = "_sans";
	public static final FONT_SIZE_22:Int = 22;
	public static final LARGER_FONT_SIZE:Int = 14;
	public static final LARGE_FONT_SIZE:Int = 15;
	public static final SECONDARY_FONT_SIZE:Int = 12;
	public static final SMALL_FONT_SIZE:Int = 11;
	public static inline final DEFAULT_FONT_SIZE:Int = 13;

	private static final _DEFAULT_TEXT_FORMAT:TextFormat = new TextFormat(DEFAULT_FONT_NAME, DEFAULT_FONT_SIZE, MoonshineColor.GREY_2);
	private static final _TEXT_FORMAT_CACHE:Map<String, TextFormat> = [];

	public static function getTextFormat(size:Int = DEFAULT_FONT_SIZE, color:MoonshineColor = MoonshineColor.GREY_2, bold:Bool = false, italic:Bool = false,
			underline:Bool = false):TextFormat {
		var id:String = Std.string(size)
			+ "-"
			+ Std.string(color)
			+ "-"
			+ Std.string(bold)
			+ "-"
			+ Std.string(italic)
			+ "-"
			+ Std.string(underline);
		if (_TEXT_FORMAT_CACHE.exists(id))
			return _TEXT_FORMAT_CACHE.get(id);

		var tf = _DEFAULT_TEXT_FORMAT.clone();
		tf.size = size;
		tf.color = color;
		tf.bold = bold;
		tf.italic = italic;
		tf.underline = underline;
		_TEXT_FORMAT_CACHE.set(id, tf);

		return tf;
	}

	public static inline function getDarkOnLightTextFormat():TextFormat {
		return _DEFAULT_TEXT_FORMAT;
	}

	public static inline function getDarkOnLightDisabledTextFormat():TextFormat {
		return getTextFormat(DEFAULT_FONT_SIZE, MoonshineColor.GREY_9);
	}

	public static inline function getLightOnDarkTextFormat():TextFormat {
		return getTextFormat(DEFAULT_FONT_SIZE, MoonshineColor.GREY_F3);
	}

	public static inline function getLightOnDarkDisabledTextFormat():TextFormat {
		return getTextFormat(DEFAULT_FONT_SIZE, MoonshineColor.GREY_5);
	}

	public static inline function getLightOnDarkSecondaryTextFormat():TextFormat {
		return getTextFormat(DEFAULT_FONT_SIZE, MoonshineColor.GREY_B);
	}

	public static inline function getMaroonTextFormat():TextFormat {
		return getTextFormat(LARGER_FONT_SIZE, MoonshineColor.MAROON);
	}

	public static inline function getGreyTextFormat():TextFormat {
		return getTextFormat(DEFAULT_FONT_SIZE, MoonshineColor.GREY_5);
	}

	public static inline function getGreySmallTextFormat():TextFormat {
		return getTextFormat(SMALL_FONT_SIZE, MoonshineColor.GREY_5);
	}

	public static inline function getLightOnDarkSecondaryDisabledTextFormat():TextFormat {
		return getTextFormat(SECONDARY_FONT_SIZE, MoonshineColor.GREY_5);
	}
}

class TypoUtils {
	public static function clone(source:TextFormat):TextFormat {
		var tf = new TextFormat();
		tf.align = source.align;
		tf.blockIndent = source.blockIndent;
		tf.bold = source.bold;
		tf.bullet = source.bullet;
		tf.color = source.color;
		tf.display = source.display;
		tf.font = source.font;
		tf.indent = source.indent;
		tf.italic = source.italic;
		tf.kerning = source.kerning;
		tf.leading = source.leading;
		tf.leftMargin = source.leftMargin;
		tf.letterSpacing = source.letterSpacing;
		tf.rightMargin = source.rightMargin;
		tf.size = source.size;
		tf.tabStops = source.tabStops;
		tf.target = source.target;
		tf.underline = source.underline;
		tf.url = source.url;
		return tf;
	}
}