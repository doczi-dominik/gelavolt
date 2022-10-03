package input;

import main.ScaleManager;
import haxe.ds.ReadOnlyArray;
import utils.Utils;
import game.actions.ActionData.ACTION_DATA;
import input.KeyCodeToString.KEY_CODE_TO_STRING;
import kha.graphics2.Graphics;
import ui.ControlHint;
import game.actions.Action;
import kha.input.KeyCode;
import save_data.InputSettings;
import kha.input.Keyboard;

using Safety;

class KeyboardInputDevice extends InputDevice {
	final keyboard: Keyboard;

	var anyKeyCounter: Int;

	var keysToActions: Null<Map<KeyCode, Null<Array<Action>>>>;
	var latestRebindFunction: Null<KeyCode->Void>;

	public var isAnyKeyDown(default, null) = false;

	public function new(inputSettings: InputSettings) {
		keyboard = Keyboard.get();

		anyKeyCounter = 0;

		super(KEYBOARD, inputSettings);
	}

	function downListener(key: KeyCode) {
		if (keysToActions == null) {
			return;
		}

		final kta = keysToActions.sure();

		if (counters == null || kta[key] == null) {
			return;
		}

		final c = counters.sure();
		final a = kta[key].sure();

		anyKeyCounter++;
		isAnyKeyDown = true;

		AnyInputDevice.lastDeviceID = AnyInputDevice.KEYBOARD_ID;

		for (action in a) {
			c[action] = 0;
		}
	}

	function upListener(key: KeyCode) {
		if (keysToActions == null) {
			return;
		}

		final kta = keysToActions.sure();

		if (counters == null || kta[key] == null) {
			return;
		}

		final c = counters.sure();
		final a = kta[key].sure();

		if (anyKeyCounter > 0)
			anyKeyCounter--;

		if (anyKeyCounter == 0)
			isAnyKeyDown = false;

		for (action in a) {
			c.remove(action);
		}
	}

	function changeKeybind(action: Action, key: Null<KeyCode>) {
		final original = inputSettings.mappings[action];

		if (original == null) {
			return;
		}

		inputSettings.mappings[action] = ({
			keyboardInput: key,
			gamepadButton: original.gamepadButton,
			gamepadAxis: original.gamepadAxis
		} : InputMapping);
	}

	inline function rebindListener(action: Action, key: KeyCode) {
		changeKeybind(action, key);
		finishRebind();
	}

	override function buildActions() {
		counters = [];
		actions = [];
		keysToActions = [];

		final c = counters.sure();
		final acs = actions.sure();
		final kta = keysToActions.sure();

		for (action in ACTION_DATA.keys()) {
			if (ACTION_DATA[action] == null || inputSettings.mappings[action] == null) {
				continue;
			}

			final ada = ACTION_DATA[action].sure();
			final kbInput = inputSettings.mappings[action].sure().keyboardInput;

			if (kbInput != null) {
				if (kta[kbInput] == null) {
					kta[kbInput] = [];
				}

				kta[kbInput].sure().push(action);
			}

			switch (ada.inputType) {
				case HOLD:
					acs[action] = holdActionHandler;
				case PRESS:
					acs[action] = pressActionHandler;
				case REPEAT:
					acs[action] = repeatActionHandler;
			}
		}
	}

	override function addListeners() {
		try {
			keyboard.notify(downListener, upListener);
		}
	}

	override function removeListeners() {
		try {
			keyboard.remove(downListener, upListener);
		}
	}

	override function removeRebindListeners() {
		try {
			keyboard.remove(latestRebindFunction);
		}
	}

	override function unbind(action: Action) {
		changeKeybind(action, null);

		super.unbind(action);
	}

	override function bindDefault(action: Action) {
		if (InputSettings.MAPPINGS_DEFAULTS[action] == null) {
			return;
		}

		changeKeybind(action, InputSettings.MAPPINGS_DEFAULTS[action].sure().keyboardInput);

		super.bindDefault(action);
	}

	override function rebind(action: Action) {
		super.rebind(action);

		latestRebindFunction = rebindListener.bind(action);
		latestRebindAction = action;

		try {
			keyboard.notify(latestRebindFunction);
		}
	}

	override function renderBinding(g: Graphics, x: Float, y: Float, scale: Float, action: Action) {
		if (ACTION_DATA[action] == null || inputSettings.mappings[action] == null) {
			return;
		}

		final ad = ACTION_DATA[action].sure();
		final kbInput = inputSettings.mappings[action].sure().keyboardInput;

		final title = ad.title;

		if (action == latestRebindAction && isRebinding) {
			g.drawString('[ Press any key for $title ]', x, y);

			return;
		}

		final binding = kbInput == null ? "[ UNBOUND ]" : KEY_CODE_TO_STRING[kbInput];

		g.drawString('$title: $binding', x, y);
	}

	override function renderControls(g: Graphics, x: Float, width: Float, padding: Float, controls: ReadOnlyArray<ControlHint>) {
		var str = "";

		for (d in controls) {
			for (action in d.actions) {
				if (inputSettings.mappings[action] == null) {
					continue;
				}

				final mapping = inputSettings.mappings[action].sure().keyboardInput;

				if (mapping != null)
					str += '${KEY_CODE_TO_STRING[mapping]}/';
			}

			str = str.substring(0, str.length - 1);

			// Hackerman but it beats having to calculate with scaling
			str += ' : ${d.description}    ';
		}

		final strWidth = g.font.width(g.fontSize, str);
		final paddedScreenWidth = width - padding * 2;

		Utils.shadowDrawString(g, 3, Black, White, str, x
			+ padding
			- getScrollX(strWidth, paddedScreenWidth),
			ScaleManager.screen.height
			- padding
			- g.font.height(g.fontSize));
	}

	public function resetIsAnyKeyDown() {
		anyKeyCounter = 0;
		isAnyKeyDown = false;
	}
}
