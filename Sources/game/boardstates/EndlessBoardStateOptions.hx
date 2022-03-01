package game.boardstates;

import game.randomizers.Randomizer;
import save_data.TrainingSettings;

@:structInit
class EndlessBoardStateOptions extends StandardBoardStateOptions {
	public final trainingSettings: TrainingSettings;
	public final randomizer: Randomizer;
}
