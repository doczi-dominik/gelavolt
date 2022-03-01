package ui;

import utils.Utils;
import kha.graphics2.Graphics;

class OptionListWidget implements IListWidget {
	final title: String;
	final options: Array<String>;
	final onChange: String->Void;

	var menu: Menu;
	var index: Int;
	var value: String;

	public var description(default, null): Array<String>;
	public var controlDisplays(default, null): Array<ControlDisplay> = [{actions: [LEFT, RIGHT], description: "Change Value"}];

	public function new(opts: OptionListWidgetOptions) {
		title = opts.title;
		options = opts.options;
		onChange = opts.onChange;

		index = opts.startIndex;
		value = options[index];

		description = opts.description;
	}

	function changeValue(delta: Int) {
		index = Std.int(Utils.negativeMod(index + delta, options.length));
		value = options[index];
		onChange(value);
	}

	public function onShow(menu: Menu) {
		this.menu = menu;
	}

	public function update() {
		final inputManager = menu.inputManager;

		if (inputManager.getAction(LEFT)) {
			changeValue(-1);
		} else if (inputManager.getAction(RIGHT)) {
			changeValue(1);
		}
	}

	public function render(g: Graphics, x: Float, y: Float, isSelected: Bool) {
		g.color = (isSelected) ? Orange : White;
		g.drawString('$title: < $value >', x, y);
		g.color = White;
	}
}
