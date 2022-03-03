package game.ui;

import input.IInputDevice;
import game.actions.ActionTitles.ACTION_TITLES;
import ui.ControlDisplay;
import game.actions.Action;
import kha.graphics2.Graphics;
import ui.Menu;
import ui.IListWidget;

class InputWidget implements IListWidget {
	final inputDevice: IInputDevice;

	public final action: Action;

	public var description(default, null): Array<String> = [];
	public var controlDisplays: Array<ControlDisplay> = [{actions: [CONFIRM], description: "Rebind"}];

	public var isRebinding: Bool;

	public function new(opts: InputWidgetOptions) {
		inputDevice = opts.inputDevice;

		action = opts.action;

		isRebinding = false;
	}

	public function onShow(_: Menu) {}

	public function update() {}

	public function render(g: Graphics, x: Float, y: Float, isSelected: Bool) {
		g.color = (isSelected) ? Orange : White;

		if (isRebinding) {
			g.drawString('Press any key / button for [ ${ACTION_TITLES[action]} ]', x, y);
			g.color = White;

			return;
		}

		inputDevice.renderBinding(g, x, y, action);
	}
}
