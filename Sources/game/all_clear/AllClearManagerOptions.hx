package game.all_clear;

import game.mediators.BorderColorMediator;
import game.geometries.BoardGeometries;
import game.particles.ParticleManager;
import kha.math.Random;

@:structInit
class AllClearManagerOptions {
	public final rng: Random;
	public final geometries: BoardGeometries;
	public final particleManager: ParticleManager;
	public final borderColorMediator: BorderColorMediator;
}
