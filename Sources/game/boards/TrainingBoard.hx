package game.boards;

import ui.ControlHint;
import game.mediators.ControlHintContainer;
import input.IInputDevice;
import game.mediators.PauseMediator;
import game.boardstates.TrainingBoardState;
import game.boardstates.TrainingInfoBoardState;
import game.boardstates.EditingBoardState;
import game.actionbuffers.IActionBuffer;
import kha.graphics2.Graphics;
import kha.graphics4.Graphics as Graphics4;
import game.boardstates.IBoardState;
import game.mediators.SaveGameStateMediator;

@:structInit
@:build(game.Macros.buildOptionsClass(TrainingBoard))
class TrainingBoardOptions {}

class TrainingBoard implements IBoard {
	static final GAME_CONTROL_HINTS: Array<ControlHint> = [
		{actions: [TOGGLE_EDIT_MODE], description: "Edit Mode"},
		{actions: [PREVIOUS_GROUP], description: "Undo"},
		{actions: [NEXT_GROUP], description: "Redo / Get Next Group"},
		{actions: [QUICK_RESTART], description: "Quick Restart"},
		{actions: [SAVE_STATE], description: "Save State"},
		{actions: [LOAD_STATE], description: "Load State"}
	];

	static final EDIT_CONTROL_HINTS: Array<ControlHint> = [
		{actions: [TOGGLE_EDIT_MODE], description: "Play Mode"},
		{actions: [EDIT_SET], description: "Set"},
		{actions: [EDIT_CLEAR], description: "Clear"},
		{actions: [PREVIOUS_STEP, NEXT_STEP], description: "Cycle Chain Steps"},
		{actions: [PREVIOUS_COLOR, NEXT_COLOR], description: "Cycle Gelos / Markers"},
		{actions: [TOGGLE_MARKERS], description: "Toggle Gelos / Markers"},
	];

	@inject final pauseMediator: PauseMediator;
	@inject final inputDevice: IInputDevice;
	@inject final infoState: TrainingInfoBoardState;
	@inject final controlHintContainer: ControlHintContainer;
	@inject final saveGameStateMediator: SaveGameStateMediator;

	@inject final playState: TrainingBoardState;
	@inject final editState: EditingBoardState;

	@copy var activeState: IBoardState;

	public function new(opts: TrainingBoardOptions) {
		game.Macros.initFromOpts();

		changeToGame();
	}

	function setControlHints(hints: Array<ControlHint>) {
		final d = controlHintContainer.value.data;

		d.resize(0);

		for (h in hints) {
			d.push(h);
		}
	}

	function changeToEdit() {
		editState.loadStep();

		infoState.showChainSteps();

		setControlHints(EDIT_CONTROL_HINTS);

		activeState = editState;
	}

	function changeToGame() {
		playState.resume();

		infoState.hideChainSteps();

		setControlHints(GAME_CONTROL_HINTS);

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
		if (inputDevice.getAction(PAUSE)) {
			pauseMediator.pause(inputDevice);
		}

		if (inputDevice.getAction(TOGGLE_EDIT_MODE)) {
			if (activeState == playState) {
				changeToEdit();
			} else {
				changeToGame();
			}
		}

		if (activeState == playState) {
			if (inputDevice.getAction(PREVIOUS_GROUP)) {
				playState.previousGroup();
			} else if (inputDevice.getAction(NEXT_GROUP)) {
				playState.nextGroup();
			}

			if (inputDevice.getAction(QUICK_RESTART)) {
				playState.onLose();
			}

			if (inputDevice.getAction(SAVE_STATE)) {
				saveGameStateMediator.saveState();
			} else if (inputDevice.getAction(LOAD_STATE)) {
				saveGameStateMediator.loadState(0);
			}
		} else {
			if (inputDevice.getAction(PREVIOUS_STEP)) {
				editState.viewPrevious();
				infoState.onViewChainStep();
			} else if (inputDevice.getAction(NEXT_STEP)) {
				editState.viewNext();
				infoState.onViewChainStep();
			}
		}

		activeState.update();
	}

	public function renderScissored(g: Graphics, g4: Graphics4, alpha: Float) {
		activeState.renderScissored(g, g4, alpha);
	}

	public function renderFloating(g: Graphics, g4: Graphics4, alpha: Float) {
		activeState.renderFloating(g, g4, alpha);
	}
}
