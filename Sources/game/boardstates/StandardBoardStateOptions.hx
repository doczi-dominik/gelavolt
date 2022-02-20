package game.boardstates;

import game.rules.Rule;
import save_data.PrefsSave;
import game.Queue;
import game.gelogroups.GeloGroup;
import game.screens.GameScreen;
import game.ChainCounter;
import game.simulation.ChainSimulator;
import game.actionbuffers.IActionBuffer;
import game.geometries.BoardGeometries;
import game.fields.Field;
import game.garbage.IGarbageManager;
import game.previews.IPreview;
import game.all_clear.AllClearManager;
import game.score.ScoreManager;
import game.particles.IParticleManager;
import kha.math.Random;

@:structInit
class StandardBoardStateOptions {
	public final rule: Rule;
	public final prefsSave: PrefsSave;

	public final gameScreen: GameScreen;
	public final rng: Random;
	public final geometries: BoardGeometries;
	public final particleManager: IParticleManager;

	public final geloGroup: GeloGroup;
	public final queue: Queue;
	public final preview: IPreview;
	public final allClearManager: AllClearManager;
	public final scoreManager: ScoreManager;
	public final actionBuffer: IActionBuffer;
	public final chainCounter: ChainCounter;
	public final chainSim: ChainSimulator;
	public final field: Field;
	public final garbageManager: IGarbageManager;
}
