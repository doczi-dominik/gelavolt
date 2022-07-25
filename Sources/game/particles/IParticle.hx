package game.particles;

import kha.graphics2.Graphics;

interface IParticle /* extends ICopyFrom */ {
	public var isAnimationFinished(default, null): Bool;

	public function update(): Void;
	public function render(g: Graphics, alpha: Float): Void;
}
