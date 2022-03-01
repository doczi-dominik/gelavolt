package game.boards;

import game.mediators.PauseMediator;
import game.boardstates.IBoardState;
import input.IInputDeviceManager;
import game.actionbuffers.IActionBuffer;
import kha.graphics2.Graphics;

class SingleStateBoard implements IBoard {
	final pauseMediator: PauseMediator;
	final inputManager: IInputDeviceManager;
	final actionBuffer: IActionBuffer;
	final state: IBoardState;

	public function new(opts: SingleStateBoardOptions) {
		pauseMediator = opts.pauseMediator;
		inputManager = opts.inputManager;
		actionBuffer = opts.actionBuffer;
		state = opts.state;
	}

	public function update() {
		if (inputManager.getAction(PAUSE)) {
			pauseMediator.pause(inputManager);
		}

		actionBuffer.update();
		state.update();
	}

	public function renderScissored(g: Graphics, g4: kha.graphics4.Graphics, alpha: Float) {
		state.renderScissored(g, g4, alpha);
	}

	public function renderFloating(g: Graphics, g4: kha.graphics4.Graphics, alpha: Float) {
		state.renderFloating(g, g4, alpha);
	}
}
