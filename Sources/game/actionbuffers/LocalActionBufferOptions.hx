package game.actionbuffers;

import game.screens.GameScreen;
import input.IInputDeviceManager;

@:structInit
class LocalActionBufferOptions {
	public final gameScreen: GameScreen;
	public final inputManager: IInputDeviceManager;
}
