package game.particles;

import kha.graphics2.Graphics;

using kha.graphics2.GraphicsExtension;

import kha.Color;
import utils.Utils.lerp;

class GeloPopParticle implements IParticle {
	public static function create(opts: GeloPopParticleOptions) {
		final p = new GeloPopParticle(opts);

		p.lastX = opts.x;
		p.lastY = opts.y;

		p.x = opts.x;
		p.y = opts.y;
		p.dy = opts.dy;
		p.t = 0;

		p.isAnimationFinished = false;

		return p;
	}

	final dx: Float;
	final dyIncrement: Float;
	final color: Color;
	final maxT: Int;

	var lastX: Float;
	var lastY: Float;

	var x: Float;
	var y: Float;
	var dy: Float;
	var t: Int;

	public var isAnimationFinished(default, null): Bool;

	function new(opts: GeloPopParticleOptions) {
		dx = opts.dx;
		dy = opts.dy;
		dyIncrement = opts.dyIncrement;
		maxT = opts.maxT;
		color = opts.color;
	}

	public function init() {
		t = 0;
		isAnimationFinished = false;
	}

	public function update() {
		if (t >= maxT) {
			isAnimationFinished = true;
			return;
		}

		lastX = x;
		lastY = y;

		dy += dyIncrement;

		x += dx;
		y += dy;

		t++;
	}

	public function render(g: Graphics, alpha: Float) {
		final lerpedX = lerp(lastX, x, alpha);
		final lerpedY = lerp(lastY, y, alpha);

		final r = Math.min(lerp(72, 0, t / maxT), 48);

		g.color = color;
		g.pushOpacity(0.5);
		g.fillCircle(lerpedX, lerpedY, r);
		g.popOpacity();
		g.fillCircle(lerpedX, lerpedY, Math.max(r - 24, 0));
		g.color = White;
	}
}
