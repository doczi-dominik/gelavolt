package input;

import game.actions.ActionInputTypes;
import game.actions.ActionCategory;
import save_data.InputSave;
import kha.Assets;
import input.GamepadSpriteCoordinates.GAMEPAD_SPRITE_COORDINATES;
import kha.graphics2.Graphics;
import game.actions.Action;
import kha.input.Keyboard;
import kha.input.KeyCode;
import kha.input.Gamepad;

/**
 * An "interface" from physical input devices into "actions", allowing for
 * easy usage and configuration of input devices. Takes advantage / extends
 * Kha input handling.
 */
class InputDeviceManager implements IInputDeviceManager {
	static final instances: Array<InputDeviceManager> = [];

	public static final keyCodeToString: Map<Int, String> = [
		0 => "Unknown", 1 => "Back", // Android
		3 => "Cancel", 6 => "Help", 8 => "Backspace", 9 => "Tab", 12 => "Clear", 13 => "Return", 16 => "Shift",
		17 => "Control", 18 => "Alt", 19 => "Pause", 20 => "CapsLock", 21 => "Kana / Hangul", 22 => "Eisu", 23 => "Junja", 24 => "Final",
		25 => "Hanja / Kanji", 27 => "Escape", 28 => "Convert", 29 => "NonConvert", 30 => "Accept", 31 => "ModeChange", 32 => "Space", 33 => "PageUp",
		34 => "PageDown", 35 => "End", 36 => "Home", 37 => "Left", 38 => "Up", 39 => "Right", 40 => "Down", 41 => "Select", 42 => "Print", 43 => "Execute",
		44 => "PrintScreen", 45 => "Insert", 46 => "Delete", 48 => "Zero", 49 => "One", 50 => "Two", 51 => "Three", 52 => "Four", 53 => "Five", 54 => "Six",
		55 => "Seven", 56 => "Eight", 57 => "Nine", 58 => "Colon", 59 => "Semicolon", 60 => "LessThan", 61 => "Equals", 62 => "GreaterThan",
		63 => "QuestionMark", 64 => "At", 65 => "A", 66 => "B", 67 => "C", 68 => "D", 69 => "E", 70 => "F", 71 => "G", 72 => "H", 73 => "I", 74 => "J",
		75 => "K", 76 => "L", 77 => "M", 78 => "N", 79 => "O", 80 => "P", 81 => "Q", 82 => "R", 83 => "S", 84 => "T", 85 => "U", 86 => "V", 87 => "W",
		88 => "X", 89 => "Y", 90 => "Z", 91 => "Win", 93 => "ContextMenu", 95 => "Sleep", 96 => "Numpad0", 97 => "Numpad1", 98 => "Numpad2", 99 => "Numpad3",
		100 => "Numpad4", 101 => "Numpad5", 102 => "Numpad6", 103 => "Numpad7", 104 => "Numpad8", 105 => "Numpad9", 106 => "Multiply", 107 => "Add",
		108 => "Separator", 109 => "Subtract", 110 => "Decimal", 111 => "Divide", 112 => "F1", 113 => "F2", 114 => "F3", 115 => "F4", 116 => "F5",
		117 => "F6", 118 => "F7", 119 => "F8", 120 => "F9", 121 => "F10", 122 => "F11", 123 => "F12", 124 => "F13", 125 => "F14", 126 => "F15", 127 => "F16",
		128 => "F17", 129 => "F18", 130 => "F19", 131 => "F20", 132 => "F21", 133 => "F22", 134 => "F23", 135 => "F24", 144 => "NumLock", 145 => "ScrollLock",
		146 => "WinOemFjJisho", 147 => "WinOemFjMasshou", 148 => "WinOemFjTouroku", 149 => "WinOemFjLoya", 150 => "WinOemFjRoya", 160 => "Circumflex",
		161 => "Exclamation", 162 => "DoubleQuote", 163 => "Hash", 164 => "Dollar", 165 => "Percent", 166 => "Ampersand", 167 => "Underscore",
		168 => "OpenParen", 169 => "CloseParen", 170 => "Asterisk", 171 => "Plus", 172 => "Pipe", 173 => "HyphenMinus", 174 => "OpenCurlyBracket",
		175 => "CloseCurlyBracket", 176 => "Tilde", 181 => "VolumeMute", 182 => "VolumeDown", 183 => "VolumeUp", 188 => "Comma", 190 => "Period",
		191 => "Slash", 192 => "BackQuote", 219 => "OpenBracket", 220 => "BackSlash", 221 => "CloseBracket", 222 => "Quote", 224 => "Meta", 225 => "AltGr",
		227 => "WinIcoHelp", 228 => "WinIco00", 230 => "WinIcoClear", 233 => "WinOemReset", 234 => "WinOemJump", 235 => "WinOemPA1", 236 => "WinOemPA2",
		237 => "WinOemPA3", 238 => "WinOemWSCTRL", 239 => "WinOemCUSEL", 240 => "WinOemATTN", 241 => "WinOemFinish", 242 => "WinOemCopy", 243 => "WinOemAuto",
		244 => "WinOemENLW", 245 => "WinOemBackTab", 246 => "ATTN", 247 => "CRSEL", 248 => "EXSEL", 249 => "EREOF", 250 => "Play", 251 => "Zoom",
		253 => "PA1", 254 => "WinOemClear",
	];

	public static var lastDevice(default, null) = InputDevice.KEYBOARD;

	public static function update() {
		for (i in instances) {
			i.updateCounters();
		}
	}

	final counters: Map<Action, Int> = [];

