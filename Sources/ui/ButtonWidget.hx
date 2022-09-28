package ui;

import kha.Assets;
import kha.Font;
import kha.graphics2.Graphics;

@:structInit
@:build(game.Macros.buildOptionsClass(ButtonWidget))
class ButtonWidgetOptions {}

class ButtonWidget implements IListWidget {
	static inline final FONT_SIZE = 60;

	@inject final callback: Void->Void;

	@inject public var title: String;
	@inject public var description: Array<String>;

	final font: Font;

	var fontSize = 0;
	var menu: Null<Menu>;

	public var controlHints(default, null): Array<ControlHint>;
	public var height(default, null) = 0.0;

	public function new(opts: ButtonWidgetOptions) {
		game.Macros.initFromOpts();

		font = Assets.fonts.Pixellari;

		controlHints = [{actions: [CONFIRM], description: "Confirm"}];
	}

	public function onShow(menu: Menu) {
		this.menu = menu;
	}

	public function onResize() {
		if (menu == null)
			return;

		fontSize = Std.int(FONT_SIZE * menu.scaleManager.smallerScale);
		height = font.height(fontSize);
	}

	public function update() {
		if (menu == null)
			return;

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
