package game.ui;

import main_menu.ui.MainMenuPage;
import main_menu.ui.OptionsPage;
import ui.YesNoWidget;
import game.mediators.PauseMediator;
import save_data.SaveManager;
import save_data.PrefsSave;
import ui.NumberRangeWidget;
import ui.IListWidget;
import ui.SubPageWidget;
import ui.ButtonWidget;
import ui.ListMenuPage;
import ui.Menu;
import game.actions.MenuActions;
import kha.graphics2.Graphics;
#if sys
import kha.Window;
#end

class PauseMenu extends Menu {
	final prefsSave: PrefsSave;
	final pauseMediator: PauseMediator;

	public var updateGameState(default, null) = false;

	public function new(opts: PauseMenuOptions) {
		prefsSave = opts.prefsSave;
		pauseMediator = opts.pauseMediator;

		super(new ListMenuPage({
			header: "Paused",
			widgetBuilder: generateInitalPage
		}));
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
				subPage: new OptionsPage(prefsSave)
			}),
			new ButtonWidget({
				title: "Show Main Menu",
				description: ["Display The Main Menu"],
				callback: () -> {
					pushPage(new MainMenuPage(prefsSave));
				}
			})
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
		if (inputManager.getAction(PAUSE)) {
			pauseMediator.resume();
		}

		super.update();
	}

	override function render(g: Graphics, alpha: Float) {
		g.pushOpacity(0.90);
		g.color = Black;
		g.fillRect(0, 0, ScaleManager.width, ScaleManager.height);
		g.color = White;
		g.popOpacity();

		super.render(g, alpha);
	}
}
