package ui;

import input.KeyboardInputDevice;
import input.GamepadInputDevice;
import input.AnyInputDevice;
import kha.graphics2.Graphics;

using Safety;

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
		menu!.popInputDevice();
		menu!.popPage();
	}

	override function onShow(menu: Menu) {
		super.onShow(menu);

		menu.pushInputDevice(keyboardDevice);
		AnyInputDevice.resetLastDeviceID();
	}

	override function update() {
		if (menu == null || AnyInputDevice.instance == null)
			return;

		final anyDevice = AnyInputDevice.instance.sure();
		final lastID = AnyInputDevice.lastDeviceID;

		var gamepad: Null<GamepadInputDevice> = null;

		if (lastID != AnyInputDevice.KEYBOARD_ID) {
			gamepad = anyDevice.getGamepad(lastID);
		}

		if (gamepad != null) {
			final page = pageBuilder(gamepad);

			// Replace Wrapper with actual widget
			popPage();
			menu!.pushPage(page);

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
