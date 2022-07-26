package game.garbage.trays;

import kha.graphics2.Graphics;
import game.copying.ICopy;

interface IGarbageTray extends ICopy {
	public function startAnimation(garbage: Int): Void;
	public function update(): Void;
	public function render(g: Graphics, x: Float, y: Float, alpha: Float): Void;
}
