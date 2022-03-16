package game.boards;

import game.mediators.ControlDisplayContainer;
import input.IInputDevice;
import game.mediators.PauseMediator;
import game.boardstates.TrainingBoardState;
import game.boardstates.TrainingInfoBoardState;
import game.boardstates.EditingBoardState;
import game.actionbuffers.IActionBuffer;

@:structInit
class TrainingBoardOptions {
	public final pauseMediator: PauseMediator;
	public final inputDevice: IInputDevice;
	public final playActionBuffer: IActionBuffer;
	public final infoState: TrainingInfoBoardState;
	public final controlDisplayContainer: ControlDisplayContainer;

	public final playState: TrainingBoardState;
	public final editState: EditingBoardState;
}
