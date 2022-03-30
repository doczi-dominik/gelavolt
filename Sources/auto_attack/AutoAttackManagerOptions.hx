package auto_attack;

import game.rules.Rule;
import game.particles.ParticleManager;
import game.ChainCounter;
import game.garbage.IGarbageManager;
import game.simulation.ILinkInfoBuilder;
import save_data.PrefsSettings;
import save_data.TrainingSettings;
import game.geometries.BoardGeometries;
import kha.math.Random;

@:structInit
class AutoAttackManagerOptions {
	public final rule: Rule;
	public final rng: Random;
	public final geometries: BoardGeometries;
	public final trainingSettings: TrainingSettings;
	public final prefsSettings: PrefsSettings;
	public final linkBuilder: ILinkInfoBuilder;
	public final garbageManager: IGarbageManager;
	public final chainCounter: ChainCounter;
	public final particleManager: ParticleManager;
}
