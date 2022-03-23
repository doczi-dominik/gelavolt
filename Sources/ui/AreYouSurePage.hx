package ui;

import kha.graphics2.Graphics;
import kha.Font;
import kha.Assets;

class AreYouSurePage implements IMenuPage {
	static inline final FONT_SIZE = 64;

	final font: Font;
	final content: String;
	final callback: Void->Void;

	var fontSize: Int;
	var menu: Menu;

	public final header: String;

	public var controlDisplays(default, null): Array<ControlDisplay>;

	public function new(content: String, callback: Void->Void) {
		font = Assets.fonts.Pixellari;
		this.content = content;

		header = "Are You Sure?";

		controlDisplays = [
			{actions: [BACK], description: "Back"},
			{actions: [CONFIRM], description: "Confirm"}
		];

		this.callback = callback;
	}

	public function onResize() {
		fontSize = Std.int(FONT_SIZE * menu.scaleManager.smallerScale);
	}

	public function onShow(menu: Menu) {
		this.menu = menu;
	}

	public function update() {
		final inputDevice = menu.inputDevice;

		if (inputDevice.getAction(BACK)) {
			menu.popPage();

			return;
		}

		if (inputDevice.getAction(CONFIRM)) {
			callback();
			menu.popPage();
		}
	}

	public function render(g: Graphics, x: Float, y: Float) {
		g.font = font;
		g.fontSize = fontSize;
		g.drawString(content, x, y);
	}
}
