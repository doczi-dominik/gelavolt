package ui;

import kha.Assets;
import kha.Font;
import kha.graphics2.Graphics;

class ButtonWidget implements IListWidget {
	static inline final FONT_SIZE = 60;

	final font: Font;

	final callback: Void->Void;

	var fontSize: Int;

	var menu: Menu;

	public var title: String;
	public var description: Array<String>;
	public var controlDisplays(default, null): Array<ControlDisplay>;
	public var height(default, null): Float;

	public function new(opts: ButtonWidgetOptions) {
		font = Assets.fonts.Pixellari;

		callback = opts.callback;

		title = opts.title;
		description = opts.description;
		controlDisplays = [{actions: [CONFIRM], description: "Confirm"}];
	}

	public function onShow(menu: Menu) {
		this.menu = menu;
	}

	public function onResize() {
		fontSize = Std.int(FONT_SIZE * menu.scaleManager.smallerScale);
		height = font.height(fontSize);
	}

	public function update() {
		if (menu.inputDevice.getAction(CONFIRM)) {
			callback();
		}
	}

	public function render(g: Graphics, x: Float, y: Float, isSelected: Bool) {
		g.color = (isSelected) ? Orange : White;
		g.font = font;
		g.fontSize = fontSize;
		g.drawString(title, x, y);
		g.color = White;
	}
}
