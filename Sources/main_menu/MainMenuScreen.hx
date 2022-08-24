package main_menu;

import input.AnyInputDevice;
import save_data.Profile;
import main_menu.ui.MainMenuPage;
import ui.Menu;
import kha.graphics2.Graphics;
import kha.graphics4.Graphics as Graphics4;

class MainMenuScreen implements IScreen {
	final menu: Menu;

	public function new() {
		final prefs = Profile.primary.prefs;

		menu = new Menu({
			prefsSettings: prefs,
			positionFactor: 0,
			widthFactor: 1,
			backgroundOpacity: 0,
			initialPage: new MainMenuPage(prefs)
		});
		menu.onShow(AnyInputDevice.instance);
	}

	public function dispose() {}

	public function update() {
		menu.update();
	}

	public function render(g: Graphics, g4: Graphics4, alpha: Float) {
		menu.render(g, alpha);
	}
}
