package game.actionbuffers;

import input.IInputDevice;
import game.mediators.FrameCounter;

@:structInit
@:build(game.Macros.buildOptionsClass(LocalActionBuffer))
class LocalActionBufferOptions {}

class LocalActionBuffer implements IActionBuffer {
	@inject final frameCounter: FrameCounter;
	@inject final inputDevice: IInputDevice;
	@inject final frameDelay: Int;

	final actions: Map<Int, ActionSnapshot>;

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

	function getAction(frame: Int) {
		while (frame-- >= 0) {
			if (actions.exists(frame))
				return actions[frame];
		}

		return actions[0];
	}

	function addAction(frame: Int, action: ActionSnapshot) {
		actions[frame + frameDelay] = action;
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

		var frame = frameCounter.value;
		var latestAction = getAction(frame);

		if (latestAction.isNotEqual(currentAction)) {
			addAction(frameCounter.value, currentAction);
			latestAction = currentAction;
		}

		return latestAction;
	}

	public function exportReplayData() {
		final data: ReplayData = [];

		for (k => v in actions.keyValueIterator()) {
			data[k] = v.toBitField();
		}

		return data;
	}
}
