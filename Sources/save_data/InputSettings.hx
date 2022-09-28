package save_data;

import utils.Geometry;
import input.AxisSpriteCoordinates.AXIS_SPRITE_COORDINATES;
import input.ButtonSpriteCoordinates.BUTTON_SPRITE_COORDINATES;
import input.GamepadBrand;
import game.actions.Action;
import input.InputMapping;

using Safety;

// Serializable mappings causes errors with null safety
// Null safety features are still used in methods
@:nullSafety(Off)
class InputSettings implements hxbit.Serializable {
	public static final MAPPINGS_DEFAULTS: Map<Action, InputMapping> = [
		PAUSE => {
			keyboardInput: Escape,
			gamepadButton: OPTIONS,
			gamepadAxis: {
				axis: null,
				direction: null
			}
		},
		MENU_LEFT => {
			keyboardInput: Left,
			gamepadButton: DPAD_LEFT,
			gamepadAxis: {axis: 0, direction: -1}
		},
		MENU_RIGHT => {
			keyboardInput: Right,
			gamepadButton: DPAD_RIGHT,
			gamepadAxis: {axis: 0, direction: 1}
		},
		MENU_DOWN => {
			keyboardInput: Down,
			gamepadButton: DPAD_DOWN,
			gamepadAxis: {axis: 1, direction: 1},
		},
		MENU_UP => {
			keyboardInput: Up,
			gamepadButton: DPAD_UP,
			gamepadAxis: {axis: 1, direction: -1}
		},
		BACK => {
			keyboardInput: Backspace,
			gamepadButton: CROSS,
			gamepadAxis: {
				axis: null,
				direction: null
			}
		},
		CONFIRM => {
			keyboardInput: Return,
			gamepadButton: CIRCLE,
			gamepadAxis: {
				axis: null,
				direction: null
			}
		},
		SHIFT_LEFT => {
			keyboardInput: Left,
			gamepadButton: DPAD_LEFT,
			gamepadAxis: {
				axis: 0,
				direction: -1
			}
		},
		SHIFT_RIGHT => {
			keyboardInput: Right,
			gamepadButton: DPAD_RIGHT,
			gamepadAxis: {
				axis: 0,
				direction: 1
			}
		},
		SOFT_DROP => {
			keyboardInput: Down,
			gamepadButton: DPAD_DOWN,
			gamepadAxis: {
				axis: 1,
				direction: 1
			}
		},
		HARD_DROP => {
			keyboardInput: Up,
			gamepadButton: DPAD_UP,
			gamepadAxis: {
				axis: 1,
				direction: -1
			}
		},
		ROTATE_LEFT => {
			keyboardInput: D,
			gamepadButton: CROSS,
			gamepadAxis: {
				axis: null,
				direction: null
			}
		},
		ROTATE_RIGHT => {
			keyboardInput: F,
			gamepadButton: CIRCLE,
			gamepadAxis: {
				axis: null,
				direction: null
			}
		},
		TOGGLE_EDIT_MODE => {
			keyboardInput: Q,
			gamepadButton: SHARE,
			gamepadAxis: {
				axis: null,
				direction: null
			}
		},
		EDIT_LEFT => {
			keyboardInput: Left,
			gamepadButton: DPAD_LEFT,
			gamepadAxis: {axis: 0, direction: -1}
		},
		EDIT_RIGHT => {
			keyboardInput: Right,
			gamepadButton: DPAD_RIGHT,
			gamepadAxis: {axis: 0, direction: 1}
		},
		EDIT_DOWN => {
			keyboardInput: Down,
			gamepadButton: DPAD_DOWN,
			gamepadAxis: {axis: 1, direction: 1},
		},
		EDIT_UP => {
			keyboardInput: Up,
			gamepadButton: DPAD_UP,
			gamepadAxis: {axis: 1, direction: -1}
		},
		EDIT_CLEAR => {
			keyboardInput: D,
			gamepadButton: CROSS,
			gamepadAxis: {
				axis: null,
				direction: null
			}
		},
		EDIT_SET => {
			keyboardInput: F,
			gamepadButton: CIRCLE,
			gamepadAxis: {
				axis: null,
				direction: null
			}
		},
		PREVIOUS_STEP => {
			keyboardInput: Y,
			gamepadButton: SQUARE,
			gamepadAxis: {
				axis: null,
				direction: null
			}
		},
		NEXT_STEP => {
			keyboardInput: X,
			gamepadButton: TRIANGLE,
			gamepadAxis: {
				axis: null,
				direction: null
			}
		},
		PREVIOUS_COLOR => {
			keyboardInput: C,
			gamepadButton: L2,
			gamepadAxis: {
				axis: null,
				direction: null
			}
		},
		NEXT_COLOR => {
			keyboardInput: V,
			gamepadButton: R2,
			gamepadAxis: {
				axis: null,
				direction: null
			}
		},
		PREVIOUS_GROUP => {
			keyboardInput: Y,
			gamepadButton: SQUARE,
			gamepadAxis: {
				axis: null,
				direction: null
			}
		},
		NEXT_GROUP => {
			keyboardInput: X,
			gamepadButton: TRIANGLE,
			gamepadAxis: {
				axis: null,
				direction: null
			}
		},
		TOGGLE_MARKERS => {
			keyboardInput: B,
			gamepadButton: R1,
			gamepadAxis: {
				axis: null,
				direction: null
			}
		},
		QUICK_RESTART => {
			keyboardInput: R,
			gamepadButton: L1,
			gamepadAxis: {
				axis: null,
				direction: null
			}
		},
		SAVE_STATE => {
			keyboardInput: O,
			gamepadButton: R1,
			gamepadAxis: {
				axis: null,
				direction: null
			}
		},
		LOAD_STATE => {
			keyboardInput: P,
			gamepadButton: R2,
			gamepadAxis: {
				axis: null,
				direction: null
			}
		}
	];

