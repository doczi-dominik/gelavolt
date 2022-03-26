package game.boardstates;

import game.rules.MarginTimeManager;
import save_data.IClearOnXModeContainer;
import game.randomizers.Randomizer;

@:structInit
class EndlessBoardStateOptions extends StandardBoardStateOptions {
	public final clearOnXModeContainer: IClearOnXModeContainer;
	public final randomizer: Randomizer;
	public final marginManager: MarginTimeManager;
}
