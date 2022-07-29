package game.gamestatebuilders;

import game.mediators.ControlHintContainer;
import game.mediators.PauseMediator;
import game.ui.PauseMenu;
import game.states.GameState;

@:allow(game.screens.IGameScreen)
interface IGameStateBuilder {
	// Write-only components set when passed to GameScreen
	public var pauseMediator(null, default): PauseMediator;
	public var controlHintContainer(null, default): ControlHintContainer;

	public var gameState(default, null): GameState;
	public var pauseMenu(default, null): PauseMenu;

	public function build(): Void;
}