	static inline final DEADZONE_DEFAULT = 0.5;
	static inline final GAMEPAD_BRAND_DEFAULT = GamepadBrand.DS4;
	static inline final LOCAL_DELAY_DEFAULT = 2;
	static inline final NETPLAY_DELAY_DEFAULT = 2;

	var updateListeners: Array<Void->Void> = new Array<Void->Void>();

	@:s public var mappings(default, null): Map<Action, InputMapping>;
	@:s public var deadzone = DEADZONE_DEFAULT;
	@:s public var gamepadBrand = GAMEPAD_BRAND_DEFAULT;
	@:s public var localDelay = LOCAL_DELAY_DEFAULT;
	@:s public var netplayDelay = NETPLAY_DELAY_DEFAULT;

	public function new() {
		mappings = MAPPINGS_DEFAULTS.copy();
	}

	public function addUpdateListener(callback: Void->Void) {
		updateListeners.push(callback);

		callback();
	}

	public function notifyListeners() {
		for (f in updateListeners) {
			f();
		}
	}

	public function setDefaults() {
		mappings = MAPPINGS_DEFAULTS.copy();

		deadzone = DEADZONE_DEFAULT;
		gamepadBrand = GAMEPAD_BRAND_DEFAULT;
		localDelay = LOCAL_DELAY_DEFAULT;
		netplayDelay = NETPLAY_DELAY_DEFAULT;

		notifyListeners();
	}

	public function getButtonSprite(action: Action): Null<Geometry> {
		return BUTTON_SPRITE_COORDINATES!.get(gamepadBrand)!.get(mappings[action].sure().gamepadButton.sure());
	}

	public function getAxisSprite(action: Action): Null<Geometry> {
		return AXIS_SPRITE_COORDINATES!.get(gamepadBrand)!.get(mappings[action].sure().gamepadAxis.hashCode());
	}
}
