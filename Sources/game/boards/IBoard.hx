package game.boards;

import game.actionbuffers.IActionBuffer;
import input.IInputDeviceManager;
import kha.graphics2.Graphics;
import kha.graphics4.Graphics as Graphics4;

interface IBoard {
	private final inputManager: IInputDeviceManager;

	// ActionBuffers must be updated in Boards to allow calling a BoardState's
	// update() method without affecting the actionbuffer e.g. for rollbacks
	private final actionBuffer: IActionBuffer;

	public function update(): Void;
	public function renderScissored(g: Graphics, g4: Graphics4, alpha: Float): Void;
	public function renderFloating(g: Graphics, g4: Graphics4, alpha: Float): Void;
}
