package game.screens;

import game.gamestatebuilders.IGameStateBuilder;

class GameScreen extends GameScreenBase {
	public function new(gameStateBuilder: IGameStateBuilder) {
		super();

		gameStateBuilder.controlHintContainer = controlHintContainer;
		gameStateBuilder.pauseMediator = {
			pause: pause,
			resume: resume
		};

		gameStateBuilder.build();

		gameState = gameStateBuilder.gameState;
		pauseMenu = gameStateBuilder.pauseMenu;
	}
}
