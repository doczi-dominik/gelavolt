package input;

import haxe.ds.ReadOnlyArray;
import utils.Utils;
import save_data.SaveManager;
import ui.ControlHint;
import kha.graphics2.Graphics;
import save_data.InputSettings;
import game.actions.Action;

class InputDevice implements IInputDevice {
	static final instances: Array<InputDevice> = [];

	public static function update() {
		for (i in instances) {
			i.updateInstance();
		}
	}

	var counters: Map<Action, Int>;
	var actions: Map<Action, Int->Bool>;
	var isRebinding: Bool;
	var latestRebindAction: Null<Action>;
	var scrollT: Int;

	public final type: InputDeviceType;

	public var inputSettings(get, default): InputSettings;

	function new(type: InputDeviceType, inputSettings: InputSettings) {
		isRebinding = false;
		scrollT = 0;

		this.type = type;

		this.inputSettings = inputSettings;
		inputSettings.addUpdateListener(buildActions);

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

	final function updateInstance() {
		for (k in counters.keys()) {
			++counters[k];
		}

		++scrollT;
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

		inputSettings.notifyListeners();
	}

	final function getScrollX(width: Float, screenWidth: Float) {
		final diff = (width - screenWidth);

		if (diff <= 0) {
			// When scrolling is needed, it will always start at the beginning
			// unlike whatever scrollT was at the time
			scrollT = 375; // Math.sin(375 / 75) == -0.95

			return 0.0;
		}

		final sinCalc = Math.sin(scrollT / 75);

		return (Utils.clamp(-0.4, sinCalc, 0.4) + 0.4) * diff * 1.25;
	}

	public function unbind(action: Action) {
		SaveManager.saveProfiles();
		inputSettings.notifyListeners();
	}

	public function bindDefault(action: Action) {
		SaveManager.saveProfiles();
		inputSettings.notifyListeners();
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

	public function renderBinding(g: Graphics, x: Float, y: Float, scale: Float, action: Action) {}

	public function renderControls(g: Graphics, x: Float, width: Float, padding: Float, controls: ReadOnlyArray<ControlHint>) {}
}
