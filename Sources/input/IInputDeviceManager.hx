package input;

import game.actions.ActionCategory;
import save_data.InputSave;
import game.actions.Action;

interface IInputDeviceManager {
	public final inputSave: InputSave;
	public final type: InputDevice;

	public var isRebinding(default, null): Bool;

	public function getAction(action: String): Bool;
	public function rebind(action: Action, category: ActionCategory): Void;
}
