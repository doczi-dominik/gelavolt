package game.fields;

import kha.Font;
import kha.Assets;
import kha.graphics2.Graphics;

class ChainFieldMarker implements IFieldMarker {
	public static function create() {
		final m = new ChainFieldMarker();

		m.modifyChain(1);

		return m;
	}

	static inline final SPRITE_X = 770;
	static inline final SPRITE_Y = 455;
	static inline final FONTSIZE = 30;

	final font: Font;
	final fontHeight: Float;

	@copy var chain: Int;
	@copy var chainString: String;
	@copy var fontWidth: Float;

	public final type: FieldMarkerType;

	function new() {
		font = Assets.fonts.ka1;
		fontHeight = font.height(FONTSIZE);

		chain = 0;
		chainString = "";
		fontWidth = 0;

		type = Chain;
	}

	public function copy(): Dynamic {
		return new ChainFieldMarker().copyFrom(this);
	}

	function modifyChain(value: Int) {
		chain = value;
		chainString = '$chain';
		fontWidth = font.width(FONTSIZE, chainString);
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
