package game.boards;

import input.IInputDevice;
import game.mediators.PauseMediator;
import game.actionbuffers.IActionBuffer;
import game.boardstates.IBoardState;

@:structInit
class SingleStateBoardOptions {
	public final pauseMediator: PauseMediator;
	public final inputDevice: IInputDevice;
	public final actionBuffer: IActionBuffer;
	public final state: IBoardState;
}
