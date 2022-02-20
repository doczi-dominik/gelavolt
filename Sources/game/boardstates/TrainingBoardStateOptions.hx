package game.boardstates;

import game.randomizers.Randomizer;
import save_data.TrainingSave;

@:structInit
class TrainingBoardStateOptions extends StandardBoardStateOptions {
	public final infoState: TrainingInfoBoardState;
	public final trainingSave: TrainingSave;
	public final randomizer: Randomizer;
}
