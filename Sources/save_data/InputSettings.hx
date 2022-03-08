package save_data;

import game.actions.Action;
import input.InputMapping;

@:structInit
class InputSettings {
	@:optional public final menu: MenuInputs = {
		pause: {
			keyboardInput: Escape,
			gamepadButton: OPTIONS,
			gamepadAxis: null
		},
		left: {
			keyboardInput: Left,
			gamepadButton: DPAD_LEFT,
			gamepadAxis: {axis: 0, direction: -1}
		},
		right: {
			keyboardInput: Right,
			gamepadButton: DPAD_RIGHT,
			gamepadAxis: {axis: 0, direction: 1}
		},
		down: {
			keyboardInput: Down,
			gamepadButton: DPAD_DOWN,
			gamepadAxis: {axis: 1, direction: 1},
		},
		up: {
			keyboardInput: Up,
			gamepadButton: DPAD_UP,
			gamepadAxis: {axis: 1, direction: -1}
		},
		back: {
			keyboardInput: Backspace,
			gamepadButton: CROSS,
			gamepadAxis: null
		},
		confirm: {
			keyboardInput: Return,
			gamepadButton: CIRCLE,
			gamepadAxis: null
		}
	};

	@:optional public final game: GameInputs = {
		shiftLeft: {keyboardInput: Left, gamepadButton: DPAD_LEFT, gamepadAxis: {axis: 0, direction: -1}},
		shiftRight: {keyboardInput: Right, gamepadButton: DPAD_RIGHT, gamepadAxis: {axis: 0, direction: 1}},
		softDrop: {keyboardInput: Down, gamepadButton: DPAD_DOWN, gamepadAxis: {axis: 1, direction: 1}},
		hardDrop: {keyboardInput: Up, gamepadButton: DPAD_UP, gamepadAxis: {axis: 1, direction: -1}},
		rotateLeft: {keyboardInput: D, gamepadButton: CROSS, gamepadAxis: null},
		rotateRight: {keyboardInput: F, gamepadButton: CIRCLE, gamepadAxis: null}
	};

	@:optional public final training: TrainingInputs = {
		toggleEditMode: {keyboardInput: Q, gamepadButton: SHARE, gamepadAxis: null},
		previousStep: {keyboardInput: Y, gamepadButton: SQUARE, gamepadAxis: null},
		nextStep: {keyboardInput: X, gamepadButton: TRIANGLE, gamepadAxis: null},
		previousColor: {keyboardInput: C, gamepadButton: L2, gamepadAxis: null},
		nextColor: {keyboardInput: V, gamepadButton: R2, gamepadAxis: null},
		toggleMarkers: {keyboardInput: B, gamepadButton: R1, gamepadAxis: null}
	};

	@:optional public var deadzone = 0;

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
			},
			deadzone: deadzone
		};
	}
}

typedef InputSettingsData = {
	menu: MenuInputs,
	game: GameInputs,
	training: TrainingInputs,
	deadzone: Float,
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
