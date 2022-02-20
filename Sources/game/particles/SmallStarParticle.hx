package game.particles;

import kha.graphics2.Graphics;
import kha.Color;
import kha.Assets;
import kha.math.FastMatrix3;

class SmallStarParticle implements IParticle {
	public static function create(opts: SmallStarParticleOptions) {
		final p = new SmallStarParticle(opts);

		p.t = 0;

		p.isAnimationFinished = false;

		return p;
	}

	final opts: SmallStarParticleOptions;
	final x: Float;
	final y: Float;
	final color: Color;

	var t: Int;

	public var isAnimationFinished(default, null): Bool;

	function new(opts: SmallStarParticleOptions) {
		this.opts = opts;
		x = opts.x;
		y = opts.y;
		color = opts.color;

		t = 0;

		isAnimationFinished = false;
	}

	public function update() {
		if (t == 21) {
			isAnimationFinished = true;
			return;
		}

		t++;
	}

	public function render(g: Graphics, alpha: Float) {
		final calc = Math.sin(t / 10);

		g.color = color;
		g.pushTransformation(g.transformation.multmat(FastMatrix3.translation(x, y).multmat(FastMatrix3.scale(calc, calc))));
		g.pushOpacity(calc);
		g.drawSubImage(Assets.images.Particles, -32, -32, 64, 0, 64, 64);
		g.popOpacity();
		g.popTransformation();
		g.color = White;
	}
}
