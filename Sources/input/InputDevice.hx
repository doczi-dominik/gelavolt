package input;

import save_data.SaveManager;
import ui.ControlDisplay;
import kha.graphics2.Graphics;
import save_data.InputSettings;
import game.actions.Action;

class InputDevice implements IInputDevice {
	static final instances: Array<InputDevice> = [];

	public static function update() {
		for (i in instances) {
			i.updateCounters();
		}
	}

	final counters: Map<Action, Int>;

	var actions: Map<Action, Int->Bool>;
	var isRebinding: Bool;
	var latestRebindAction: Null<Action>;

	public final type: InputDeviceType;

	@:isVar public var inputSettings(get, set): InputSettings;

	function new(type: InputDeviceType, inputSettings: InputSettings) {
		counters = [];

		isRebinding = false;

		this.type = type;

		this.inputSettings = inputSettings;

		addListeners();

		instances.push(this);
	}

	function buildActions() {}

	function addListeners() {}

	function removeListeners() {}

	function removeRebindListeners() {}

	function get_inputSettings() {
		return inputSettings;
	}

	function set_inputSettings(value: InputSettings) {
		inputSettings = value;
		buildActions();

		return inputSettings;
	}

	final function updateCounters() {
		for (k in counters.keys()) {
			++counters[k];
		}
	}

	final function holdActionHandler(value: Int) {
		return value > 0;
	}

	final function pressActionHandler(value: Int) {
		return value == 1;
	}

	final function repeatActionHandler(value: Int) {
		if (value < 20) {
			return value == 1;
		}

		return value % 4 == 0;
	}

	final function finishRebind() {
		isRebinding = false;
		AnyInputDevice.rebindCounter--;

		SaveManager.saveProfiles();

		removeRebindListeners();
		addListeners();

		buildActions();
	}

	public function unbind(action: Action) {
		SaveManager.saveProfiles();
		buildActions();
	}

	public function bindDefault(action: Action) {
		SaveManager.saveProfiles();
		buildActions();
	}

	public function rebind(action: Action) {
		isRebinding = true;
		AnyInputDevice.rebindCounter++;

		removeListeners();
	}

	public final function getAction(action: Action) {
		return actions[action](counters[action]);
	}

	public final function getRawAction(action: Action) {
		return holdActionHandler(counters[action]);
	}

	public function renderBinding(g: Graphics, x: Float, y: Float, action: Action) {}

	public function renderControls(g: Graphics, padding: Float, controls: Array<ControlDisplay>) {}
}
