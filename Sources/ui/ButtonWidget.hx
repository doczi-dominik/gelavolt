package ui;

import kha.graphics2.Graphics;

class ButtonWidget implements IListWidget {
	final callback: Void->Void;

	var menu: Menu;

	public var title: String;
	public var description: Array<String>;
	public var controlDisplays(default, null): Array<ControlDisplay> = [{actions: [CONFIRM], description: "Confirm"}];

	public function new(opts: ButtonWidgetOptions) {
		title = opts.title;
		callback = opts.callback;

		description = opts.description;
	}

	public function onShow(menu: Menu) {
		this.menu = menu;
	}

	public function update() {
		if (menu.inputManager.getAction(CONFIRM)) {
			callback();
		}
	}

	public function render(g: Graphics, x: Float, y: Float, isSelected: Bool) {
		g.color = (isSelected) ? Orange : White;
		g.drawString(title, x, y);
		g.color = White;
	}
}
