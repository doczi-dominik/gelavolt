package game.ui;

import game.actions.ActionData.ACTION_DATA;
import ui.ControlDisplay;
import game.actions.Action;
import kha.graphics2.Graphics;
import ui.Menu;
import ui.IListWidget;

class InputWidget implements IListWidget {
	final action: Action;

	var menu: Menu;

	public var description(default, null): Array<String>;
	public var controlDisplays: Array<ControlDisplay> = [{actions: [CONFIRM], description: "Rebind"}];
	public var height(default, null): Float;

	public function new(action: Action) {
		this.action = action;

		description = ACTION_DATA[action].description;
	}

	public function onShow(menu: Menu) {
		this.menu = menu;
	}

	public function onResize() {
		height = menu.inputDevice.height;
	}

	public function update() {
		if (menu.inputDevice.getAction(CONFIRM)) {
			menu.inputDevice.rebind(action);
		}
	}

	public function render(g: Graphics, x: Float, y: Float, isSelected: Bool) {
		g.color = (isSelected) ? Orange : White;
		menu.inputDevice.renderBinding(g, x, y, action);
		g.color = White;
	}
}
