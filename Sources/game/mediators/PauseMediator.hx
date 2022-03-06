package game.mediators;

import input.IInputDevice;
import game.states.GameState;

class PauseMediator {
	public var gameState(null, default): GameState;

	public function new() {}

	public function pause(inputDevice: IInputDevice) {
		gameState.pause(inputDevice);
	}

	public function resume() {
		gameState.resume();
	}
}
