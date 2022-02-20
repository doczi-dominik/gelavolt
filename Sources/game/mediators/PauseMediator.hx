package game.mediators;

import game.states.GameState;
import input.IInputDeviceManager;

class PauseMediator {
	public var gameState(null, default): GameState;

	public function new() {}

	public function pause(inputManager: IInputDeviceManager) {
		gameState.pause(inputManager);
	}

	public function resume() {
		gameState.resume();
	}
}
