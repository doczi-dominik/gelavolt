package game.boardmanagers;

import kha.graphics2.Graphics;
import kha.graphics4.Graphics as Graphics4;

@:structInit
@:build(game.Macros.buildOptionsClass(DualBoardManager))
class DualBoardManagerOptions {}

class DualBoardManager implements IBoardManager {
	@inject final boardOne: SingleBoardManager;
	@inject final boardTwo: SingleBoardManager;

	public function new(opts: DualBoardManagerOptions) {
		game.Macros.initFromOpts();
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
