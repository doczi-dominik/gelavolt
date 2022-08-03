package game.actionbuffers;

import game.mediators.RollbackMediator;
import game.mediators.FrameCounter;

@:structInit
private class LatestActionResults {
	public final frame: Int;
	public final actions: ActionSnapshot;
}

@:structInit
@:build(game.Macros.buildOptionsClass(ReceiveActionBuffer))
class ReceiveActionBufferOptions {}

class ReceiveActionBuffer implements IActionBuffer {
	@inject final frameCounter: FrameCounter;
	@inject final rollbackMediator: RollbackMediator;

	final actions: Map<Int, ActionSnapshot>;

	public function new(opts: ReceiveActionBufferOptions) {
		Macros.initFromOpts();

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
		while (frame > 0) {
			if (actions.exists(frame))
				break;

			frame--;
		}

		return actions[frame];
	}

	public function onInput(frame: Int, actions: Int) {
		trace('Received input for frame $frame on ${frameCounter.value}');

		final frameDiff = frameCounter.value - frame;
		final snapshot = ActionSnapshot.fromBitField(actions);

		if (frameDiff < 1) {
			trace('Input is for the future, saving');

			this.actions[frame] = snapshot;

			return;
		}

		trace('Input received happened $frameDiff frames ago!!');

		if (getAction(frame).isNotEqual(snapshot)) {
			trace('Inputs diverge, saving input and rolling back $frameDiff frames!');

			this.actions[frame] = snapshot;

			rollbackMediator.rollback(frame);

			return;
		}

		trace('Input are the same, skipping rollback');
	}

	public function update() {
		return getAction(frameCounter.value);
	}

	public function exportReplayData() {
		final data: ReplayData = [];

		for (k => v in actions.keyValueIterator()) {
			data[k] = v.toBitField();
		}

		return data;
	}
}
