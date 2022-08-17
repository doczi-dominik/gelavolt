package input;

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

class KeyboardInputDevice extends InputDevice {
	final keyboard: Keyboard;

	var anyKeyCounter: Int;

	var keysToActions: Map<KeyCode, Null<Array<Action>>>;
	var latestRebindFunction: KeyCode->Void;

	public var isAnyKeyDown(default, null): Bool;

	public function new(inputSettings: InputSettings) {
		keyboard = Keyboard.get();

		anyKeyCounter = 0;

		super(KEYBOARD, inputSettings);
	}

	function downListener(key: KeyCode) {
		anyKeyCounter++;
		isAnyKeyDown = true;

		AnyInputDevice.lastDeviceID = AnyInputDevice.KEYBOARD_ID;

		if (!keysToActions.exists(key))
			return;

		for (action in keysToActions[key]) {
			counters[action] = 0;
		}
	}

	function upListener(key: KeyCode) {
		if (anyKeyCounter > 0)
			anyKeyCounter--;

		if (anyKeyCounter == 0)
			isAnyKeyDown = false;

		if (!keysToActions.exists(key))
			return;

		for (action in keysToActions[key]) {
			counters.remove(action);
		}
	}

	function changeKeybind(action: Action, key: Null<KeyCode>) {
		final original = inputSettings.mappings[action];

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

		for (action in ACTION_DATA.keys()) {
			final kbInput = inputSettings.mappings[action].keyboardInput;

			if (kbInput != null) {
				if (keysToActions[kbInput] == null)
					keysToActions[kbInput] = [];

				keysToActions[kbInput].push(action);
			}

			switch (ACTION_DATA[action].inputType) {
				case HOLD:
					actions[action] = holdActionHandler;
				case PRESS:
					actions[action] = pressActionHandler;
				case REPEAT:
					actions[action] = repeatActionHandler;
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
		changeKeybind(action, InputSettings.MAPPINGS_DEFAULTS[action].keyboardInput);

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
		final title = ACTION_DATA[action].title;

		if (action == latestRebindAction && isRebinding) {
			g.drawString('[ Press any key for $title ]', x, y);

			return;
		}

		final kbInput = inputSettings.mappings[action].keyboardInput;
		final binding = kbInput == null ? "[ UNBOUND ]" : KEY_CODE_TO_STRING[kbInput];

		g.drawString('$title: $binding', x, y);
	}

	override function renderControls(g: Graphics, x: Float, width: Float, padding: Float, controls: ReadOnlyArray<ControlHint>) {
		var str = "";

		for (d in controls) {
			for (action in d.actions) {
				final mapping = inputSettings.mappings[action].keyboardInput;

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
