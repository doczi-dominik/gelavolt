package game.boards;

import game.mediators.PauseMediator;
import game.boardstates.TrainingBoardState;
import game.boardstates.TrainingInfoBoardState;
import game.boardstates.EditingBoardState;
import game.actionbuffers.IActionBuffer;
import input.IInputDeviceManager;
import kha.graphics2.Graphics;
import kha.graphics4.Graphics as Graphics4;
import game.boardstates.IBoardState;

class TrainingBoard implements IBoard {
	final pauseMediator: PauseMediator;
	final inputManager: IInputDeviceManager;
	final actionBuffer: IActionBuffer;
	final infoState: TrainingInfoBoardState;

	final playState: TrainingBoardState;
	final editState: EditingBoardState;

	var activeState: IBoardState;

	public function new(opts: TrainingBoardOptions) {
		pauseMediator = opts.pauseMediator;
		inputManager = opts.inputManager;
		actionBuffer = opts.playActionBuffer;
		infoState = opts.infoState;

		playState = opts.playState;
		editState = opts.editState;

		activeState = playState;
	}

	function changeToEdit() {
		editState.loadStep();

		infoState.showChainSteps();

		activeState = editState;
	}

	function changeToGame() {
		playState.resume();

		infoState.hideChainSteps();

		activeState = playState;
	}

	public function getField() {
		if (activeState == playState) {
			return playState.getField();
		}

		return editState.field;
	}

	public function clearField() {
		// Calling only the active one avoids modifying the ChainSimulator
		// state twice. When the activeState gets swapped, they will read the
		// ChainSimulator anyway.
		if (activeState == playState) {
			playState.clearField();
		} else {
			editState.clearField();
		}
	}

	public function update() {
		if (inputManager.getAction(PAUSE)) {
			pauseMediator.pause(inputManager);
		}

		if (inputManager.getAction(TOGGLE_EDIT_MODE)) {
			if (activeState == playState) {
				changeToEdit();
			} else {
				changeToGame();
			}
		}

		if (activeState == playState) {
			if (inputManager.getAction(PREVIOUS_STEP)) {
				playState.previousGroup();
			} else if (inputManager.getAction(NEXT_STEP)) {
				playState.nextGroup();
			}
		} else {
			if (inputManager.getAction(PREVIOUS_STEP)) {
				editState.viewPrevious();
				infoState.onViewChainStep();
			} else if (inputManager.getAction(NEXT_STEP)) {
				editState.viewNext();
				infoState.onViewChainStep();
			}
		}

		actionBuffer.update();
		activeState.update();
	}

	public function renderScissored(g: Graphics, g4: Graphics4, alpha: Float) {
		activeState.renderScissored(g, g4, alpha);
	}

	public function renderFloating(g: Graphics, g4: Graphics4, alpha: Float) {
		activeState.renderFloating(g, g4, alpha);
	}
}
