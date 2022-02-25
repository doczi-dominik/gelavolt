package game.mediators;

import input.InputDeviceManager;
import game.states.GameState;

class PauseMediator {
	public var gameState(null, default): GameState;

	public function new() {}

	public function pause(inputManager: InputDeviceManager) {
		gameState.pause(inputManager);
	}

	public function resume() {
		gameState.resume();
	}
}
