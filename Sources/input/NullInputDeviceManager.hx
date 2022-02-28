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

	public final inputOptions: InputSave = new InputSave();

	public var isRebinding(default, null) = false;

	function new() {}

	public function getAction(action: String) {
		return false;
	}

	public function rebind(action: Action, category: String) {}

	public function renderGamepadIcon(g: Graphics, x: Float, y: Float, sprite: Geometry, scale: Float) {}
}
