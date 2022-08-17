package ui;

import input.KeyboardInputDevice;
import input.GamepadInputDevice;
import input.AnyInputDevice;
import kha.graphics2.Graphics;

@:structInit
@:build(game.Macros.buildOptionsClass(AnyGamepadDetectWrapper))
class AnyGamepadDetectWrapperOptions {}

class AnyGamepadDetectWrapper extends MenuPageBase {
	static final TEXT = ["Press any button on", "the gamepad you wish", "to use"];

	@inject final keyboardDevice: KeyboardInputDevice;
	@inject final pageBuilder: GamepadInputDevice->IMenuPage;

	public function new(opts: AnyGamepadDetectWrapperOptions) {
		game.Macros.initFromOpts();

		super({
			designFontSize: 64,
			header: "Select Gamepad",
			controlHints: [{actions: [BACK], description: "Back"}]
		});
	}

	inline function popPage() {
		menu.popInputDevice();
		menu.popPage();
	}

	override function onShow(menu: Menu) {
		super.onShow(menu);

		menu.pushInputDevice(keyboardDevice);
		AnyInputDevice.instance.resetLastDeviceID();
	}

	override function update() {
		final anyDevice = AnyInputDevice.instance;
		final lastID = AnyInputDevice.lastDeviceID;

		if (lastID != AnyInputDevice.KEYBOARD_ID) {
			final page = pageBuilder(anyDevice.getGamepad(lastID));

			// Replace Wrapper with actual widget
			popPage();
			menu.pushPage(page);

			return;
		}

		if (anyDevice.getAction(BACK)) {
			popPage();
		}
	}

	override function render(g: Graphics, x: Float, y: Float) {
		super.render(g, x, y);

		for (i in 0...TEXT.length) {
			g.drawString(TEXT[i], x, y + i * fontHeight);
		}
	}
}
