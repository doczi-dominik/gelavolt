package game.boards;

import game.boardstates.EndlessBoardState;

class EndlessBoard extends SingleStateBoard {
	final endlessState: EndlessBoardState;

	public function new(opts: EndlessBoardOptions) {
		super({
			pauseMediator: opts.pauseMediator,
			inputDevice: opts.inputDevice,
			actionBuffer: opts.actionBuffer,
			state: opts.endlessState
		});

		endlessState = opts.endlessState;
	}

	override function update() {
		if (inputDevice.getAction(QUICK_RESTART)) {
			endlessState.onLose();
		}

		super.update();
	}
}
