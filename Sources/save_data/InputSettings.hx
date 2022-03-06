package save_data;

import game.actions.Action;
import input.InputMapping;

@:structInit
class InputSettings {
	@:optional public final menu: MenuInputs = {
		pause: {
			keyboardInput: Escape,
			gamepadInput: OPTIONS
		},
		left: {
			keyboardInput: Left,
			gamepadInput: DPAD_LEFT
		},
		right: {
			keyboardInput: Right,
			gamepadInput: DPAD_RIGHT
		},
		down: {
			keyboardInput: Down,
			gamepadInput: DPAD_DOWN
		},
		up: {
			keyboardInput: Up,
			gamepadInput: DPAD_UP
		},
		back: {
			keyboardInput: Backspace,
			gamepadInput: CROSS
		},
		confirm: {
			keyboardInput: Return,
			gamepadInput: CIRCLE
		}
	};

	@:optional public final game: GameInputs = {
		shiftLeft: {keyboardInput: Left, gamepadInput: DPAD_LEFT},
		shiftRight: {keyboardInput: Right, gamepadInput: DPAD_RIGHT},
		softDrop: {keyboardInput: Down, gamepadInput: DPAD_DOWN},
		hardDrop: {keyboardInput: Up, gamepadInput: DPAD_UP},
		rotateLeft: {keyboardInput: D, gamepadInput: CROSS},
		rotateRight: {keyboardInput: F, gamepadInput: CIRCLE}
	};

	@:optional public final training: TrainingInputs = {
		toggleEditMode: {keyboardInput: Q, gamepadInput: SHARE},
		previousStep: {keyboardInput: Y, gamepadInput: SQUARE},
		nextStep: {keyboardInput: X, gamepadInput: TRIANGLE},
		previousColor: {keyboardInput: C, gamepadInput: L2},
		nextColor: {keyboardInput: V, gamepadInput: R2},
		toggleMarkers: {keyboardInput: B, gamepadInput: R1}
	};

	public function getMapping(action: Action) {
		return switch (action) {
			case PAUSE: menu.pause;
			case LEFT: menu.left;
			case RIGHT: menu.right;
			case DOWN: menu.down;
			case UP: menu.up;
			case BACK: menu.back;
			case CONFIRM: menu.confirm;

			case SHIFT_LEFT: game.shiftLeft;
			case SHIFT_RIGHT: game.shiftRight;
			case SOFT_DROP: game.softDrop;
			case HARD_DROP: game.hardDrop;
			case ROTATE_LEFT: game.rotateLeft;
			case ROTATE_RIGHT: game.rotateRight;

			case TOGGLE_EDIT_MODE: training.toggleEditMode;
			case PREVIOUS_STEP: training.previousStep;
			case NEXT_STEP: training.nextStep;
			case PREVIOUS_COLOR: training.previousColor;
			case NEXT_COLOR: training.nextColor;
			case TOGGLE_MARKERS: training.toggleMarkers;
		}
	}

	public function setMapping(action: Action, mapping: InputMapping) {
		switch (action) {
			case PAUSE:
				menu.pause = mapping;
			case LEFT:
				menu.left = mapping;
			case RIGHT:
				menu.right = mapping;
			case DOWN:
				menu.down = mapping;
			case UP:
				menu.up = mapping;
			case BACK:
				menu.back = mapping;
			case CONFIRM:
				menu.confirm = mapping;

			case SHIFT_LEFT:
				game.shiftLeft = mapping;
			case SHIFT_RIGHT:
				game.shiftRight = mapping;
			case SOFT_DROP:
				game.softDrop = mapping;
			case HARD_DROP:
				game.hardDrop = mapping;
			case ROTATE_LEFT:
				game.rotateLeft = mapping;
			case ROTATE_RIGHT:
				game.rotateRight = mapping;

			case TOGGLE_EDIT_MODE:
				training.toggleEditMode = mapping;
			case PREVIOUS_STEP:
				training.previousStep = mapping;
			case NEXT_STEP:
				training.nextStep = mapping;
			case PREVIOUS_COLOR:
				training.previousColor = mapping;
			case NEXT_COLOR:
				training.nextColor = mapping;
			case TOGGLE_MARKERS:
				training.toggleMarkers = mapping;
		}
	}

	public function exportData(): InputSettingsData {
		return {
			menu: {
				pause: menu.pause,
				left: menu.left,
				right: menu.right,
				down: menu.down,
				up: menu.up,
				back: menu.back,
				confirm: menu.confirm
			},
			game: {
				shiftLeft: game.shiftLeft,
				shiftRight: game.shiftRight,
				softDrop: game.softDrop,
				hardDrop: game.hardDrop,
				rotateLeft: game.rotateLeft,
				rotateRight: game.rotateRight
			},
			training: {
				toggleEditMode: training.toggleEditMode,
				previousStep: training.previousStep,
				nextStep: training.nextStep,
				previousColor: training.previousColor,
				nextColor: training.nextColor,
				toggleMarkers: training.toggleMarkers
			}
		};
	}
}

typedef InputSettingsData = {
	menu: MenuInputs,
	game: GameInputs,
	training: TrainingInputs
};

private typedef MenuInputs = {
	pause: InputMapping,
	left: InputMapping,
	right: InputMapping,
	down: InputMapping,
	up: InputMapping,
	back: InputMapping,
	confirm: InputMapping
};

private typedef GameInputs = {
	shiftLeft: InputMapping,
	shiftRight: InputMapping,
	softDrop: InputMapping,
	hardDrop: InputMapping,
	rotateLeft: InputMapping,
	rotateRight: InputMapping
};

private typedef TrainingInputs = {
	toggleEditMode: InputMapping,
	previousStep: InputMapping,
	nextStep: InputMapping,
	previousColor: InputMapping,
	nextColor: InputMapping,
	toggleMarkers: InputMapping
};