	var keyboard: Keyboard;
	var gamepad: Gamepad;

	var actions: Map<Action, Int->Bool>;
	var keysToActions: Map<KeyCode, Null<Array<Action>>>;
	var buttonsToActions: Map<Int, Null<Array<Action>>>;

	var keyRebindListener: KeyCode->Void;
	var buttonRebindListener: (Int, Float) -> Void;

	public final inputOptions: InputSave;

	public var isRebinding(default, null): Bool;

	public function new(inputOptions: InputSave, keyboardIndex: Int = 0, gamepadIndex: Int = 0) {
		this.inputOptions = inputOptions;

		keyboard = Keyboard.get(keyboardIndex);
		gamepad = Gamepad.get(gamepadIndex);

		isRebinding = false;

		buildActions();
		addListeners();

		instances.push(this);
	}

	function buildActions() {
		actions = [];
		keysToActions = [];
		buttonsToActions = [];

		for (mappings in inputOptions.mappings) {
			for (k => v in mappings.keyValueIterator()) {
				final kbInput = v.keyboardInput;
				final gpInput = v.gamepadInput;

				if (keysToActions[kbInput] == null) {
					keysToActions[kbInput] = [];
				}
				keysToActions[kbInput].push(k);

				if (buttonsToActions[gpInput] == null) {
					buttonsToActions[gpInput] = [];
				}
				buttonsToActions[gpInput].push(k);

				switch (ActionInputTypes[k]) {
					case HOLD:
						actions[k] = holdActionHandler;
					case PRESS:
						actions[k] = pressActionHandler;
					case REPEAT:
						actions[k] = repeatActionHandler;
				}
			}
		}
	}

	function keyDownListener(key: KeyCode) {
		if (!keysToActions.exists(key))
			return;

		for (action in keysToActions[key]) {
			if (counters.exists(action))
				continue;

			counters[action] = 0;
		}
	}

	function keyUpListener(key: KeyCode) {
		if (!keysToActions.exists(key))
			return;

		for (action in keysToActions[key]) {
			counters.remove(action);
		}
	}

	function buttonListener(button: Int, value: Float) {
		if (!buttonsToActions.exists(button))
			return;

		if (value == 0) {
			buttonUpListener(button);
		} else {
			buttonDownListener(button);
		}
	}

	function buttonDownListener(button: Int) {
		for (action in buttonsToActions[button]) {
			if (counters.exists(action))
				continue;

			counters[action] = 0;
		}
	}

	function buttonUpListener(button: Int) {
		for (action in buttonsToActions[button]) {
			counters.remove(action);
		}
	}

	function rebindKeyListener(action: Action, category: ActionCategory, key: KeyCode) {
		final original = inputOptions.mappings[category][action];

		inputOptions.mappings[category][action] = ({
			keyboardInput: key,
			gamepadInput: original.gamepadInput
		} : InputMapping);

		isRebinding = false;

		removeRebindListeners();
		addListeners();

		buildActions();
	}

	function rebindButtonListener(action: Action, category: ActionCategory, button: Int, value: Float) {
		if (value == 0)
			return;

		final original = inputOptions.mappings[category][action];

		inputOptions.mappings[category][action] = ({
			keyboardInput: original.keyboardInput,
			gamepadInput: button
		} : InputMapping);

		isRebinding = false;

		removeRebindListeners();
		addListeners();

		buildActions();
	}

	function keyboardLastDeviceListener(_: KeyCode) {
		lastDevice = KEYBOARD;
	}

	function gamepadLastDeviceListener(_: Int, _: Float) {
		lastDevice = GAMEPAD;
	}

	function addListeners() {
		try {
			keyboard.notify(keyDownListener, keyUpListener);
			keyboard.notify(keyboardLastDeviceListener);
		} catch (e) {}

		try {
			gamepad.notify(null, buttonListener);
			gamepad.notify(null, gamepadLastDeviceListener);
		} catch (e) {}
	}

	function removeListeners() {
		try {
			keyboard.remove(keyDownListener, keyUpListener);
			keyboard.remove(keyboardLastDeviceListener);
		} catch (e) {}

		try {
			gamepad.remove(null, buttonListener);
			gamepad.remove(null, gamepadLastDeviceListener);
		} catch (e) {}
	}

	function removeRebindListeners() {
		keyboard.remove(keyRebindListener);
		gamepad.remove(null, buttonRebindListener);
	}

	function holdActionHandler(value: Int) {
		return value > 0;
	}

	function pressActionHandler(value: Int) {
		return value == 1;
	}

	function repeatActionHandler(value: Int) {
		if (value < 20) {
			return value == 1;
		}

		return value % 4 == 0;
	}

	function updateCounters() {
		for (k in counters.keys()) {
			++counters[k];
		}
	}

	public function getAction(action: Action) {
		return actions[action](counters[action]);
	}

	public function rebind(action: Action, category: ActionCategory) {
		isRebinding = true;

		removeListeners();

		keyRebindListener = rebindKeyListener.bind(action, category);
		buttonRebindListener = rebindButtonListener.bind(action, category);

		keyboard.notify(keyRebindListener);
		gamepad.notify(null, buttonRebindListener);
	}

	public function renderGamepadIcon(g: Graphics, x: Float, y: Float, button: GamepadButton, size: Float) {
		final subImageCoords = GAMEPAD_SPRITE_COORDINATES[button];

		g.drawScaledSubImage(Assets.images.Buttons, subImageCoords.x, subImageCoords.y, 64, 64, x, y, size, size);
	}
}
