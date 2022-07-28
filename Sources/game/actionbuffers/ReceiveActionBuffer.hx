package game.actionbuffers;

import game.mediators.FrameCounter;
import game.net.SessionManager;

@:structInit
@:build(game.Macros.buildOptionsClass(ReceiveActionBuffer))
class ReceiveActionBufferOptions {}

class ReceiveActionBuffer implements IActionBuffer {
	@inject final frameCounter: FrameCounter;
	@inject final session: SessionManager;
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

		session.onInput = onInput;
	}

	function onInput(frame: Int, actions: Int) {
		final snapshot = ActionSnapshot.fromBitField(actions);

		this.actions[frame] = snapshot;
	}

	public function update() {
		var frame = frameCounter.value;

		while (frame-- >= 0) {
			if (actions.exists(frame))
				return actions[frame];
		}

		return actions[0];
	}

	public function exportReplayData() {
		final data: ReplayData = [];

		for (k => v in actions.keyValueIterator()) {
			data[k] = v.toBitField();
		}

		return data;
	}
}
