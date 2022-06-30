package game.particles;

import kha.graphics2.Graphics;
import kha.Color;
import kha.Assets;
import kha.math.FastMatrix3;

@:structInit
@:build(game.Macros.buildOptionsClass(SmallStarParticle))
class SmallStarParticleOptions {}

class SmallStarParticle implements IParticle {
	public static function create(opts: SmallStarParticleOptions) {
		final p = new SmallStarParticle(opts);

		p.t = 0;

		p.isAnimationFinished = false;

		return p;
	}

	@inject final x: Float;
	@inject final y: Float;
	@inject final color: Color;

	var t: Int;

	public var isAnimationFinished(default, null): Bool;

	function new(opts: SmallStarParticleOptions) {
		game.Macros.initFromOpts();

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
