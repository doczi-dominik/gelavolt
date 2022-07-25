package game;

import game.copying.ICopyFrom;
import kha.math.FastMatrix3;
import kha.graphics2.Graphics;
import kha.Assets;
import kha.Font;
import kha.Color;
import utils.Point;
import utils.Utils.lerp;
import utils.Utils.shadowDrawString;

private enum abstract InnerState(Int) {
	final IDLE = 0;
	final ANIMATING;
}

class ChainCounter implements ICopyFrom {
	static final NUMBER_FONTSIZE = 96;

	static final TEXT = "-CHAIN!";
	static final TEXT_FONTSIZE = 48;

	static final POWERED_COLOR = Color.fromValue(0xFFFF1744);

	final numberFont: Font;
	final numberHeight: Float;

	final textFont: Font;
	final textWidth: Float;

	@copy var x: Float;
	@copy var y: Float;

	@copy var number: String;
	@copy var numberColor: Color;

	@copy var numberWidth: Float;
	@copy var totalHalfWidth: Float;

	@copy var t: Int;

	@copy var state: InnerState;

	public function new() {
		numberFont = Assets.fonts.superstar_memesbruh03;
		numberHeight = numberFont.height(NUMBER_FONTSIZE);

		textFont = Assets.fonts.DigitalDisco;
		textWidth = textFont.width(TEXT_FONTSIZE, TEXT);

		state = IDLE;
	}

	function updateAnimation() {
		if (t == 60) {
			state = IDLE;
			return;
		}

		t++;
	}

	function renderAnimation(g: Graphics, alpha: Float) {
		final alphaT = lerp(t - 1, t, alpha);

		final scale = Math.min(1, Math.sin(alphaT / 25) * 4);
		final textLength = Std.int(lerp(0, TEXT.length, Math.max(0, alphaT - 15) / 20));
		final numberYOffset = Math.pow(1.2, Math.max(0, alphaT - 38));
		final textYOffset = Math.pow(1.2, Math.max(0, alphaT - 40));

		final transform = FastMatrix3.translation(x, y).multmat(FastMatrix3.scale(1, scale));

		g.pushTransformation(g.transformation.multmat(transform));
		g.pushOpacity(Math.sin(alphaT / 20));

		// Number
		g.font = numberFont;
		g.fontSize = NUMBER_FONTSIZE;
		shadowDrawString(g, 4, Black, numberColor, number, -totalHalfWidth, -numberHeight - numberYOffset + 20);

		// Text
		g.font = textFont;
		g.fontSize = TEXT_FONTSIZE;
		shadowDrawString(g, 4, Black, White, TEXT.substr(0, textLength), -totalHalfWidth + numberWidth, -numberHeight / 2 - textYOffset);

		g.popOpacity();
		g.popTransformation();
		g.color = White;
	}

	public function startAnimation(chain: Int, begin: Point, isPowerful: Bool) {
		x = begin.x;
		y = begin.y;

		if (isPowerful) {
			number = 'P${chain}';
			numberColor = POWERED_COLOR;
		} else {
			number = '${chain}';
			numberColor = Yellow;
		}

		numberWidth = numberFont.width(NUMBER_FONTSIZE, number);
		totalHalfWidth = (numberWidth + textWidth) / 2;

		t = 0;

		state = ANIMATING;
	}

	public function update() {
		switch (state) {
			case IDLE:
			case ANIMATING:
				updateAnimation();
		}
	}

	public function render(g: Graphics, alpha: Float) {
		switch (state) {
			case IDLE:
			case ANIMATING:
				renderAnimation(g, alpha);
		}
	}
}
