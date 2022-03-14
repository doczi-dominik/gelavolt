package game.boardstates;

import save_data.IClearOnXModeContainer;
import game.randomizers.Randomizer;

@:structInit
class EndlessBoardStateOptions extends StandardBoardStateOptions {
	public final clearOnXModeContainer: IClearOnXModeContainer;
	public final randomizer: Randomizer;
}
