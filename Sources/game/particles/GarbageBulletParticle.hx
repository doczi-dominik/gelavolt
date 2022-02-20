package game.particles;

import utils.Utils.pointLerp;
import kha.graphics2.Graphics;
import kha.Color;
import utils.Point;
import utils.Utils.lerp;

using kha.graphics2.GraphicsExtension;

class GarbageBulletParticle implements IParticle {
	public static function create(opts: GarbageBulletParticleOptions) {
		final p = new GarbageBulletParticle(opts);

		final begin = opts.begin;

		p.prevX = begin.x;
		p.prevY = begin.y;

		p.currentX = begin.x;
		p.currentY = begin.y;
		p.t = 0;

		p.isAnimationFinished = false;

		return p;
	}

	final particleManager: IParticleManager;
	final layer: ParticleLayer;

	final begin: Point;
	final control: Point;
	final target: Point;
	final beginScale: Float;
	final targetScale: Float;
	final duration: Int;
	final color: Color;
	final onFinish: Void->Void;

	var prevX: Float;
	var prevY: Float;

	var currentX: Float;
	var currentY: Float;
	var t: Float;

	public var isAnimationFinished(default, null): Bool;

	function new(opts: GarbageBulletParticleOptions) {
		particleManager = opts.particleManager;
		layer = opts.layer;

		begin = opts.begin;
		control = opts.control;
		target = opts.target;
		beginScale = opts.beginScale;
		targetScale = opts.targetScale;
		duration = opts.duration;
		color = opts.color;
		onFinish = opts.onFinish;
	}

	public function update() {
		prevX = currentX;
		prevY = currentY;

		final m1 = pointLerp(begin, control, t);
		final m2 = pointLerp(control, target, t);

		final current = pointLerp(m1, m2, t);
		currentX = current.x;
		currentY = current.y;

		particleManager.add(layer, GarbageBulletTrailParticle.create({
			x: currentX,
			y: currentY,
			color: color
		}));

		t += 1 / duration;

		if (t >= 1) {
			onFinish();
			isAnimationFinished = true;
		}
	}

	public function render(g: Graphics, alpha: Float) {
		final scale = lerp(beginScale, targetScale, t);

		final lerpX = lerp(prevX, currentX, alpha);
		final lerpY = lerp(prevY, currentY, alpha);

		g.color = color;
		g.fillCircle(lerpX, lerpY, 32 * scale);
		g.color = White;
	}
}
