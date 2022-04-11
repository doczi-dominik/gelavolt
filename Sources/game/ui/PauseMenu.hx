package game.ui;

import main_menu.MainMenuScreen;
import Screen.GlobalScreenSwitcher;
import ui.AreYouSureSubPageWidget;
import main_menu.ui.OptionsPage;
import game.mediators.PauseMediator;
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
	final pauseMediator: PauseMediator;

	public var updateGameState(default, null) = false;

	public function new(opts: PauseMenuOptions) {
		pauseMediator = opts.pauseMediator;

		super({
			prefsSettings: opts.prefsSettings,
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
			new AreYouSureSubPageWidget({
				title: "Exit To Main Menu",
				description: ["Return To The Main Menu"],
				content: "Return To The Main Menu?",
				callback: () -> {
					GlobalScreenSwitcher.switchScreen(new MainMenuScreen());
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

			return;
		}

		final firstPage = pages.first();

		firstPage.onShow(this);
		firstPage.onResize();
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
