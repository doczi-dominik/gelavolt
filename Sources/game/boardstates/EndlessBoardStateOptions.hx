package game.boardstates;

import game.randomizers.Randomizer;
import save_data.TrainingSave;

@:structInit
class EndlessBoardStateOptions extends StandardBoardStateOptions {
	public final trainingSave: TrainingSave;
	public final randomizer: Randomizer;
}
