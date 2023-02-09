package game.particles;

import kha.Assets;
import utils.Utils.pointLerp;
import kha.graphics2.Graphics;
import kha.Color;
import utils.Point;
import utils.Utils.lerp;
import game.copying.CopyableArray;
import kha.Font;

using utils.GraphicsExtension;

@:structInit
@:build(game.Macros.buildOptionsClass(GarbageBulletParticle))
class GarbageBulletParticleOptions {}

class GarbageBulletParticle implements IParticle {
	inline static final TEXT = "AC!";
	inline static final FONT_SIZE = 48;

	public static function create(opts: GarbageBulletParticleOptions) {
		final p = new GarbageBulletParticle(opts);

		final begin = opts.begin;

		p.prevX = begin.x;
		p.prevY = begin.y;

		p.currentX = begin.x;
		p.currentY = begin.y;
		p.t = 0;

		p.font = Assets.fonts.ka1;
		p.halfWidth = p.font.width(FONT_SIZE, TEXT) / 2;
		p.halfHeight = p.font.height(FONT_SIZE) / 2;

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
	@inject final sendsAllClearBonus: Bool;

	@copy final trailParts: CopyableArray<GarbageBulletTrailParticle>;

	@copy var prevX: Float;
	@copy var prevY: Float;

	@copy var currentX: Float;
	@copy var currentY: Float;
	@copy var t: Float;
	@copy var onFinishCalled: Bool;

	@copy var font: Font;
	@copy var halfWidth: Float;
	@copy var halfHeight: Float;

	@copy public var isAnimationFinished(default, null): Bool;

	function new(opts: GarbageBulletParticleOptions) {
		game.Macros.initFromOpts();

		if (sendsAllClearBonus) {
			color = Orange;
		}

		trailParts = new CopyableArray([]);

		onFinishCalled = false;
	}

	public function copy(): Dynamic {
		return new GarbageBulletParticle({
			begin: begin,
			control: control,
			target: target,
			beginScale: beginScale,
			targetScale: targetScale,
			duration: duration,
			color: color,
			onFinish: onFinish,
			sendsAllClearBonus: sendsAllClearBonus
		}).copyFrom(this);
	}

	public function update() {
		prevX = currentX;
		prevY = currentY;

		if (t < 1) {
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

			t += 1 / duration;
		} else {
			if (!onFinishCalled) {
				onFinish();
				onFinishCalled = true;
			}

			if (trailParts.data.length == 0) {
				isAnimationFinished = true;
			}
		}

		for (p in trailParts.data) {
			p.update();

			if (p.isAnimationFinished) {
				trailParts.data.remove(p);
			}
		}
	}

	public function render(g: Graphics, alpha: Float) {
		for (p in trailParts.data) {
			p.render(g, alpha);
		}

		if (t >= 1) {
			return;
		}

		final scale = lerp(beginScale, targetScale, t);

		final lerpX = lerp(prevX, currentX, alpha);
		final lerpY = lerp(prevY, currentY, alpha);

		g.color = color;
		g.fillCircle(lerpX, lerpY, 32 * scale);
		g.color = White;

		if (sendsAllClearBonus) {
			g.font = font;
			g.fontSize = FONT_SIZE;
			g.color = White;

			g.drawString(TEXT, lerpX - halfWidth, lerpY - halfHeight);
		}
	}
}
