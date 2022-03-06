package game.ui;

import input.IInputDevice;
import game.actions.Action;

@:structInit
class ControlsPageWidgetOptions {
	public final title: String;
	public final description: Array<String>;
	public final actions: Array<Action>;
	public final inputDevice: IInputDevice;
}
