package game.backgrounds;

import kha.Assets;
import main.ScaleManager;
import utils.Utils;
import game.copying.CopyableRNG;
import kha.graphics2.Graphics;

using utils.GraphicsExtension;

private class BackgroundParticle {
	final rng: CopyableRNG;

	var lastY = 0.0;

	var x = 0.0;
	var y = 0.0;
	var dy = 0.0;
	var t = 0;

	public function new(rng: CopyableRNG) {
		this.rng = rng;

		randomizeData();

		y += ScaleManager.screen.height / 8;
	}

	function randomizeData() {
		x = rng.data.GetFloatIn(0, ScaleManager.screen.width);
		y = ScaleManager.screen.height * rng.data.GetFloatIn(1, 1.25);
		dy = rng.data.GetFloatIn(0.5, 2);
		t = rng.data.GetIn(0, 12);

		lastY = y;
	}

	public function update() {
		if (y < -64) {
			randomizeData();
		}

		lastY = y;

		y -= dy;

		++t;
	}

	public function render(g: Graphics, alpha: Float) {
		final lerpY = Utils.lerp(lastY, y, alpha);
		final c = Math.sin(t / (dy * 50));
		final size = c * 24;

		g.pushOpacity(Math.max(c, 0));
		g.drawScaledImage(Assets.images.NestBackgroundParticle, x, lerpY, size, size);
		g.popOpacity();
	}
}

class NestBackground {
	final rng: CopyableRNG;
	final particles: Array<BackgroundParticle>;

	public function new(rng: CopyableRNG) {
		this.rng = rng;
		particles = [];

		for (x in 0...128) {
			particles.push(new BackgroundParticle(rng));
		}
	}

	public function update() {
		for (p in particles) {
			p.update();
		}
	}

	public function render(g: Graphics, alpha: Float) {
		for (p in particles) {
			p.render(g, alpha);
		}
	}
}
