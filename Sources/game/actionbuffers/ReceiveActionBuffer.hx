package game.actionbuffers;

import game.net.logger.ISessionLogger;
import game.net.InputHistoryEntry;
import game.mediators.RollbackMediator;
import game.mediators.FrameCounter;

using Safety;

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

	public var isActive = true;

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

		return actions[frame].sure();
	}

	public function onInput(history: Array<InputHistoryEntry>) {
		rollbackMediator.logger.push('Received ${history.length} inputs, last frame: ${history[history.length - 1].frame}');
		
		var shouldRollback = false;

		for (e in history) {
			final frame = e.frame;
			final frameDiff = frameCounter.value - frame;
			final snapshot = ActionSnapshot.fromBitField(e.actions);

			this.actions[frame] = snapshot;

			if (shouldRollback) {
				continue;
			}

			if (frameDiff < 1) {
				continue;
			}

			if (getAction(frame).isNotEqual(snapshot)) {
				rollbackMediator.logger.push('ROLLBACK SCHEDULED -- FROM: $frame -- LEN: $frameDiff');
				shouldRollback = true;
			}
		}


		if (shouldRollback) {
			rollbackMediator.rollback();
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
