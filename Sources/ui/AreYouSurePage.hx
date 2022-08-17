package ui;

import kha.graphics2.Graphics;

class AreYouSurePage extends MenuPageBase {
	final content: String;
	final callback: Void->Void;

	public function new(content: String, callback: Void->Void) {
		super({
			designFontSize: 64,
			header: "Are You Sure?",
			controlHints: [
				{actions: [BACK], description: "Back"},
				{actions: [CONFIRM], description: "Confirm"}
			]
		});

		this.content = content;
		this.callback = callback;
	}

	override function update() {
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

	override function render(g: Graphics, x: Float, y: Float) {
		g.font = font;
		g.fontSize = fontSize;
		g.drawString(content, x, y);
	}
}
