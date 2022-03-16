package game.states;

import input.IInputDevice;
import game.mediators.FrameCounter;
import game.rules.MarginTimeManager;
import game.ui.PauseMenu;
import kha.graphics4.ConstantLocation;
import game.particles.ParticleManager;
import game.boardmanagers.IBoardManager;
import kha.graphics2.Graphics;
import kha.graphics4.Graphics as Graphics4;

class GameState {
	final particleManager: ParticleManager;
	final boardManager: IBoardManager;
	final marginManager: MarginTimeManager;
	final pauseMenu: PauseMenu;
	final frameCounter: FrameCounter;

	final FADE_TO_WHITELocation: ConstantLocation;

	var isPaused: Bool;
	var pausingInputs: Null<IInputDevice>;

	public function new(opts: GameStateOptions) {
		particleManager = opts.particleManager;
		boardManager = opts.boardManager;
		marginManager = opts.marginManager;
		pauseMenu = opts.pauseMenu;
		frameCounter = opts.frameCounter;

		FADE_TO_WHITELocation = Pipelines.FADE_TO_WHITE.getConstantLocation("comp");
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

		boardManager.update();
		particleManager.update();
		marginManager.update();

		frameCounter.update();
	}

	public function renderTransformed(g: Graphics, g4: Graphics4, alpha: Float) {
		g.pipeline = Pipelines.FADE_TO_WHITE;
		g4.setPipeline(g.pipeline);
		g4.setFloat(FADE_TO_WHITELocation, 0.5 + Math.cos(frameCounter.value / 4) / 2);
		g.pipeline = null;

		particleManager.renderBackground(g, alpha);
		boardManager.render(g, g4, alpha);
		particleManager.renderForeground(g, alpha);
	}

	public function render(g: Graphics, g4: kha.graphics4.Graphics, alpha: Float) {
		if (isPaused)
			pauseMenu.render(g, alpha);
	}
}
