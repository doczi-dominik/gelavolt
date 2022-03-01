package input;

import save_data.InputSettings;
import game.actions.Action;

interface IInputDeviceManager {
	public final inputSettings: InputSettings;
	public final type: InputDevice;

	public var isRebinding(default, null): Bool;

	public function getAction(action: Action): Bool;
	public function rebind(action: Action): Void;
}
