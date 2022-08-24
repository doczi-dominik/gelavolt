package game.screens;

import input.AnyInputDevice;
import kha.graphics2.Graphics;
import kha.System;
import kha.Font;
import game.states.GameState;
import input.IInputDevice;
import game.copying.CopyableRNG;
import game.backgrounds.NestBackground;
import kha.Assets;
import kha.math.FastMatrix3;
import game.mediators.ControlHintContainer;
import game.ui.PauseMenu;
import kha.graphics4.Graphics as Graphics4;

class GameScreenBase implements IScreen {
	static inline final CONTROLS_FONT_SIZE = 32;

	public static inline final PLAY_AREA_DESIGN_WIDTH = 1440;
	public static inline final PLAY_AREA_DESIGN_HEIGHT = 1080;

	final font: Font;

	final background: NestBackground;
	final controlHintContainer: ControlHintContainer;

	var fontSize: Int;
	var transform: FastMatrix3;

	var gameState: GameState;
	var pauseMenu: PauseMenu;

	var isPaused: Bool;

	function new() {
		font = Assets.fonts.Pixellari;

		background = new NestBackground(new CopyableRNG(Std.int(System.time * 1000000)));
		controlHintContainer = new ControlHintContainer();

		isPaused = false;

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

	function pause(inputDevice: IInputDevice) {
		pauseMenu.onShow(inputDevice);
		isPaused = true;
	}

	function resume() {
		isPaused = false;
	}

	function updatePaused() {
		pauseMenu.update();
	}

	function updateRunning() {
		background.update();
		gameState.update();
	}

	function renderGameState(g: Graphics, g4: Graphics4, alpha: Float) {
		gameState.render(g, g4, alpha);
	}

	public function dispose() {}

	public function update() {
		if (isPaused) {
			updatePaused();

			return;
		}

		updateRunning();
	}

	public function render(g: Graphics, g4: Graphics4, alpha: Float) {
		background.render(g, alpha);

		g.pushTransformation(transform);
		renderGameState(g, g4, alpha);
		g.popTransformation();

		if (controlHintContainer.isVisible) {
			g.font = font;
			g.fontSize = fontSize;
			AnyInputDevice.instance.renderControls(g, 0, ScaleManager.screen.width, 0, controlHintContainer.value.data);
		}

		if (isPaused) {
			pauseMenu.render(g, alpha);
		}
	}
}
