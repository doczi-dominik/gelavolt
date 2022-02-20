package save_data;

import game.actions.ActionCategory;
import input.GamepadButton;
import game.actions.TrainingActions;
import game.actions.GameActions;
import kha.input.KeyCode;
import game.actions.MenuActions;
import input.InputMapping;
import game.actions.Action;
import input.InputType;

class InputSave {
	public var mappings: Null<Map<ActionCategory, Null<Map<Action, InputMapping>>>>;

	public function new() {}

	inline function createDefaultCategory(category: ActionCategory) {
		if (mappings[category] == null)
			mappings[category] = new Map<Action, InputMapping>();
	}

	inline function setDefault(map: Map<Action, InputMapping>, key: Action, def: InputMapping) {
		if (map[key] == null)
			map[key] = def;
	}

	public function setDefaults() {
		if (mappings == null)
			mappings = new Map<ActionCategory, Null<Map<Action, InputMapping>>>();

		createDefaultCategory(MENU);
		final m = mappings[MENU];

		setDefault(m, PAUSE, {keyboardInput: KeyCode.Escape, gamepadInput: GamepadButton.OPTIONS});
		setDefault(m, LEFT, {keyboardInput: KeyCode.Left, gamepadInput: GamepadButton.DPAD_LEFT});
		setDefault(m, RIGHT, {keyboardInput: KeyCode.Right, gamepadInput: GamepadButton.DPAD_RIGHT});
		setDefault(m, DOWN, {keyboardInput: KeyCode.Down, gamepadInput: GamepadButton.DPAD_DOWN});
		setDefault(m, UP, {keyboardInput: KeyCode.Up, gamepadInput: GamepadButton.DPAD_UP});
		setDefault(m, BACK, {keyboardInput: KeyCode.Backspace, gamepadInput: GamepadButton.CROSS});
		setDefault(m, CONFIRM, {keyboardInput: KeyCode.Return, gamepadInput: GamepadButton.CIRCLE});

		createDefaultCategory(GAME);
		final g = mappings[GAME];

		setDefault(g, SHIFT_LEFT, {keyboardInput: KeyCode.Left, gamepadInput: GamepadButton.DPAD_LEFT});
		setDefault(g, SHIFT_RIGHT, {keyboardInput: KeyCode.Right, gamepadInput: GamepadButton.DPAD_RIGHT});
		setDefault(g, SOFT_DROP, {keyboardInput: KeyCode.Down, gamepadInput: GamepadButton.DPAD_DOWN});
		setDefault(g, HARD_DROP, {keyboardInput: KeyCode.Up, gamepadInput: GamepadButton.DPAD_UP});
		setDefault(g, ROTATE_LEFT, {keyboardInput: KeyCode.D, gamepadInput: GamepadButton.CROSS});
		setDefault(g, ROTATE_RIGHT, {keyboardInput: KeyCode.F, gamepadInput: GamepadButton.CIRCLE});

		createDefaultCategory(TRAINING);
		final t = mappings[TRAINING];

		setDefault(t, TOGGLE_EDIT_MODE, {keyboardInput: KeyCode.Q, gamepadInput: GamepadButton.SHARE});
		setDefault(t, PREVIOUS_STEP, {keyboardInput: KeyCode.Y, gamepadInput: GamepadButton.SQUARE});
		setDefault(t, NEXT_STEP, {keyboardInput: KeyCode.X, gamepadInput: GamepadButton.TRIANGLE});
		setDefault(t, PREVIOUS_COLOR, {keyboardInput: KeyCode.C, gamepadInput: GamepadButton.L2});
		setDefault(t, NEXT_COLOR, {keyboardInput: KeyCode.V, gamepadInput: GamepadButton.R2});
		setDefault(t, TOGGLE_MARKERS, {keyboardInput: KeyCode.B, gamepadInput: GamepadButton.R1});
	}
}
