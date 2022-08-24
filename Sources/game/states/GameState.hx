package game.states;

import hxbit.Serializer;
import game.copying.ICopyFrom;
import game.mediators.FrameCounter;
import game.rules.MarginTimeManager;
import kha.graphics4.ConstantLocation;
import game.particles.ParticleManager;
import game.boardmanagers.IBoardManager;
import kha.graphics2.Graphics;
import kha.graphics4.Graphics as Graphics4;

@:structInit
@:build(game.Macros.buildOptionsClass(GameState))
class GameStateOptions {}

class GameState {
	@inject final particleManager: ParticleManager;
	@inject final frameCounter: FrameCounter;
	@inject final boardManager: IBoardManager;
	@inject final marginManager: MarginTimeManager;

	final FADE_TO_WHITELocation: ConstantLocation;

	public function new(opts: GameStateOptions) {
		game.Macros.initFromOpts();

		FADE_TO_WHITELocation = Pipelines.FADE_TO_WHITE.getConstantLocation("comp");
	}

	public function addDesyncInfo(ctx: Serializer) {
		boardManager.addDesyncInfo(ctx);
	}

	public function update() {
		boardManager.update();
		particleManager.update();
		marginManager.update();

		frameCounter.update();
	}

	public function render(g: Graphics, g4: Graphics4, alpha: Float) {
		g.pipeline = Pipelines.FADE_TO_WHITE;
		g4.setPipeline(g.pipeline);
		g4.setFloat(FADE_TO_WHITELocation, 0.5 + Math.cos(frameCounter.value / 4) / 2);
		g.pipeline = null;

		particleManager.renderBackground(g, alpha);
		boardManager.render(g, g4, alpha);
		particleManager.renderForeground(g, alpha);
	}
}
