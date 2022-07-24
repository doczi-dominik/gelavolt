package game.boardmanagers;

import game.copying.ICopyFrom;
import kha.graphics2.Graphics;

interface IBoardManager extends ICopyFrom {
	public function update(): Void;
	public function render(g: Graphics, g4: kha.graphics4.Graphics, alpha: Float): Void;
}

@:keep
interface III extends IBoardManager {}
