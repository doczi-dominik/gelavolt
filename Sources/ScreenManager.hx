final class ScreenManager {
	static var currentScreen: IScreen = NullScreen.instance;

	public static function updateCurrent(): Void {
		currentScreen.update();
	}

	public static function renderCurrent(fb: kha.Framebuffer, alpha: Float): Void {
		final g4 = fb.g4;
		final g = fb.g2;

		g.begin();

		currentScreen.render(g, g4, alpha);

		g.end();
	}

	public static function switchScreen(newScreen: IScreen) {
		currentScreen = newScreen;
	}
}
