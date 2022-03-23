package game.backgrounds;

import utils.Utils;
import kha.math.Random;
import kha.graphics2.Graphics;

using kha.graphics2.GraphicsExtension;

private class BackgroundParticle {
	final rng: Random;

	var lastY: Float;

	var x: Float;
	var y: Float;
	var dy: Float;
	var t: Int;

	public function new(rng: Random) {
		this.rng = rng;

		randomizeData();

		y += ScaleManager.screen.height / 8;
	}

	function randomizeData() {
		x = rng.GetFloatIn(0, ScaleManager.screen.width);
		y = ScaleManager.screen.height * rng.GetFloatIn(1, 1.25);
		dy = rng.GetFloatIn(0.5, 2);
		t = rng.GetIn(0, 12);

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
		final r = c * 12;

		g.pushOpacity(Math.max(c, 0));
		g.color = Red;
		g.fillCircle(x, lerpY, r, 8);
		g.color = Black;
		g.fillCircle(x, lerpY, r - 4, 8);
		g.color = White;
		g.popOpacity();
	}
}

class NestBackground {
	final rng: Random;
	final particles: Array<BackgroundParticle>;

	public function new(rng: Random) {
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
