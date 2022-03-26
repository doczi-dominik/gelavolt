package game.boards;

import game.actionbuffers.IActionBuffer;
import input.IInputDevice;
import game.mediators.PauseMediator;
import game.boardstates.EndlessBoardState;

@:structInit
class EndlessBoardOptions {
	public final pauseMediator: PauseMediator;
	public final inputDevice: IInputDevice;
	public final actionBuffer: IActionBuffer;
	public final endlessState: EndlessBoardState;
}
