package side_setup;

import input.InputMapping;
import game.actions.Action;
import save_data.InputSettings;
import input.KeyboardInputDevice;

class VersusSideSetupScreen extends SideSetupScreen {
	public function new() {
		devices = [
			new InputDeviceIcon("Keyboard (Arrow Keys)", new KeyboardInputDevice(new InputSettings([]))),
			new InputDeviceIcon("Keyboard (WASD)", new KeyboardInputDevice(new InputSettings([
				MAPPINGS => [
					MENU_LEFT => ({
						keyboardInput: A,
						gamepadButton: DPAD_LEFT,
						gamepadAxis: {axis: 0, direction: -1},
					} : InputMapping).asString(),
					MENU_RIGHT => ({
						keyboardInput: D,
						gamepadButton: DPAD_RIGHT,
						gamepadAxis: {axis: 0, direction: 1}
					} : InputMapping).asString()
				]
			])))
		];

		super();
	}
}
