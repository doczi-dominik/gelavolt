package versus_setup;

import input.InputDevice;
import input.InputDeviceManager;
import game.actions.MenuActions;

class InputManagerIcon {
	final device: InputDevice;
	final inputManager: InputDeviceManager;

	public final name: String;

	public var slot: InputSlot;

	public function new(opts: InputManagerIconOptions) {
		device = opts.device;
		inputManager = opts.inputManager;

		name = opts.name;

		slot = opts.defaultSlot;
	}

	public inline function getLeftAction() {
		return inputManager.getAction(LEFT);
	}

	public inline function getRightAction() {
		return inputManager.getAction(RIGHT);
	}
}
