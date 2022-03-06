package game.ui;

import input.IInputDevice;
import game.actions.Action;

@:structInit
class ControlsPageOptions {
	public final header: String;
	public final actions: Array<Action>;
	public final inputDevice: IInputDevice;
}
