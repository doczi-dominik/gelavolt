package input;

import ui.ControlDisplay;
import kha.graphics2.Graphics;
import game.actions.Action;
import save_data.InputSettings;

interface IInputDevice {
	public final type: InputDeviceType;

	public var inputSettings(get, null): InputSettings;
	public var height(default, null): Float;

	public function rebind(action: Action): Void;
	public function getAction(action: Action): Bool;
	public function onResize(): Void;
	public function renderBinding(g: Graphics, x: Float, y: Float, action: Action): Void;
	public function renderControls(g: Graphics, x: Float, y: Float, controls: Array<ControlDisplay>): Void;
}