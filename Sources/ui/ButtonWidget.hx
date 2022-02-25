package ui;

import kha.Assets;
import kha.Font;
import kha.graphics2.Graphics;
import game.actions.MenuActions;

class ButtonWidget implements IListWidget {
	static inline final FONT_SIZE = 60;

	final font: Font;

	final callback: Void->Void;

	var fontSize: Int;

	var menu: Menu;

	public var title: String;
	public var description: Array<String>;
	public var controlDisplays(default, null): Array<ControlDisplay> = [{actions: [CONFIRM], description: "Confirm"}];
	public var height(default, null): Float;

	public function new(opts: ButtonWidgetOptions) {
		font = Assets.fonts.Pixellari;

		title = opts.title;
		callback = opts.callback;

		description = opts.description;
	}

	public function onShow(menu: Menu) {
		this.menu = menu;
	}

	public function onResize() {
		fontSize = Std.int(FONT_SIZE * ScaleManager.smallerScale);
		height = font.height(fontSize);
	}

	public function update() {
		if (menu.inputManager.getAction(CONFIRM)) {
			callback();
		}
	}

	public function render(g: Graphics, x: Float, y: Float, isSelected: Bool) {
		g.font = font;
		g.fontSize = fontSize;
		g.color = (isSelected) ? Orange : White;
		g.drawString(title, x, y);
		g.color = White;
	}
}
