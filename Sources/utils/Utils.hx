package utils;

import kha.System;
import game.copying.CopyableRNG;
import kha.graphics2.Graphics;
import kha.Color;

class Utils {
	public static final AROUND: Array<IntPoint> = [{x: 1, y: 0}, {x: -1, y: 0}, {x: 0, y: 1}, {x: 0, y: -1},];

	public static final AROUND_DIAG: Array<IntPoint> = [
		{x: 1, y: 0},
		{x: -1, y: 0},
		{x: 0, y: 1},
		{x: 0, y: -1},
		{x: -1, y: -1},
		{x: 1, y: -1},
		{x: 1, y: 1},
		{x: -1, y: 1}
	];

	public static inline function clamp(min: Float, v: Float, max: Float) {
		return Math.min(max, Math.max(v, min));
	}

	public static inline function intClamp(min: Float, v: Float, max: Float) {
		return Std.int(clamp(min, v, max));
	}

	public static inline function negativeMod(n: Float, d: Int) {
		final r = n % d;

		return (r < 0) ? r + d : r;
	}

	public static inline function lerp(min: Float, max: Float, v: Float) {
		return min + (max - min) * v;
	}

	public static inline function limitDecimals(v: Float, decimals: Int) {
		final multiplier = Math.pow(10, decimals);

		return Math.round(v * multiplier) / multiplier;
	}

	public static function pointLerp(minPoint: Point, maxPoint: Point, v: Float): Point {
		final x = lerp(minPoint.x, maxPoint.x, v);
		final y = lerp(minPoint.y, maxPoint.y, v);

		return {x: x, y: y};
	}

	public static function rgbLerp(minColor: Color, maxColor: Color, v: Float) {
		final r = lerp(minColor.R, maxColor.R, v);
		final g = lerp(minColor.G, maxColor.G, v);
		final b = lerp(minColor.B, maxColor.B, v);

		return Color.fromFloats(r, g, b);
	}

	inline public static function easeOutBack(x: Float): Float {
		final c1 = 1.70150;
		final c3 = c1 + 1;

		return 1 + c3 * Math.pow(x - 1, 3) + c1 * Math.pow(x - 1, 2);
	}

	public static function shadowDrawString(g: Graphics, size: Int, bgColor: Color, fgColor: Color, text: String, x: Float, y: Float) {
		g.color = bgColor;

		for (p in AROUND_DIAG) {
			g.drawString(text, x + p.x * size, y + p.y * size);
		}

		g.color = fgColor;
		g.drawString(text, x, y);
	}

	public static function shadowDrawCharacter(g: Graphics, size: Int, bgColor: Color, fgColor: Color, charArray: Array<Int>, x: Float, y: Float) {
		g.color = bgColor;

		for (p in AROUND_DIAG) {
			g.drawCharacters(charArray, 0, 1, x + p.x * size, y + p.y * size);
		}

		g.color = fgColor;
		g.drawCharacters(charArray, 0, 1, x, y);
	}

	public static function randomString(length: Int) {
		final rng = new CopyableRNG(Std.int(System.time * 1000000));

		final numbers = [for (x in 48...58) x];
		final uppercase = [for (x in 65...91) x];
		final lowercase = [for (x in 97...123) x];

		final ascii = numbers.concat(uppercase).concat(lowercase);

		var result = "";

		for (_ in 0...length) {
			final i = rng.data.GetUpTo(ascii.length - 1);

			result += String.fromCharCode(ascii[i]);
		}

		return result;
	}
}
