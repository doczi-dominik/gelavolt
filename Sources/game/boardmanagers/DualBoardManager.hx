package game.boardmanagers;

import hxbit.Serializer;
import kha.graphics2.Graphics;
import kha.graphics4.Graphics as Graphics4;

@:structInit
@:build(game.Macros.buildOptionsClass(DualBoardManager))
class DualBoardManagerOptions {}

class DualBoardManager implements IBoardManager {
	@inject final doesBoardOneHavePriority: Bool;
	@inject final boardOne: SingleBoardManager;
	@inject final boardTwo: SingleBoardManager;

	public function new(opts: DualBoardManagerOptions) {
		game.Macros.initFromOpts();
	}

	public function addDesyncInfo(ctx: Serializer) {
		if (doesBoardOneHavePriority) {
			boardOne.addDesyncInfo(ctx);
			boardTwo.addDesyncInfo(ctx);
		} else {
			boardTwo.addDesyncInfo(ctx);
			boardOne.addDesyncInfo(ctx);
		}
	}

	public function update() {
		boardOne.update();
		boardTwo.update();
	}

	public function render(g: Graphics, g4: Graphics4, alpha: Float) {
		boardOne.render(g, g4, alpha);
		boardTwo.render(g, g4, alpha);
	}
}
