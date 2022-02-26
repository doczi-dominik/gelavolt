package game.screens;

import game.gamestatebuilders.EndlessGameStateBuilder;
import kha.System;
import kha.math.Random;
import game.backgrounds.NestBackground;
import game.states.GameState;
import game.gamestatebuilders.TrainingGameStateBuilder;
import kha.math.FastMatrix3;
import kha.graphics2.Graphics;
import Screen.IScreen;

class GameScreen implements IScreen {
	public static final PLAY_AREA_DESIGN_WIDTH = 1440;
	public static final PLAY_AREA_DESIGN_HEIGHT = 1080;

	public static function create(opts: GameScreenOptions) {
		final v = new GameScreen();

		ScaleManager.addOnResizeCallback(v.updateScaling);

		v.gameState = new EndlessGameStateBuilder(v).setPrimaryProfile(opts.primaryProfile)
			.setRNGSeed(opts.rngSeed)
			.setRule(opts.rule)
			.build();

		return v;
	}

	final background: NestBackground;

	var translationX: Float;
	var translationY: Float;
	var scale: Float;

	var gameState: GameState;

	public var currentFrame(get, never): Int;

	function new() {
		final seed = Std.int(System.time * 1000000);
		background = new NestBackground(new Random(seed));
	}

	function get_currentFrame() {
		return gameState.currentFrame;
	}

	function updateScaling() {
		scale = ScaleManager.smallerScale;
		translationX = (ScaleManager.width - PLAY_AREA_DESIGN_WIDTH * scale) / 2;
		translationY = (ScaleManager.height - PLAY_AREA_DESIGN_HEIGHT * scale) / 2;
	}

	public function setTransformedScissor(g: Graphics, x: Float, y: Float, w: Float, h: Float) {
		final tx = Std.int(translationX + x * scale);
		final ty = Std.int(translationY + y * scale);
		final tw = Std.int(w * scale);
		final th = Std.int(h * scale);

		g.scissor(tx, ty, tw, th);
	}

	public function update() {
		background.update();
		gameState.update();
	}

	public function render(g: Graphics, g4: kha.graphics4.Graphics, alpha: Float) {
		background.render(g);

		final transform = FastMatrix3.translation(translationX, translationY).multmat(FastMatrix3.scale(scale, scale));
		g.pushTransformation(transform);

		gameState.renderTransformed(g, g4, alpha);

		g.popTransformation();

		gameState.render(g, g4, alpha);
	}
}
