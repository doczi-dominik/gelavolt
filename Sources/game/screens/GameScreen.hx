package game.screens;

import input.AnyInputDevice;
import kha.Assets;
import kha.Font;
import game.mediators.ControlHintContainer;
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
	static inline final CONTROLS_FONT_SIZE = 32;

	public static inline final PLAY_AREA_DESIGN_WIDTH = 1440;
	public static inline final PLAY_AREA_DESIGN_HEIGHT = 1080;

	final font: Font;

	final background: NestBackground;
	final gameState: GameState;
	final pauseMenu: PauseMenu;
	final controlDisplayContainer: ControlHintContainer;

	var fontSize: Int;
	var transform: FastMatrix3;

	var isPaused: Bool;

	public function new(gameStateBuilder: IGameStateBuilder) {
		font = Assets.fonts.Pixellari;

		background = new NestBackground(new Random(Std.int(System.time * 1000000)));
		controlDisplayContainer = new ControlHintContainer();

		gameStateBuilder.pauseMediator = {
			pause: pause,
			resume: resume
		};

		gameStateBuilder.controlDisplayContainer = controlDisplayContainer;

		gameStateBuilder.build();

		gameState = gameStateBuilder.gameState;
		pauseMenu = gameStateBuilder.pauseMenu;

		ScaleManager.addOnResizeCallback(onResize);
	}

	function onResize() {
		final scr = ScaleManager.screen;
		final scale = scr.smallerScale;
		final tlX = (scr.width - PLAY_AREA_DESIGN_WIDTH * scale) / 2;
		final tlY = (scr.height - PLAY_AREA_DESIGN_HEIGHT * scale) / 2;

		fontSize = Std.int(CONTROLS_FONT_SIZE * scale);
		transform = FastMatrix3.translation(tlX, tlY).multmat(FastMatrix3.scale(scale, scale));
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

		g.pushTransformation(transform);
		gameState.render(g, g4, alpha);
		g.popTransformation();

		if (controlDisplayContainer.isVisible) {
			g.font = font;
			g.fontSize = fontSize;
			AnyInputDevice.instance.renderControls(g, 0, ScaleManager.screen.width, 0, controlDisplayContainer.value);
		}

		if (isPaused) {
			pauseMenu.render(g, alpha);
		}
	}
}
