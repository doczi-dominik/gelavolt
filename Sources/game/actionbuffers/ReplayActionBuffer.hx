package game.actionbuffers;

import game.screens.GameScreen;

class ReplayActionBuffer implements IActionBuffer {
	final gameScreen: GameScreen;
	final actions: Map<Int, Int>;

	public var latestAction(default, null): ActionSnapshot;

	public function new(opts: ReplayActionBufferOptions) {
		gameScreen = opts.gameScreen;
		actions = opts.actions;

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
		final current = actions[gameScreen.currentFrame];

		if (current == null)
			return;

		latestAction = ActionSnapshot.fromBitField(current);
	}

	public function exportReplayData() {
		return new Map<Int, Int>();
	}
}
