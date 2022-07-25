package game.particles;

import kha.graphics2.Graphics;

using kha.graphics2.GraphicsExtension;

import kha.Color;
import utils.Utils.lerp;

@:structInit
@:build(game.Macros.buildOptionsClass(GeloPopParticle))
class GeloPopParticleOptions {}

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

	@inject final dx: Float;
	@inject final dyIncrement: Float;
	@inject final color: Color;
	@inject final maxT: Int;

	@inject @copy var x: Float;
	@inject @copy var y: Float;
	@inject @copy var dy: Float;

	@copy var lastX: Float;
	@copy var lastY: Float;
	@copy var t: Int;

	@copy public var isAnimationFinished(default, null): Bool;

	function new(opts: GeloPopParticleOptions) {
		game.Macros.initFromOpts();
	}

	public function copy() {
		return new GeloPopParticle({
			dx: dx,
			dyIncrement: dyIncrement,
			color: color,
			maxT: maxT,
			x: x,
			y: y,
			dy: dy
		}).copyFrom(this);
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
