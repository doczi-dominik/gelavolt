package ui;

import input.KeyboardInputDevice;
import input.GamepadInputDevice;
import input.AnyInputDevice;
import kha.Assets;
import kha.Font;
import kha.graphics2.Graphics;

@:structInit
@:build(game.Macros.buildOptionsClass(AnyGamepadDetectWrapper))
class AnyGamepadDetectWrapperOptions {}

class AnyGamepadDetectWrapper implements IMenuPage {
	static inline final FONT_SIZE = 64;
	static final TEXT = ["Press any button on", "the gamepad you wish", "to use"];

	@inject final keyboardDevice: KeyboardInputDevice;
	@inject final pageBuilder: GamepadInputDevice->IMenuPage;

	final font: Font;

	var menu: Menu;
	var fontSize: Int;
	var fontHeight: Float;

	public final header: String;

	public var controlDisplays(default, null): Array<ControlHint>;

	public function new(opts: AnyGamepadDetectWrapperOptions) {
		game.Macros.initFromOpts();

		font = Assets.fonts.Pixellari;

		header = "Select Gamepad";

		controlDisplays = [{actions: [BACK], description: "Back"}];
	}

	inline function popPage() {
		menu.popInputDevice();
		menu.popPage();
	}

	public function onResize() {
		fontSize = Std.int(FONT_SIZE * menu.scaleManager.smallerScale);
		fontHeight = font.height(fontSize);
	}

	public function onShow(menu: Menu) {
		this.menu = menu;

		menu.pushInputDevice(keyboardDevice);
		AnyInputDevice.instance.resetLastDeviceID();
	}

	public function update() {
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

	public function render(g: Graphics, x: Float, y: Float) {
		g.font = font;
		g.fontSize = fontSize;

		for (i in 0...TEXT.length) {
			g.drawString(TEXT[i], x, y + i * fontHeight);
		}
	}
}
