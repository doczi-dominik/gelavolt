package game.ui;

import main.ScreenManager;
import save_data.PrefsSettings;
import main_menu.MainMenuScreen;
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

@:structInit
class PauseMenuOptions {
	public final prefsSettings: PrefsSettings;
	public final pauseMediator: PauseMediator;
}

class PauseMenu extends Menu {
	final pauseMediator: PauseMediator;

	public var updateGameState(default, null) = false;

	public function new(opts: PauseMenuOptions) {
		pauseMediator = opts.pauseMediator;

		super({
			prefsSettings: opts.prefsSettings,
			positionFactor: 0,
			widthFactor: 1,
			backgroundOpacity: 0.9,
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
					ScreenManager.switchScreen(new MainMenuScreen());
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

	override function update() {
		if (inputDevice.getAction(PAUSE)) {
			pauseMediator.resume();
		}

		super.update();
	}
}
