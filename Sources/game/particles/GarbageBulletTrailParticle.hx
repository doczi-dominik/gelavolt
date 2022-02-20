package game.particles;

import kha.graphics2.Graphics;

using kha.graphics2.GraphicsExtension;

import kha.Color;
import utils.Utils.lerp;

class GarbageBulletTrailParticle implements IParticle {
	public static function create(opts: GarbageBulletTrailParticleOptions) {
		final p = new GarbageBulletTrailParticle(opts);

		p.lastT = 0;
		p.t = 0;

		p.isAnimationFinished = false;

		return p;
	}

	final x: Float;
	final y: Float;
	final color: Color;

	var lastT: Int;
	var t: Int;

	public var isAnimationFinished(default, null): Bool;

	function new(opts: GarbageBulletTrailParticleOptions) {
		x = opts.x;
		y = opts.y;
		color = opts.color;
	}

	public function update() {
		if (t == 20) {
			isAnimationFinished = true;
			return;
		}

		lastT = t;

		t++;
	}

	public function render(g: Graphics, alpha: Float) {
		final lerpT = lerp(lastT, t, alpha);
		final tt = lerpT / 20;

		final r = lerp(32, 4, tt);
		final bgOpacity = lerp(0.5, 0, tt);
		final fgOpacity = lerp(1, 0, tt);

		g.color = color;

		g.pushOpacity(bgOpacity);
		g.fillCircle(x, y, r + 16, 16);
		g.popOpacity();

		g.pushOpacity(fgOpacity);
		g.fillCircle(x, y, r, 4);
		g.popOpacity();

		g.color = White;
	}
}
