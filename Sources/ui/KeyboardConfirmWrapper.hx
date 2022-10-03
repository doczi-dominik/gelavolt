package ui;

import input.KeyboardInputDevice;
import input.AnyInputDevice;
import kha.graphics2.Graphics;

@:structInit
@:build(game.Macros.buildOptionsClass(KeyboardConfirmWrapper))
class KeyboardConfirmWrapperOptions {}

class KeyboardConfirmWrapper extends MenuPageBase {
	static final TEXT = "Press any button to continue";

	@inject final keyboardDevice: KeyboardInputDevice;
	@inject final pageBuilder: Void->IMenuPage;

	public function new(opts: KeyboardConfirmWrapperOptions) {
		super({
			designFontSize: 64,
			header: "Confirm Keyboard",
			controlHints: [{actions: [BACK], description: "Back"}]
		});

		game.Macros.initFromOpts();
	}

	override function onShow(menu: Menu) {
		super.onShow(menu);

		keyboardDevice.resetIsAnyKeyDown();
	}

	override function update() {
		if (menu == null || AnyInputDevice.instance == null)
			return;

		if (AnyInputDevice.instance.getAction(BACK)) {
			menu!.popPage();

			return;
		}

		if (keyboardDevice.isAnyKeyDown) {
			menu!.popPage();
			menu!.pushPage(pageBuilder());
		}
	}

	override function render(g: Graphics, x: Float, y: Float) {
		super.render(g, x, y);

		g.drawString(TEXT, x, y);
	}
}
