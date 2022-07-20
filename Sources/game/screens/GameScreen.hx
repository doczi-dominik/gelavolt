package game.screens;

import kha.math.FastMatrix3;
import input.IInputDevice;
import game.ui.PauseMenu;
import game.gamestatebuilders.IGameStateBuilder;
import kha.System;
import kha.math.Random;
import game.backgrounds.NestBackground;
import game.states.GameState;
import kha.graphics2.Graphics;
import Screen.IScreen;

class GameScreenOptions {}

class GameScreen implements IScreen {
	public static final PLAY_AREA_DESIGN_WIDTH = 1440;
	public static final PLAY_AREA_DESIGN_HEIGHT = 1080;

	final background: NestBackground;
	final gameState: GameState;
	final pauseMenu: PauseMenu;

	var isPaused: Bool;

	public function new(gameStateBuilder: IGameStateBuilder) {
		background = new NestBackground(new Random(Std.int(System.time * 1000000)));

		gameStateBuilder.pauseMediator = {
			pause: pause,
			resume: resume
		};

		gameStateBuilder.build();

		gameState = gameStateBuilder.gameState;
		pauseMenu = gameStateBuilder.pauseMenu;
	}

	public function pause(inputDevice: IInputDevice) {
		pauseMenu.onShow(inputDevice);
		isPaused = true;
	}

	public function resume() {
		isPaused = false;
	}

	public function update() {
		if (isPaused) {
			pauseMenu.update();
			return;
		}

		background.update();
		gameState.update();
	}

	public function render(g: Graphics, g4: kha.graphics4.Graphics, alpha: Float) {
		background.render(g, alpha);

		final scr = ScaleManager.screen;
		final scale = scr.smallerScale;
		final tlX = (scr.width - PLAY_AREA_DESIGN_WIDTH * scale) / 2;
		final tlY = (scr.height - PLAY_AREA_DESIGN_HEIGHT * scale) / 2;
		final transform = FastMatrix3.translation(tlX, tlY).multmat(FastMatrix3.scale(scale, scale));

		g.pushTransformation(transform);
		gameState.renderTransformed(g, g4, alpha);
		g.popTransformation();

		gameState.render(g, g4, alpha);

		if (isPaused) {
			pauseMenu.render(g, alpha);
		}
	}
}
