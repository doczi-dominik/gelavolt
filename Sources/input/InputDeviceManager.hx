package input;

import save_data.Profile;
import utils.Geometry;
import game.actions.ActionInputTypes;
import save_data.InputSettings;
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

	public static var any(default, null): InputDeviceManager;

	static function gamepadConnect(id: Int) {
		Gamepad.get(id).notify(null, any.buttonListener);
	}

	static function gamepadDisconnect(id: Int) {
		Gamepad.get(id).remove(null, any.buttonListener);
	}

	public static function init() {
		any = new InputDeviceManager(Profile.primary.inputSettings, ANY);

		Keyboard.get().notify(any.keyDownListener, any.keyUpListener);

		Gamepad.notifyOnConnect(gamepadConnect, gamepadDisconnect);

		Profile.addOnChangePrimaryCallback(() -> {
			any.changeInputSettings(Profile.primary.inputSettings);
		});
	}

	public static function update() {
		for (i in instances) {
			i.updateCounters();
		}
	}

	public static function renderGamepadIcon(g: Graphics, x: Float, y: Float, sprite: Geometry, scale: Float) {
		final w = sprite.width;
		final h = sprite.height;

		g.drawScaledSubImage(Assets.images.Buttons, sprite.x, sprite.y, w, h, x, y, w * scale, h * scale);
	}

	final counters: Map<Action, Int>;
	final keyboard: Null<Keyboard>;
	final gamepads: Array<Int>;

	var actions: Map<Action, Int->Bool>;
	var keysToActions: Map<KeyCode, Null<Array<Action>>>;
	var buttonsToActions: Map<Int, Null<Array<Action>>>;

	var keyRebindListener: KeyCode->Void;
	var buttonRebindListener: (Int, Float) -> Void;

	public final type: InputDevice;

	public var inputSettings(default, null): InputSettings;
	public var isRebinding(default, null): Bool;

	public function new(inputSettings: InputSettings, type: InputDevice) {
		counters = [];

		switch (type) {
			case KEYBOARD:
				keyboard = Keyboard.get();
				gamepads = [];
			case GAMEPAD(id):
				keyboard = null;
				gamepads = [id];
			case ANY:
				keyboard = Keyboard.get();
				gamepads = [];

				Gamepad.notifyOnConnect(gamepadConnectListener, gamepadDisconnectListener);
		}
		this.type = type;

		changeInputSettings(inputSettings);
		isRebinding = false;

		addListeners();

		instances.push(this);
	}

	function buildActions() {
		actions = [];
		keysToActions = [];
		buttonsToActions = [];

		for (action in Type.allEnums(Action)) {
			final mapping = inputSettings.getMapping(action);
			final kbInput = mapping.keyboardInput;
			final gpInput = mapping.gamepadInput;

			if (keysToActions[kbInput] == null) {
				keysToActions[kbInput] = [];
			}
			keysToActions[kbInput].push(action);

			if (buttonsToActions[gpInput] == null) {
				buttonsToActions[gpInput] = [];
			}
			buttonsToActions[gpInput].push(action);

			switch (ActionInputTypes[action]) {
				case HOLD:
					actions[action] = holdActionHandler;
				case PRESS:
					actions[action] = pressActionHandler;
				case REPEAT:
					actions[action] = repeatActionHandler;
			}
		}
	}

	function changeInputSettings(value: InputSettings) {
		inputSettings = value;

		buildActions();
	}

	function resetListeners() {
		removeListeners();
		addListeners();
	}

	function gamepadConnectListener(id: Int) {
		gamepads.push(id);

		resetListeners();
	}

	function gamepadDisconnectListener(id: Int) {
		gamepads.remove(id);

		resetListeners();
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

	function rebindKeyListener(action: Action, key: KeyCode) {
		final original = inputSettings.getMapping(action);

		inputSettings.setMapping(action, {
			keyboardInput: key,
			gamepadInput: original.gamepadInput
		});

		isRebinding = false;

		removeRebindListeners();
		addListeners();

		buildActions();
	}

	function rebindButtonListener(action: Action, button: Int, value: Float) {
		if (value == 0)
			return;

		final original = inputSettings.getMapping(action);

		inputSettings.setMapping(action, {
			keyboardInput: original.keyboardInput,
			gamepadInput: button
		});

		isRebinding = false;

		removeRebindListeners();
		addListeners();

		buildActions();
	}

	function addListeners() {
		try {
			if (keyboard != null)
				keyboard.notify(keyDownListener, keyUpListener);
		} catch (e) {}

		try {
			for (id in gamepads) {
				Gamepad.get(id).notify(null, buttonListener);
			}
		} catch (e) {}
	}

	function removeListeners() {
		try {
			if (keyboard != null)
				keyboard.remove(keyDownListener, keyUpListener);
		} catch (e) {}

		try {
			for (id in gamepads) {
				Gamepad.get(id).remove(null, buttonListener);
			}
		} catch (e) {}
	}

	function removeRebindListeners() {
		keyboard.remove(keyRebindListener);

		for (id in gamepads) {
			Gamepad.get(id).remove(null, buttonRebindListener);
		}
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

	public function rebind(action: Action) {
		isRebinding = true;

		removeListeners();

		keyRebindListener = rebindKeyListener.bind(action);
		buttonRebindListener = rebindButtonListener.bind(action);

		if (keyboard != null)
			keyboard.notify(keyRebindListener);

		for (id in gamepads) {
			Gamepad.get(id).notify(null, buttonRebindListener);
		}
	}
}
