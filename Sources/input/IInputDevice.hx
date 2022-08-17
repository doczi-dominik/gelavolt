package input;

import haxe.ds.ReadOnlyArray;
import ui.ControlHint;
import kha.graphics2.Graphics;
import game.actions.Action;
import save_data.InputSettings;

interface IInputDevice {
	public final type: InputDeviceType;

	public var inputSettings(get, null): InputSettings;

	public function unbind(action: Action): Void;
	public function bindDefault(action: Action): Void;
	public function rebind(action: Action): Void;
	public function getAction(action: Action): Bool;
	public function getRawAction(action: Action): Bool;
	public function renderBinding(g: Graphics, x: Float, y: Float, scale: Float, action: Action): Void;
	public function renderControls(g: Graphics, x: Float, width: Float, padding: Float, controls: ReadOnlyArray<ControlHint>): Void;
}
