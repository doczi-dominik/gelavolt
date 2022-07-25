package ui;

import input.KeyboardInputDevice;
import input.AnyInputDevice;
import kha.Assets;
import kha.Font;
import kha.graphics2.Graphics;

@:structInit
@:build(game.Macros.buildOptionsClass(KeyboardConfirmWrapper))
class KeyboardConfirmWrapperOptions {}

class KeyboardConfirmWrapper implements IMenuPage {
	static inline final FONT_SIZE = 64;
	static final TEXT = "Press any button to continue";

	@inject final keyboardDevice: KeyboardInputDevice;
	@inject final pageBuilder: Void->IMenuPage;

	final font: Font;

	var menu: Menu;
	var fontSize: Int;

	public final header: String;

	public var controlHints(default, null): Array<ControlHint>;

	public function new(opts: KeyboardConfirmWrapperOptions) {
		game.Macros.initFromOpts();

		font = Assets.fonts.Pixellari;

		header = "Confirm Keyboard";

		controlHints = [{actions: [BACK], description: "Back"}];
	}

	public function onResize() {
		fontSize = Std.int(FONT_SIZE * menu.scaleManager.smallerScale);
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
