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

	public var isActive: Bool;

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

		isActive = true;
	}

	function getAction(frame: Int) {
		while (frame > 0) {
			if (actions.exists(frame))
				break;

			frame--;
		}

		return actions[frame];
	}

	public function update() {
		var latestAction = getAction(frameCounter.value);

		if (!isActive) {
			return latestAction;
		}

		final currentAction: ActionSnapshot = {
			shiftLeft: inputDevice.getAction(SHIFT_LEFT),
			shiftRight: inputDevice.getAction(SHIFT_RIGHT),
			rotateLeft: inputDevice.getAction(ROTATE_LEFT),
			rotateRight: inputDevice.getAction(ROTATE_RIGHT),
			softDrop: inputDevice.getAction(SOFT_DROP),
			hardDrop: inputDevice.getAction(HARD_DROP)
		};

		if (latestAction.isNotEqual(currentAction)) {
			actions[frameCounter.value + frameDelay] = currentAction;
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
