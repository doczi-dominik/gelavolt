package game.boards;

import game.mediators.PauseMediator;
import game.boardstates.TrainingBoardState;
import game.boardstates.TrainingInfoBoardState;
import game.boardstates.EditingBoardState;
import game.actionbuffers.IActionBuffer;
import input.IInputDeviceManager;

@:structInit
class TrainingBoardOptions {
	public final pauseMediator: PauseMediator;
	public final inputManager: IInputDeviceManager;
	public final playActionBuffer: IActionBuffer;
	public final infoState: TrainingInfoBoardState;

	public final playState: TrainingBoardState;
	public final editState: EditingBoardState;
}
