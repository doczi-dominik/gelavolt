package input;

import save_data.InputSettings;
import game.actions.Action;

interface IInputDeviceManager {
	public final type: InputDevice;

	public var inputSettings(default, null): InputSettings;
	public var isRebinding(default, null): Bool;

	public function getAction(action: Action): Bool;
	public function rebind(action: Action): Void;
}
