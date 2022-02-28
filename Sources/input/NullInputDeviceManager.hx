package input;

import utils.Geometry;
import save_data.InputSave;
import kha.input.KeyCode;
import kha.graphics2.Graphics;
import game.actions.Action;

class NullInputDeviceManager implements IInputDeviceManager {
	public static var instance(get, null): NullInputDeviceManager;

	static function get_instance() {
		if (instance == null)
			instance = new NullInputDeviceManager();

		return instance;
	}

	var actions: Map<String, Bool> = [];

	public final inputSave: InputSave = new InputSave();
	public final type: InputDevice = ANY;

	public var isRebinding(default, null) = false;

	function new() {}

	public function getAction(action: String) {
		return false;
	}

	public function rebind(action: Action, category: String) {}
}
