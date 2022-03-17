package ui;

import input.KeyboardInputDevice;
import input.AnyInputDevice;
import kha.Assets;
import kha.Font;
import kha.graphics2.Graphics;

class KeyboardConfirmWrapper implements IMenuPage {
	static inline final FONT_SIZE = 64;
	static final TEXT = "Press any button to continue";

	final font: Font;

	final keyboardDevice: KeyboardInputDevice;
	final pageBuilder: Void->IMenuPage;

	var menu: Menu;
	var fontSize: Int;
	var fontHeight: Float;

	public final header: String;

	public var controlDisplays(default, null): Array<ControlDisplay>;

	public function new(opts: KeyboardConfirmWrapperOptions) {
		font = Assets.fonts.Pixellari;

		keyboardDevice = opts.keyboardDevice;
		pageBuilder = opts.pageBuilder;

		header = "Confirm Keyboard";

		controlDisplays = [{actions: [BACK], description: "Back"}];
	}

	public function onResize() {
		fontSize = Std.int(FONT_SIZE * ScaleManager.smallerScale);
		fontHeight = font.height(fontSize);
	}

	public function onShow(menu: Menu) {
		this.menu = menu;

		keyboardDevice.resetIsAnyKeyDown();
	}

	public function update() {
		if (AnyInputDevice.instance.getAction(BACK)) {
			menu.popPage();

			return;
		}

		if (keyboardDevice.isAnyKeyDown) {
			menu.popPage();
			menu.pushPage(pageBuilder());
		}
	}

	public function render(g: Graphics, x: Float, y: Float) {
		g.font = font;
		g.fontSize = fontSize;

		g.drawString(TEXT, x, y);
	}
}
