package game.boards;

import game.mediators.PauseMediator;
import input.IInputDeviceManager;
import game.actionbuffers.IActionBuffer;
import game.boardstates.IBoardState;

@:structInit
class SingleStateBoardOptions {
	public final pauseMediator: PauseMediator;
	public final inputManager: IInputDeviceManager;
	public final actionBuffer: IActionBuffer;
	public final state: IBoardState;
}
