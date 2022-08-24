import input.AnyInputDevice;
import ui.IMenuPage;
import save_data.Profile;
import ui.Menu;

final class ScreenManager {
	static var overlay: Menu;
	static var showOverlay: Bool;
	static var currentScreen: IScreen;

	public static function init() {
		overlay = new Menu({
			positionFactor: 0,
			widthFactor: 1,
			backgroundOpacity: 0.9,
			prefsSettings: Profile.primary.prefs,
		});

		showOverlay = false;
		currentScreen = NullScreen.instance;
	}

	public static function pushOverlay(page: IMenuPage) {
		overlay.pushPage(page);
		overlay.onShow(AnyInputDevice.instance);
		showOverlay = true;
	}

	public static function updateCurrent(): Void {
		if (showOverlay) {
			overlay.update();
			return;
		}

		currentScreen.update();
	}

	public static function renderCurrent(fb: kha.Framebuffer, alpha: Float): Void {
		final g4 = fb.g4;
		final g = fb.g2;

		g.begin();

		currentScreen.render(g, g4, alpha);

		if (showOverlay)
			overlay.render(g, alpha);

		g.end();
	}

	public static function switchScreen(newScreen: IScreen) {
		currentScreen.dispose();
		currentScreen = newScreen;
		showOverlay = false;
	}
}
