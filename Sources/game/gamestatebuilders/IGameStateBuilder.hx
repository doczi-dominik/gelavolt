package game.gamestatebuilders;

import game.mediators.ControlDisplayContainer;
import game.mediators.PauseMediator;
import game.ui.PauseMenu;
import game.states.GameState;

interface IGameStateBuilder {
	// Write-only components set when passed to GameScreen
	public var pauseMediator(null, default): PauseMediator;
	public var controlDisplayContainer(null, default): ControlDisplayContainer;

	public var gameState(default, null): GameState;
	public var pauseMenu(default, null): PauseMenu;

	public function build(): Void;
}
