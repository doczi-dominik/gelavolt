package game.garbage;

import kha.math.Random;
import game.mediators.GarbageTargetMediator;
import save_data.PrefsSettings;
import game.garbage.trays.GarbageTray;
import game.geometries.BoardGeometries;
import game.boardmanagers.IBoardManager;
import game.particles.ParticleManager;
import game.rules.Rule;

@:structInit
class GarbageManagerOptions {
	public final rule: Rule;
	public final rng: Random;
	public final prefsSettings: PrefsSettings;
	public final particleManager: ParticleManager;
	public final geometries: BoardGeometries;
	public final tray: GarbageTray;
	public final target: GarbageTargetMediator;
}
