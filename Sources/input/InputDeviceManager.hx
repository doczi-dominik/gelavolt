package input;

import utils.Geometry;
import game.actions.ActionInputTypes;
import game.actions.ActionCategory;
import save_data.InputSave;
import kha.Assets;
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

	public static var lastDevice(default, null) = InputDevice.KEYBOARD;

	public static function update() {
		for (i in instances) {
			i.updateCounters();
		}
	}

	final counters: Map<Action, Int> = [];
	final keyboard: Null<Keyboard>;
	final gamepad: Null<Gamepad>;

	var actions: Map<Action, Int->Bool>;
	var keysToActions: Map<KeyCode, Null<Array<Action>>>;
	var buttonsToActions: Map<Int, Null<Array<Action>>>;

	var keyRebindListener: KeyCode->Void;
	var buttonRebindListener: (Int, Float) -> Void;

	public final inputOptions: InputSave;

	public var isRebinding(default, null): Bool;

	public function new(inputOptions: InputSave, gamepadIndex: Null<Int>) {
		this.inputOptions = inputOptions;

		if (gamepadIndex == null) {
			keyboard = Keyboard.get();
			gamepad = null;
		} else {
			keyboard = null;
			gamepad = Gamepad.get(gamepadIndex);
		}

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
			if (keyboard != null)
				keyboard.notify(keyDownListener, keyUpListener);
			if (keyboard != null)
				keyboard.notify(keyboardLastDeviceListener);
		} catch (e) {}

		try {
			if (gamepad != null)
				gamepad.notify(null, buttonListener);
			if (gamepad != null)
				gamepad.notify(null, gamepadLastDeviceListener);
		} catch (e) {}
	}

	function removeListeners() {
		try {
			if (keyboard != null)
				keyboard.remove(keyDownListener, keyUpListener);
			if (keyboard != null)
				keyboard.remove(keyboardLastDeviceListener);
		} catch (e) {}

		try {
			if (gamepad != null)
				gamepad.remove(null, buttonListener);
			if (gamepad != null)
				gamepad.remove(null, gamepadLastDeviceListener);
		} catch (e) {}
	}

	function removeRebindListeners() {
		if (keyboard != null)
			keyboard.remove(keyRebindListener);
		if (gamepad != null)
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

		if (keyboard != null) {
			keyRebindListener = rebindKeyListener.bind(action, category);
			keyboard.notify(keyRebindListener);
		}

		if (gamepad != null) {
			buttonRebindListener = rebindButtonListener.bind(action, category);
			gamepad.notify(null, buttonRebindListener);
		}
	}

	public function renderGamepadIcon(g: Graphics, x: Float, y: Float, sprite: Geometry, scale: Float) {
		final w = sprite.width;
		final h = sprite.height;

		g.drawScaledSubImage(Assets.images.Buttons, sprite.x, sprite.y, w, h, x, y, w * scale, h * scale);
	}
}
