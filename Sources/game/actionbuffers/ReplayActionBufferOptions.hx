package game.actionbuffers;

import game.mediators.FrameCounter;

@:structInit
class ReplayActionBufferOptions {
	public final frameCounter: FrameCounter;
	public final actions: ReplayData;
}
