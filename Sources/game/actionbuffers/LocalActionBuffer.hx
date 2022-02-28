package game.actionbuffers;

import game.mediators.FrameCounter;
import game.actions.GameActions;
import input.IInputDeviceManager;
import game.screens.GameScreen;

class LocalActionBuffer implements IActionBuffer {
	final frameCounter: FrameCounter;
	final inputManager: IInputDeviceManager;
	final actions: Map<Int, ActionSnapshot>;

	public var latestAction(default, null): ActionSnapshot;

	public function new(opts: LocalActionBufferOptions) {
		frameCounter = opts.frameCounter;
		inputManager = opts.inputManager;
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
			shiftLeft: inputManager.getAction(SHIFT_LEFT),
			shiftRight: inputManager.getAction(SHIFT_RIGHT),
			rotateLeft: inputManager.getAction(ROTATE_LEFT),
			rotateRight: inputManager.getAction(ROTATE_RIGHT),
			softDrop: inputManager.getAction(SOFT_DROP),
			hardDrop: inputManager.getAction(HARD_DROP)
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
