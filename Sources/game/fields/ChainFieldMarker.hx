package game.fields;

import kha.Font;
import kha.Assets;
import kha.graphics2.Graphics;

class ChainFieldMarker implements IFieldMarker {
	static inline final SPRITE_X = 770;
	static inline final SPRITE_Y = 455;
	static inline final FONTSIZE = 30;

	final font: Font;
	final fontHeight: Float;

	var chain: Int;
	var chainString: String;
	var fontWidth: Float;

	public final type: FieldMarkerType;

	public function new() {
		font = Assets.fonts.ka1;
		fontHeight = font.height(FONTSIZE);

		modifyChain(1);

		type = Chain;
	}

	function modifyChain(value: Int) {
		chain = value;
		chainString = '$chain';
		fontWidth = font.width(FONTSIZE, chainString);
	}

	public function copy() {
		final c = new ChainFieldMarker();

		c.chain = chain;
		c.chainString = chainString;
		c.fontWidth = fontWidth;

		return c;
	}

	public function onSet(value: IFieldMarker) {
		if (value.type == Chain) {
			modifyChain((chain + 1) % 100);
			return (this : IFieldMarker);
		}

		return value;
	}

	public function render(g: Graphics, x: Float, y: Float) {
		g.drawSubImage(Assets.images.pixel, x, y, SPRITE_X, SPRITE_Y, 64, 64);

		g.font = font;
		g.fontSize = FONTSIZE;

		g.drawString(chainString, x + 32 - fontWidth / 2, y + 32 - fontHeight / 2);
	}
}
