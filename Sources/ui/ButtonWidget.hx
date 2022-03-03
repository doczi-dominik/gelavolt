package ui;

import kha.graphics2.Graphics;

class ButtonWidget implements IListWidget {
	final callback: Void->Void;

	var menu: Menu;

	public var title: String;
	public var description: Array<String>;
	public var controlDisplays(default, null): Array<ControlDisplay>;

	public function new(opts: ButtonWidgetOptions) {
		callback = opts.callback;

		title = opts.title;
		description = opts.description;
		controlDisplays = [{actions: [CONFIRM], description: "Confirm"}];
	}

	public function onShow(menu: Menu) {
		this.menu = menu;
	}

	public function update() {
		if (menu.inputDevice.getAction(CONFIRM)) {
			callback();
		}
	}

	public function render(g: Graphics, x: Float, y: Float, isSelected: Bool) {
		g.color = (isSelected) ? Orange : White;
		g.drawString(title, x, y);
		g.color = White;
	}
}
