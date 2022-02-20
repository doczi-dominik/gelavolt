package game.simulation;

import kha.Assets;
import game.geometries.BoardGeometries;
import kha.Color;
import kha.graphics2.Graphics;
import game.fields.Field;

class SimulationStep {
	public static inline final LABEL_SIZE = 64;
	public static inline final CARD_SIZE = 512;
	public static inline final TITLE_FONT_SIZE = 40;
	public static inline final CARD_FONT_SIZE = 32;

	public final type: SimulationStepType;
	public final chain: Int;
	public final fieldSnapshot: Field;

	function new(type: SimulationStepType, opts: SimulationStepOptions) {
		this.type = type;
		chain = opts.chain;
		fieldSnapshot = opts.fieldSnapshot;
	}

	final function cardRow(row: Int) {
		final f = Assets.fonts.Pixellari;

		return f.height(TITLE_FONT_SIZE) + f.height(CARD_FONT_SIZE) * row;
	}

	final function renderBackground(g: Graphics, y: Float, color: Color, size: Int) {
		g.color = color;
		g.fillRect(0, y, BoardGeometries.WIDTH, size);
		g.pushOpacity(0.75);
		g.color = Black;
		g.fillRect(0, y + 4, BoardGeometries.WIDTH, size - 8);
		g.color = White;
		g.popOpacity();
	}

	final function renderTitle(g: Graphics, y: Float, title: String) {
		g.fontSize = TITLE_FONT_SIZE;
		g.drawString(title, 12, y + 12);
	}

	public function renderLabel(g: Graphics, y: Float, alpha: Float) {}

	public function renderCard(g: Graphics, y: Float, alpha: Float) {}
}
