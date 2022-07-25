package game.particles;

import game.copying.ICopyFrom;
import game.copying.CopyFromArray;
import kha.graphics2.Graphics;

class ParticleManager implements ICopyFrom {
	@copy final backParticles = new CopyFromArray<IParticle>([]);
	@copy final frontParticles = new CopyFromArray<IParticle>([]);

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
				backParticles.data.push(particle);
			case FRONT:
				frontParticles.data.push(particle);
		}
	}

	public function update() {
		updateArray(backParticles.data);
		updateArray(frontParticles.data);
	}

	public function renderBackground(g: Graphics, alpha: Float) {
		renderArray(g, backParticles.data, alpha);
	}

	public function renderForeground(g: Graphics, alpha: Float) {
		renderArray(g, frontParticles.data, alpha);
	}
}
