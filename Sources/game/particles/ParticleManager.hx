package game.particles;

import kha.graphics2.Graphics;

class ParticleManager {
	final backParticles: Array<IParticle> = [];
	final frontParticles: Array<IParticle> = [];

	public function new() {}

	function updateArray(arr: Array<IParticle>) {
		// Reverse-iterate to remove elements mid-iteration
		var i = arr.length;
		while (--i >= 0) {
			final p = arr[i];

			p.update();

			if (p.isAnimationFinished) {
				arr.splice(i, 1);
			}
		}
	}

	function renderArray(g: Graphics, arr: Array<IParticle>, alpha: Float) {
		for (p in arr) {
			p.render(g, alpha);
		}
	}

	public function add(layer: ParticleLayer, particle: IParticle) {
		switch (layer) {
			case BACK:
				backParticles.push(particle);
			case FRONT:
				frontParticles.push(particle);
		}
	}

	public function update() {
		updateArray(backParticles);
		updateArray(frontParticles);
	}

	public function renderBackground(g: Graphics, alpha: Float) {
		renderArray(g, backParticles, alpha);
	}

	public function renderForeground(g: Graphics, alpha: Float) {
		renderArray(g, frontParticles, alpha);
	}
}
