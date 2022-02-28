package game.actionbuffers;

import game.mediators.FrameCounter;
import input.IInputDeviceManager;

@:structInit
class LocalActionBufferOptions {
	public final frameCounter: FrameCounter;
	public final inputManager: IInputDeviceManager;
}
