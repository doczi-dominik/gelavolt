package game.particles;

import game.particles.GarbageBulletParticle.GarbageBulletParticleOptions;
import kha.Font;
import kha.Assets;
import kha.graphics2.Graphics;

using kha.graphics2.GraphicsExtension;

class AllClearBulletParticle extends GarbageBulletParticle {
	inline static final TEXT = "AC!";
	inline static final FONT_SIZE = 64;

	public static function create(opts: GarbageBulletParticleOptions) {
		final p = new AllClearBulletParticle(opts);

		p.currentX = 0;
		p.currentY = 0;
		p.t = 0;

		p.isAnimationFinished = false;

		p.font = Assets.fonts.ka1;
		p.halfWidth = p.font.width(FONT_SIZE, TEXT);
		p.halfHeight = p.font.height(FONT_SIZE);

		return p;
	}

	@copy var font: Font;
	@copy var halfWidth: Float;
	@copy var halfHeight: Float;

	override function copy() {
		return new AllClearBulletParticle({
			particleManager: particleManager,
			layer: layer,
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

	override function render(g: Graphics, alpha: Float) {
		g.font = font;
		g.fontSize = FONT_SIZE;
		g.color = color;

		g.fillCircle(currentX, currentY, halfWidth + 4);
		g.color = White;
		g.drawString(TEXT, currentX - halfWidth, currentY - halfHeight);
	}
}
