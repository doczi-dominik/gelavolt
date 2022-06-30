package game.states;

import game.states.GameState.GameStateOptions;
import kha.Font;
import kha.Assets;
import input.AnyInputDevice;
import kha.graphics2.Graphics;
import kha.graphics4.Graphics as Graphics4;
import game.mediators.ControlDisplayContainer;

@:structInit
@:build(game.Macros.buildOptionsClass(ControlDisplayGameState))
class ControlDisplayGameStateOptions extends GameStateOptions {}

class ControlDisplayGameState extends GameState {
	static inline final FONT_SIZE = 32;

	@inject final controlDisplayContainer: ControlDisplayContainer;
	final font: Font;

	var fontSize: Int;
	var fontHeight: Float;
	var lastIsVisible: Bool;

	public function new(opts: ControlDisplayGameStateOptions) {
		super(opts);
		game.Macros.initFromOpts();

		font = Assets.fonts.Pixellari;

		ScaleManager.addOnResizeCallback(onResize);
		lastIsVisible = controlDisplayContainer.isVisible;
	}

	function onResize() {
		fontSize = Std.int(FONT_SIZE * ScaleManager.screen.smallerScale);
		fontHeight = font.height(fontSize);
	}

	override function render(g: Graphics, g4: Graphics4, alpha: Float) {
		if (controlDisplayContainer.isVisible) {
			g.font = font;
			g.fontSize = fontSize;
			AnyInputDevice.instance.renderControls(g, 0, ScaleManager.screen.width, 0, controlDisplayContainer.value);
		}

		super.render(g, g4, alpha);
	}
}
