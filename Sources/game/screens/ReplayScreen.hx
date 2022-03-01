package game.screens;

import save_data.Profile;
import input.InputDeviceManager;
import game.gamemodes.EndlessGameMode;
import game.gamestatebuilders.EndlessGameStateBuilder;
import game.gamemodes.IGameMode;

class ReplayScreen extends GameScreen {
	final inputManager: InputDeviceManager;

	public function new(gameMode: IGameMode) {
		inputManager = new InputDeviceManager(Profile.primary.inputSettings, KEYBOARD);

		super(gameMode);
	}

	override function setGameState(gameMode: IGameMode) {
		return switch (gameMode.gameMode) {
			case ENDLESS:
				new EndlessGameStateBuilder({
					gameMode: cast(gameMode, EndlessGameMode),
					transformMediator: transformMediator,
					inputManager: inputManager
				}).build();
			default: null; // TODO: ErrorGameState or something
		}
	}
}
