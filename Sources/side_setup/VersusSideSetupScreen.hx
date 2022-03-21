package side_setup;

import input.IInputDevice;
import input.InputMapping;
import game.actions.Action;
import save_data.InputSettings;
import input.KeyboardInputDevice;

class VersusSideSetupScreen extends SideSetupScreen {
	var isLeftReady: Bool;
	var isRightReady: Bool;

	public function new(onReady: (Null<IInputDevice>, Null<IInputDevice>) -> Void) {
		isLeftReady = false;
		isRightReady = false;

		devices = [
			new InputDeviceIcon("Keyboard (Arrows)", new KeyboardInputDevice(new InputSettings([]))),
			new InputDeviceIcon("Keyboard (WASD)", new KeyboardInputDevice(new InputSettings([
				MAPPINGS => [
					MENU_LEFT => ({
						keyboardInput: A,
						gamepadButton: DPAD_LEFT,
						gamepadAxis: {axis: 0, direction: -1}
					} : InputMapping).asString(),
					MENU_RIGHT => ({
						keyboardInput: D,
						gamepadButton: DPAD_RIGHT,
						gamepadAxis: {axis: 0, direction: 1}
					} : InputMapping).asString(),
					MENU_DOWN => ({
						keyboardInput: S,
						gamepadButton: DPAD_DOWN,
						gamepadAxis: {axis: 1, direction: 1},
					} : InputMapping).asString(),
					MENU_UP => ({
						keyboardInput: W,
						gamepadButton: DPAD_UP,
						gamepadAxis: {axis: 1, direction: -1}
					} : InputMapping).asString(),
					CONFIRM => ({
						keyboardInput: Tab,
						gamepadButton: CIRCLE,
						gamepadAxis: {
							axis: null,
							direction: null
						}
					} : InputMapping).asString(),
				]
			])))
		];

		super(onReady);
	}

	override function update() {
		super.update();

		if (leftSlot != null) {
			if (leftSlot.getReadyAction())
				isLeftReady = !isLeftReady;
		}

		if (rightSlot != null) {
			if (rightSlot.getReadyAction())
				isRightReady = !isRightReady;
		}

		if (isLeftReady && isRightReady) {
			onReady(leftSlot.device, rightSlot.device);
		}
	}
}
