package game.particles;

import kha.graphics2.Graphics;

interface IParticleManager {
	public function add(layer: ParticleLayer, particle: IParticle): Void;

	public function update(): Void;
	public function renderBackground(g: Graphics, alpha: Float): Void;
	public function renderForeground(g: Graphics, alpha: Float): Void;
}
