package game.ui;

import main_menu.ui.MainMenuPage;
import main_menu.ui.OptionsPage;
import game.mediators.PauseMediator;
import save_data.PrefsSettings;
import ui.IListWidget;
import ui.SubPageWidget;
import ui.ButtonWidget;
import ui.ListMenuPage;
import ui.Menu;
import kha.graphics2.Graphics;
#if sys
import kha.Window;
#end

class PauseMenu extends Menu {
	final prefsSettings: PrefsSettings;
	final pauseMediator: PauseMediator;

	public var updateGameState(default, null) = false;

	public function new(opts: PauseMenuOptions) {
		prefsSettings = opts.prefsSettings;
		pauseMediator = opts.pauseMediator;

		super({
			positionFactor: 0,
			widthFactor: 1,
			initialPage: new ListMenuPage({
				header: "Paused",
				widgetBuilder: generateInitalPage
			})
		});
	}

	function generateInitalPage(menu: Menu): Array<IListWidget> {
		return [
			new ButtonWidget({
				title: "Resume",
				description: ["Continue Chaining!"],
				callback: pauseMediator.resume
			}),
			new SubPageWidget({
				title: "Options",
				description: ["Change Various Options and Settings"],
				subPage: new OptionsPage(prefsSettings)
			}),
			new ButtonWidget({
				title: "Show Main Menu",
				description: ["Display The Main Menu"],
				callback: () -> {
					pushPage(new MainMenuPage(prefsSettings));
				}
			}),
			#if sys
			new ButtonWidget({
				title: "Exit To Desktop",
				description: ["Leave GelaVolt"],
				callback: () -> {
					Sys.exit(0);
				}
			}),
			#end
		];
	}

	override function popPage() {
		final poppedPage = pages.pop();

		if (pages.isEmpty()) {
			pages.add(poppedPage);
			pauseMediator.resume();
		}
	}

	override function update() {
		if (inputDevice.getAction(PAUSE)) {
			pauseMediator.resume();
		}

		super.update();
	}

	override function render(g: Graphics, alpha: Float) {
		final scr = ScaleManager.screen;

		g.pushOpacity(0.90);
		g.color = Black;
		g.fillRect(0, 0, scr.width, scr.height);
		g.color = White;
		g.popOpacity();

		super.render(g, alpha);
	}
}
