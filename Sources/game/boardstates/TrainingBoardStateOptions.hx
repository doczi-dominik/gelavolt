package game.boardstates;

import save_data.TrainingSettings;
import game.randomizers.Randomizer;

@:structInit
class TrainingBoardStateOptions extends EndlessBoardStateOptions {
	public final trainingSettings: TrainingSettings;
	public final infoState: TrainingInfoBoardState;
}
