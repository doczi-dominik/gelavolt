package game.screens;

import input.AnyInputDevice;
import save_data.Profile;
import game.gamemodes.EndlessGameMode;
import game.gamestatebuilders.EndlessGameStateBuilder;
import game.gamemodes.IGameMode;

class ReplayScreen extends GameScreen {
	override function setGameState(gameMode: IGameMode) {
		return switch (gameMode.gameMode) {
			case ENDLESS:
				new EndlessGameStateBuilder({
					gameMode: cast(gameMode, EndlessGameMode),
					transformMediator: transformMediator,
					inputDevice: AnyInputDevice.instance
				}).build();
			default: null; // TODO: ErrorGameState or something
		}
	}
}
