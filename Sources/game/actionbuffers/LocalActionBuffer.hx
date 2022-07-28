package game.actionbuffers;

import input.IInputDevice;
import game.mediators.FrameCounter;

@:structInit
@:build(game.Macros.buildOptionsClass(LocalActionBuffer))
class LocalActionBufferOptions {}

class LocalActionBuffer implements IActionBuffer {
	@inject final frameCounter: FrameCounter;
	@inject final inputDevice: IInputDevice;
	final actions: Map<Int, ActionSnapshot>;

	public var latestAction(get, never): ActionSnapshot;

	public function new(opts: LocalActionBufferOptions) {
		game.Macros.initFromOpts();

		actions = [
			0 => {
				shiftLeft: false,
				shiftRight: false,
				rotateLeft: false,
				rotateRight: false,
				softDrop: false,
				hardDrop: false
			}
		];
	}

	function get_latestAction() {
		var frame = frameCounter.value;

		while (frame-- >= 0) {
			if (actions.exists(frame))
				return actions[frame];
		}

		return actions[0];
	}

	function addAction(frame: Int, action: ActionSnapshot) {
		actions[frame] = action;
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
			addAction(frameCounter.value, currentAction);
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
