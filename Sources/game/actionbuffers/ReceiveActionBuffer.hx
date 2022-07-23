package game.actionbuffers;

import game.net.SessionManager;

@:structInit
@:build(game.Macros.buildOptionsClass(ReceiveActionBuffer))
class ReceiveActionBufferOptions {}

class ReceiveActionBuffer implements IActionBuffer {
	@inject final session: SessionManager;
	final actions: Map<Int, ActionSnapshot>;

	public var latestAction(default, null): ActionSnapshot;

	public function new(opts: ReceiveActionBufferOptions) {
		Macros.initFromOpts();

		actions = [];

		latestAction = {
			shiftLeft: false,
			shiftRight: false,
			rotateLeft: false,
			rotateRight: false,
			softDrop: false,
			hardDrop: false
		};

		session.onInput = onInput;
	}

	function onInput(frame: Int, actions: Int) {
		final snapshot = ActionSnapshot.fromBitField(actions);

		this.actions[frame] = snapshot;
		latestAction = snapshot;
	}

	public function update() {}

	public function exportReplayData() {
		final data: ReplayData = [];

		for (k => v in actions.keyValueIterator()) {
			data[k] = v.toBitField();
		}

		return data;
	}
}
