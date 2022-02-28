package game.actionbuffers;

import game.mediators.FrameCounter;
import game.screens.GameScreen;

class ReplayActionBuffer implements IActionBuffer {
	final frameCounter: FrameCounter;
	final actions: ReplayData;

	public var latestAction(default, null): ActionSnapshot;

	public function new(opts: ReplayActionBufferOptions) {
		frameCounter = opts.frameCounter;
		actions = opts.actions;

		latestAction = {
			shiftLeft: false,
			shiftRight: false,
			rotateLeft: false,
			rotateRight: false,
			softDrop: false,
			hardDrop: false
		};
	}

	public function update() {
		final current = actions[frameCounter.value];

		if (current == null)
			return;

		latestAction = ActionSnapshot.fromBitField(current);
	}

	public function exportReplayData() {
		return new ReplayData();
	}
}
