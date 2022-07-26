package game.particles;

import utils.Utils.pointLerp;
import kha.graphics2.Graphics;
import kha.Color;
import utils.Point;
import utils.Utils.lerp;
import game.copying.CopyableArray;

using kha.graphics2.GraphicsExtension;

@:structInit
@:build(game.Macros.buildOptionsClass(GarbageBulletParticle))
class GarbageBulletParticleOptions {}

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

	@inject final begin: Point;
	@inject final control: Point;
	@inject final target: Point;
	@inject final beginScale: Float;
	@inject final targetScale: Float;
	@inject final duration: Int;
	@inject final color: Color;
	@inject final onFinish: Void->Void;

	@copy final trailParts: CopyableArray<GarbageBulletTrailParticle>;

	@copy var prevX: Float;
	@copy var prevY: Float;

	@copy var currentX: Float;
	@copy var currentY: Float;
	@copy var t: Float;

	@copy public var isAnimationFinished(default, null): Bool;

	function new(opts: GarbageBulletParticleOptions) {
		game.Macros.initFromOpts();

		trailParts = new CopyableArray([]);
	}

	public function copy() {
		return new GarbageBulletParticle({
			begin: begin,
			control: control,
			target: target,
			beginScale: beginScale,
			targetScale: targetScale,
			duration: duration,
			color: color,
			onFinish: onFinish
		}).copyFrom(this);
	}

	public function update() {
		prevX = currentX;
		prevY = currentY;

		final m1 = pointLerp(begin, control, t);
		final m2 = pointLerp(control, target, t);

		final current = pointLerp(m1, m2, t);
		currentX = current.x;
		currentY = current.y;

		trailParts.data.push(GarbageBulletTrailParticle.create({
			x: currentX,
			y: currentY,
			color: color
		}));

		for (p in trailParts.data) {
			p.update();
		}

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

		for (p in trailParts.data) {
			p.render(g, alpha);
		}

		g.color = color;
		g.fillCircle(lerpX, lerpY, 32 * scale);
		g.color = White;
	}
}
