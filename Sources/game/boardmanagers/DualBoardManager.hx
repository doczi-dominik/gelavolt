package game.boardmanagers;

import kha.graphics2.Graphics;
import kha.graphics4.Graphics as Graphics4;

class DualBoardManager implements IBoardManager {
	final boardOne: SingleBoardManager;
	final boardTwo: SingleBoardManager;

	public function new(opts: DualBoardManagerOptions) {
		boardOne = opts.boardOne;
		boardTwo = opts.boardTwo;
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
