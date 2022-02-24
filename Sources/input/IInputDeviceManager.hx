package input;

import utils.Geometry;
import game.actions.ActionCategory;
import save_data.InputSave;
import kha.graphics2.Graphics;
import game.actions.Action;

interface IInputDeviceManager {
	public final inputOptions: InputSave;

	public var isRebinding(default, null): Bool;

	public function getAction(action: String): Bool;
	public function rebind(action: Action, category: ActionCategory): Void;
	public function renderGamepadIcon(g: Graphics, x: Float, y: Float, sprite: Geometry, scale: Float): Void;
}
