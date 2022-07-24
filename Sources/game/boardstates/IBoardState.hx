package game.boardstates;

import game.copying.ICopyFrom;
import kha.graphics2.Graphics;
import kha.graphics4.Graphics as Graphics4;

interface IBoardState extends ICopyFrom {
	public function update(): Void;
	public function renderScissored(g: Graphics, g4: Graphics4, alpha: Float): Void;
	public function renderFloating(g: Graphics, g4: Graphics4, alpha: Float): Void;
}
