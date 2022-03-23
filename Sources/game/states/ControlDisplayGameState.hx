package game.states;

import kha.Font;
import kha.Assets;
import input.AnyInputDevice;
import kha.graphics2.Graphics;
import kha.graphics4.Graphics as Graphics4;
import game.mediators.ControlDisplayContainer;

class ControlDisplayGameState extends GameState {
	static inline final FONT_SIZE = 32;

	final font: Font;
	final container: ControlDisplayContainer;

	var fontSize: Int;
	var fontHeight: Float;
	var lastIsVisible: Bool;

	public function new(opts: ControlDisplayGameStateOptions) {
		super(opts);

		font = Assets.fonts.Pixellari;
		container = opts.controlDisplayContainer;

		ScaleManager.addOnResizeCallback(onResize);
		lastIsVisible = container.isVisible;
	}

	function onResize() {
		fontSize = Std.int(FONT_SIZE * ScaleManager.screen.smallerScale);
		fontHeight = font.height(fontSize);
	}

	override function render(g: Graphics, g4: Graphics4, alpha: Float) {
		if (container.isVisible) {
			g.font = font;
			g.fontSize = fontSize;
			AnyInputDevice.instance.renderControls(g, 0, ScaleManager.screen.width, 0, container.value);
		}

		super.render(g, g4, alpha);
	}
}
