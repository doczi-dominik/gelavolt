package ui;

import main.ScreenManager;
import main_menu.MainMenuScreen;
import kha.graphics2.Graphics;
import game.Macros;

@:structInit
@:build(game.Macros.buildOptionsClass(ErrorPage))
class ErrorPageOptons {
	public final controlDescription: String;
}

class ErrorPage extends MenuPageBase {
	@inject final message: String;
	@inject final callback: Void->Void;

	public static function mainMenuPage(message: String) {
		return new ErrorPage({
			message: message,
			controlDescription: "Return To Main Menu",
			callback: () -> {
				ScreenManager.switchScreen(new MainMenuScreen());
			}
		});
	}

	public function new(opts: ErrorPageOptons) {
		super({
			designFontSize: 64,
			header: "Error",
			controlHints: [{actions: [BACK, CONFIRM], description: opts.controlDescription}]
		});

		Macros.initFromOpts();
	}

	override function update() {
		if (menu == null)
			return;

		if (menu.inputDevice.getAction(BACK) || menu!.inputDevice!.getAction(CONFIRM))
			callback();
	}

	override function render(g: Graphics, x: Float, y: Float) {
		super.render(g, x, y);

		g.drawString(message, x, y);
	}
}
