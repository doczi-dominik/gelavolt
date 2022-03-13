package ui;

import kha.Assets;
import kha.Font;
import utils.Utils;
import kha.graphics2.Graphics;

class OptionListWidget implements IListWidget {
	static inline final FONT_SIZE = 60;

	final font: Font;

	final title: String;
	final options: Array<String>;
	final onChange: String->Void;

	var fontSize: Int;

	var menu: Menu;
	var index: Int;
	var value: String;

	public var description(default, null): Array<String>;
	public var controlDisplays(default, null): Array<ControlDisplay> = [{actions: [MENU_LEFT, MENU_RIGHT], description: "Change"}];
	public var height(default, null): Float;

	public function new(opts: OptionListWidgetOptions) {
		font = Assets.fonts.Pixellari;

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

	public function onResize() {
		fontSize = Std.int(FONT_SIZE * ScaleManager.smallerScale);
		height = font.height(fontSize);
	}

	public function update() {
		final inputDevice = menu.inputDevice;

		if (inputDevice.getAction(MENU_LEFT)) {
			changeValue(-1);
		} else if (inputDevice.getAction(MENU_RIGHT)) {
			changeValue(1);
		}
	}

	public function render(g: Graphics, x: Float, y: Float, isSelected: Bool) {
		g.color = (isSelected) ? Orange : White;
		g.font = font;
		g.fontSize = fontSize;
		g.drawString('$title: < $value >', x, y);
		g.color = White;
	}
}
