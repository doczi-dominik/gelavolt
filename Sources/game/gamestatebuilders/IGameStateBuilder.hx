package game.gamestatebuilders;

import game.copying.ICopyFrom;
import game.mediators.ControlHintContainer;
import game.mediators.PauseMediator;
import game.ui.PauseMenu;
import game.states.GameState;
import game.mediators.SaveGameStateMediator;

interface IGameStateBuilder extends ICopyFrom {
	// Write-only components set when passed to GameScreen
	public var pauseMediator(null, default): PauseMediator;
	public var controlHintContainer(null, default): ControlHintContainer;
	public var saveGameStateMediator(null, default): SaveGameStateMediator;

	public var gameState(default, null): GameState;
	public var pauseMenu(default, null): PauseMenu;

	public function copy(): IGameStateBuilder;
	public function build(): Void;
}
