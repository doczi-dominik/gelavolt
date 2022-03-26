package game.boardstates;

import save_data.PrefsSettings;
import game.particles.ParticleManager;
import game.rules.Rule;
import game.rules.MarginTimeManager;
import game.ChainCounter;
import kha.math.Random;
import save_data.TrainingSettings;
import game.garbage.trays.GarbageTray;
import game.simulation.ChainSimulator;
import game.score.ScoreManager;
import game.simulation.ILinkInfoBuilder;
import game.geometries.BoardGeometries;
import game.garbage.GarbageManager;

@:structInit
class TrainingInfoBoardStateOptions {
	public final geometries: BoardGeometries;
	public final marginManager: MarginTimeManager;
	public final rule: Rule;
	public final rng: Random;
	public final linkBuilder: ILinkInfoBuilder;
	public final trainingSettings: TrainingSettings;
	public final chainAdvantageDisplay: GarbageTray;
	public final afterCounterDisplay: GarbageTray;
	public final autoChainCounter: ChainCounter;
	public final particleManager: ParticleManager;
	public final prefsSettings: PrefsSettings;

	public final playerScoreManager: ScoreManager;
	public final playerChainSim: ChainSimulator;

	public final garbageManager: GarbageManager;
}
