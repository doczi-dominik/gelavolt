package;

import kha.graphics2.Graphics;
import kha.graphics4.Graphics as Graphics4;

interface IScreen {
	public function update(): Void;
	public function render(g: Graphics, g4: Graphics4, alpha: Float): Void;
}

/**
 * Handles switching, updating and rendering the current `Screen` object.
 */
final class GlobalScreenSwitcher {
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
