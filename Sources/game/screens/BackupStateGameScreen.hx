package game.screens;

import game.gamestatebuilders.IBackupGameStateBuilder;
import game.states.GameState;

class BackupStateGameScreen extends GameScreenBase {
	final stateBuilder: IBackupGameStateBuilder;

	final backupStateBuilder: IBackupGameStateBuilder;
	final backupState: GameState;

	public function new(gameStateBuilder: IBackupGameStateBuilder) {
		super();

		stateBuilder = gameStateBuilder;

		stateBuilder.controlHintContainer = controlHintContainer;

		stateBuilder.pauseMediator = {
			pause: pause,
			resume: resume
		};

		stateBuilder.saveGameStateMediator = {
			loadState: loadState,
			saveState: saveState,
		};

		stateBuilder.build();

		gameState = stateBuilder.gameState;
		pauseMenu = stateBuilder.pauseMenu;

		backupStateBuilder = gameStateBuilder.createBackupBuilder();
		backupStateBuilder.build();

		backupState = backupStateBuilder.gameState;
	}

	inline function loadState() {
		stateBuilder.copyFrom(backupStateBuilder);
	}

	inline function saveState() {
		backupStateBuilder.copyFrom(stateBuilder);
	}
}
