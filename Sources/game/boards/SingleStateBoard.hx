package game.boards;

import input.IInputDevice;
import game.mediators.PauseMediator;
import game.boardstates.IBoardState;
import game.actionbuffers.IActionBuffer;
import kha.graphics2.Graphics;

class SingleStateBoard implements IBoard {
	final pauseMediator: PauseMediator;
	final inputDevice: IInputDevice;
	final actionBuffer: IActionBuffer;
	final state: IBoardState;

	public function new(opts: SingleStateBoardOptions) {
		pauseMediator = opts.pauseMediator;
		inputDevice = opts.inputDevice;
		actionBuffer = opts.actionBuffer;
		state = opts.state;
	}

	public function update() {
		if (inputDevice.getAction(PAUSE)) {
			pauseMediator.pause(inputDevice);
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
