package game.actionbuffers;

import input.IInputDevice;
import game.mediators.FrameCounter;

@:structInit
class LocalActionBufferOptions {
	public final frameCounter: FrameCounter;
	public final inputDevice: IInputDevice;
}
