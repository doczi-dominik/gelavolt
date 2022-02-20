package game.particles;

import kha.Color;
import utils.Point;

@:structInit
class GarbageBulletParticleOptions {
	public final particleManager: IParticleManager;
	public final layer: ParticleLayer;

	public final begin: Point;
	public final control: Point;
	public final target: Point;
	public final beginScale: Float;
	public final targetScale: Float;
	public final duration: Int;
	public final color: Color;
	public final onFinish: Void->Void;
}
