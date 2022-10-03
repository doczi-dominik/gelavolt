package main;

import input.AnyInputDevice;
import ui.IMenuPage;
import save_data.Profile;
import ui.Menu;

using Safety;

final class ScreenManager {
	static var overlay: Null<Menu>;
	static var showOverlay = false;
	static var currentScreen: IScreen = NullScreen.instance;

	public static function init() {
		overlay = new Menu({
			positionFactor: 0,
			widthFactor: 1,
			backgroundOpacity: 0.9,
			prefsSettings: Profile.primary.sure().prefs,
		});
	}

	public static function pushOverlay(page: IMenuPage) {
		if (overlay == null || AnyInputDevice.instance == null) {
			return;
		}

		final o = overlay.sure();
		final input = AnyInputDevice.instance.sure();

		o.pushPage(page);
		o.onShow(input);
		showOverlay = true;
	}

	public static function updateCurrent(): Void {
		if (showOverlay) {
			overlay!.update();
			return;
		}

		currentScreen.update();
	}

	public static function renderCurrent(fb: kha.Framebuffer, alpha: Float): Void {
		final g4 = fb.g4;
		final g = fb.g2;

		g.begin();

		currentScreen.render(g, g4, alpha);

		if (showOverlay) {
			overlay!.render(g, alpha);
		}

		g.end();
	}

	public static function switchScreen(newScreen: IScreen) {
		currentScreen.dispose();
		currentScreen = newScreen;
		showOverlay = false;
	}
}
