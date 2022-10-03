package input;

import haxe.ds.ReadOnlyArray;
import game.actions.Action;
import ui.ControlHint;
import kha.graphics2.Graphics;
import save_data.Profile;
import save_data.InputSettings;

class NullInputDevice implements IInputDevice {
	public static var instance(default, null) = new NullInputDevice();

	public final type: InputDeviceType = NULL;

	public var inputSettings(get, null): Null<InputSettings>;

	function new() {}

	function get_inputSettings(): Null<InputSettings> {
		if (Profile.primary == null) {
			return null;
		}

		return Profile.primary.input;
	}

	public function unbind(action: Action) {}

	public function bindDefault(actoin: Action) {}

	public function rebind(action: Action) {}

	public function getAction(action: Action) {
		return false;
	}

	public function getRawAction(action: Action) {
		return false;
	}

	public function renderBinding(g: Graphics, x: Float, y: Float, scale: Float, action: Action) {}

	public function renderControls(g: Graphics, x: Float, width: Float, padding: Float, controls: ReadOnlyArray<ControlHint>) {}
}
