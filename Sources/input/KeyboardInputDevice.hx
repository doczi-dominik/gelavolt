package input;

import game.actions.ActionTitles.ACTION_TITLES;
import input.KeyCodeToString.KEY_CODE_TO_STRING;
import kha.graphics2.Graphics;
import ui.ControlDisplay;
import game.actions.ActionInputTypes;
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

	function rebindListener(action: Action, key: KeyCode) {
		final original = inputSettings.getMapping(action);

		inputSettings.setMapping(action, {
			keyboardInput: key,
			gamepadButton: original.gamepadButton,
			gamepadAxis: original.gamepadAxis
		});

		finishRebind();
	}

	override function buildActions() {
		actions = [];
		keysToActions = [];

		for (action in Type.allEnums(Action)) {
			final kbInput = inputSettings.getMapping(action).keyboardInput;

			if (keysToActions[kbInput] == null)
				keysToActions[kbInput] = [];

			keysToActions[kbInput].push(action);

			switch (ACTION_INPUT_TYPES[action]) {
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

	override function rebind(action: Action) {
		super.rebind(action);

		latestRebindFunction = rebindListener.bind(action);
		latestRebindAction = action;

		try {
			keyboard.notify(latestRebindFunction);
		}
	}

	override function renderBinding(g: Graphics, x: Float, y: Float, action: Action) {
		super.renderBinding(g, x, y, action);

		final title = ACTION_TITLES[action];

		if (action == latestRebindAction && isRebinding) {
			g.drawString('Press any key for [ $title ]', x, y);

			return;
		}

		g.drawString('$title: ${KEY_CODE_TO_STRING[inputSettings.getMapping(action).keyboardInput]}', x, y);
	}

	override function renderControls(g: Graphics, x: Float, y: Float, controls: Array<ControlDisplay>) {
		super.renderControls(g, x, y, controls);

		for (d in controls) {
			var str = "";

			for (action in d.actions) {
				str += '${KEY_CODE_TO_STRING[inputSettings.getMapping(action).keyboardInput]}/';
			}

			str = str.substring(0, str.length - 1);

			// Hackerman but it beats having to calculate with scaling
			str += ' : ${d.description}    ';

			final strWidth = font.width(controlsFontSize, str);

			g.drawString(str, x, y);

			x += strWidth;
		}
	}

	public function resetIsAnyKeyDown() {
		anyKeyCounter = 0;
		isAnyKeyDown = false;
	}
}
