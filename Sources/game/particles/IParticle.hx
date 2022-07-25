package game.particles;

import game.copying.ICopy;
import kha.graphics2.Graphics;

interface IParticle extends ICopy {
	public var isAnimationFinished(default, null): Bool;

	public function update(): Void;
	public function render(g: Graphics, alpha: Float): Void;
}
