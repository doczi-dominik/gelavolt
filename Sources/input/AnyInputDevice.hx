package input;

import ui.ControlHint;
import kha.graphics2.Graphics;
import game.actions.Action;
import save_data.InputSettings;
import kha.input.Gamepad;
import save_data.Profile;

class AnyInputDevice implements IInputDevice {
	static inline final FONT_SIZE = 48;

	public static inline final KEYBOARD_ID = -1;

	public static var instance(default, null): AnyInputDevice;

	public static var rebindCounter = 0;
	public static var lastDeviceID = KEYBOARD_ID;

	public static function init() {
		instance = new AnyInputDevice();
	}

	final devices: Map<Int, InputDevice>;

	var isRebinding: Bool;

	public final type: InputDeviceType;

	public var inputSettings(get, null): InputSettings;

	function new() {
		devices = [];

		isRebinding = false;

		type = ANY;

		devices[KEYBOARD_ID] = new KeyboardInputDevice(inputSettings);

		for (i in 0...4) {
			if (Gamepad.get(i).connected) {
				connectListener(i);
			}
		}

		Gamepad.notifyOnConnect(connectListener, disconnectListener);

		Profile.addOnChangePrimaryCallback(onChangePrimary);
	}

	function connectListener(id: Int) {
		devices[id] = new GamepadInputDevice(Profile.primary.input, id);
	}

	function disconnectListener(id: Int) {
		devices.remove(id);
	}

	function onChangePrimary() {
		for (d in devices) {
			d.inputSettings = Profile.primary.input;
		}
	}

	function get_inputSettings() {
		return Profile.primary.input;
	}

	public function resetLastDeviceID() {
		lastDeviceID = KEYBOARD_ID;
	}

	public final function unbind(action: Action) {}

	public final function bindDefault(action: Action) {}

	public final function rebind(action: Action) {
		isRebinding = false;
	}

	public function getAction(action: Action) {
		if (rebindCounter > 0)
			return false;

		for (d in devices) {
			if (d.getAction(action))
				return true;
		}

		return false;
	}

	public function getRawAction(action: Action) {
		if (rebindCounter > 0)
			return false;

		for (d in devices) {
			if (d.getRawAction(action))
				return true;
		}

		return false;
	}

	public inline function getGamepad(id: Int) {
		return cast(devices[id], GamepadInputDevice);
	}

	public inline function getKeyboard() {
		return cast(devices[KEYBOARD_ID], KeyboardInputDevice);
	}

	// AnyInputDevices cannot be rebound and shouldn't be active when
	// displaying a rebinding menu.
	public function renderBinding(g: Graphics, x: Float, y: Float, scale: Float, action: Action) {}

	public function renderControls(g: Graphics, x: Float, width: Float, padding: Float, controls: Array<ControlHint>) {
		final lastDevice = devices[lastDeviceID];

		if (lastDevice == null)
			return;

		lastDevice.renderControls(g, x, width, padding, controls);
	}
}
