package game.boards;

import game.copying.ICopyFrom;
import input.IInputDevice;
import game.actionbuffers.IActionBuffer;
import kha.graphics2.Graphics;
import kha.graphics4.Graphics as Graphics4;

interface IBoard extends ICopyFrom {
	private final inputDevice: IInputDevice;

	// ActionBuffers must be updated in Boards to allow calling a BoardState's
	// update() method without affecting the actionbuffer e.g. for rollbacks
	private final playActionBuffer: IActionBuffer;

	public function update(): Void;
	public function renderScissored(g: Graphics, g4: Graphics4, alpha: Float): Void;
	public function renderFloating(g: Graphics, g4: Graphics4, alpha: Float): Void;
}
