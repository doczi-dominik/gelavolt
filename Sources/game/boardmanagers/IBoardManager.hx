package game.boardmanagers;

import hxbit.Serializer;
import kha.graphics2.Graphics;

interface IBoardManager {
	public function addDesyncInfo(ctx: Serializer): Void;
	public function update(): Void;
	public function render(g: Graphics, g4: kha.graphics4.Graphics, alpha: Float): Void;
}
