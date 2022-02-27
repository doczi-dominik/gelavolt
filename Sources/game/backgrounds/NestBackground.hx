package game.backgrounds;

import kha.math.Random;
import kha.graphics2.Graphics;

using kha.graphics2.GraphicsExtension;

private class BackgroundParticle {
	final rng: Random;

	var x: Float;
	var y: Float;
	var dy: Float;
	var t: Int;

	public function new(rng: Random) {
		this.rng = rng;

		randomizeData();

		y += ScaleManager.height / 8;
	}

	function randomizeData() {
		x = rng.GetFloatIn(0, ScaleManager.width);
		y = ScaleManager.height * rng.GetFloatIn(1, 1.25);
		dy = rng.GetFloatIn(0.5, 2);
		t = rng.GetIn(0, 12);
	}

	public function update() {
		if (y < -64) {
			randomizeData();
		}

		y -= dy;

		++t;
	}

	public function render(g: Graphics) {
		final c = Math.sin(t / (dy * 50));
		final r = c * 12;

		g.pushOpacity(Math.max(c, 0));
		g.color = Red;
		g.fillCircle(x, y, r, 8);
		g.color = Black;
		g.fillCircle(x, y, r - 4, 8);
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

	public function render(g: Graphics) {
		for (p in particles) {
			p.render(g);
		}
	}
}
