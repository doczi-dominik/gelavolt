package game.gelogroups;

import game.rules.Rule;
import save_data.PrefsSettings;
import game.simulation.ChainSimulator;
import game.fields.Field;
import game.score.ScoreManager;

@:structInit
class GeloGroupOptions {
	public final prefsSettings: PrefsSettings;
	public final rule: Rule;

	public final scoreManager: ScoreManager;
	public final field: Field;
	public final chainSim: ChainSimulator;
}
