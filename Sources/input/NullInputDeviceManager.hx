package input;

import save_data.InputSettings;
import game.actions.Action;

class NullInputDeviceManager implements IInputDeviceManager {
	public static var instance(get, null): NullInputDeviceManager;

	static function get_instance() {
		if (instance == null)
			instance = new NullInputDeviceManager();

		return instance;
	}

	var actions: Map<String, Bool> = [];

	public final inputSettings: InputSettings = {};
	public final type: InputDevice = ANY;

	public var isRebinding(default, null) = false;

	function new() {}

	public function getAction(action: Action) {
		return false;
	}

	public function rebind(action: Action) {}
}
