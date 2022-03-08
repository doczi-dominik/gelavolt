package input;

import kha.Font;
import input.GamepadSpriteCoordinates.GAMEPAD_SPRITE_COORDINATES;
import input.KeyCodeToString.KEY_CODE_TO_STRING;
import kha.Assets;
import ui.ControlDisplay;
import kha.graphics2.Graphics;
import game.actions.Action;
import save_data.InputSettings;
import kha.input.Gamepad;
import save_data.Profile;

class AnyInputDevice implements IInputDevice {
	static inline final FONT_SIZE = 48;
	static inline final KEYBOARD_ID = -1;

	public static var instance(default, null): AnyInputDevice;

	public static var rebindCounter = 0;
	public static var lastGamepadID: Null<Int>;

	public static function init() {
		instance = new AnyInputDevice();
	}

	final font: Font;

	final devices: Map<Int, InputDevice>;

	var fontSize: Int;

	var isRebinding: Bool;

	public final type: InputDeviceType;

	public var inputSettings(get, null): InputSettings;
	public var height(default, null): Float;

	function new() {
		font = Assets.fonts.Pixellari;

		devices = [];

		isRebinding = false;

		type = ANY;

		devices[KEYBOARD_ID] = new KeyboardInputDevice(Profile.primary.inputSettings);

		Gamepad.notifyOnConnect(connectListener, disconnectListener);

		Profile.addOnChangePrimaryCallback(onChangePrimary);
	}

	function connectListener(id: Int) {
		devices[id] = new GamepadInputDevice(Profile.primary.inputSettings, id);
	}

	function disconnectListener(id: Int) {
		devices.remove(id);
	}

	function onChangePrimary() {
		for (d in devices) {
			d.inputSettings = Profile.primary.inputSettings;
		}
	}

	function get_inputSettings() {
		return Profile.primary.inputSettings;
	}

	public function clearLastGamepadID() {
		lastGamepadID = null;
	}

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

	public inline function getGamepad(id: Int) {
		return cast(devices[id], GamepadInputDevice);
	}

	public inline function getKeyboard() {
		return cast(devices[KEYBOARD_ID], KeyboardInputDevice);
	}

	public function onResize() {
		fontSize = Std.int(FONT_SIZE * ScaleManager.smallerScale);
		height = font.height(fontSize);
	}

	// AnyInputDevices cannot be rebound and shouldn't be active when
	// displaying a rebinding menu.
	public function renderBinding(g: Graphics, x: Float, y: Float, action: Action) {}

	public function renderControls(g: Graphics, x: Float, y: Float, controls: Array<ControlDisplay>) {
		g.font = font;
		g.fontSize = fontSize;

		for (d in controls) {
			var str = "/";

			for (action in d.actions) {
				final mapping = inputSettings.getMapping(action);
				final spr = GAMEPAD_SPRITE_COORDINATES[mapping.gamepadButton];

				GamepadInputDevice.renderButton(g, x, y, height / spr.height, spr);

				x += spr.width * ScaleManager.smallerScale;
				str += '${KEY_CODE_TO_STRING[mapping.keyboardInput]},';
			}

			str = str.substr(0, str.length - 1);

			// Hackerman but it beats having to calculate with scaling
			str += ': ${d.description}    ';

			final strWidth = g.font.width(fontSize, str);

			g.drawString(str, x, y);

			x += strWidth;
		}
	}
}
