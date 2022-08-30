package game.actionbuffers;

import game.net.InputHistoryEntry;
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

	public var isActive: Bool;

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

	public function onInput(history: Array<InputHistoryEntry>) {
		// trace('Received ${history.length} inputs on ${frameCounter.value}');

		var rollbackTo: Null<Int> = null;

		for (e in history) {
			final frame = e.frame;
			final frameDiff = frameCounter.value - frame;
			final snapshot = ActionSnapshot.fromBitField(e.actions);

			this.actions[frame] = snapshot;

			if (frameDiff < 1) {
				continue;
			}

			if (rollbackTo != null) {
				continue;
			}

			if (getAction(frame).isNotEqual(snapshot)) {
				// trace('Inputs diverge, scheduling $frameDiff frame rollback to $frame!');
				rollbackTo = frame;
			}
		}

		if (rollbackTo != null) {
			// trace('Executing rollback');
			rollbackMediator.rollback(rollbackTo);
		}
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
