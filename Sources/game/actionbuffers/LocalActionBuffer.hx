package game.actionbuffers;

import input.IInputDevice;
import game.mediators.FrameCounter;

class LocalActionBuffer implements IActionBuffer {
	final frameCounter: FrameCounter;
	final inputDevice: IInputDevice;
	final actions: Map<Int, ActionSnapshot>;

	public var latestAction(default, null): ActionSnapshot;

	public function new(opts: LocalActionBufferOptions) {
		frameCounter = opts.frameCounter;
		inputDevice = opts.inputDevice;
		actions = [];

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
		final currentAction: ActionSnapshot = {
			shiftLeft: inputDevice.getAction(SHIFT_LEFT),
			shiftRight: inputDevice.getAction(SHIFT_RIGHT),
			rotateLeft: inputDevice.getAction(ROTATE_LEFT),
			rotateRight: inputDevice.getAction(ROTATE_RIGHT),
			softDrop: inputDevice.getAction(SOFT_DROP),
			hardDrop: inputDevice.getAction(HARD_DROP)
		};

		if (latestAction.isNotEqual(currentAction)) {
			actions[frameCounter.value] = currentAction;

			latestAction = currentAction;
		}
	}

	public function exportReplayData() {
		final data: ReplayData = [];

		for (k => v in actions.keyValueIterator()) {
			data[k] = v.toBitField();
		}

		return data;
	}
}
