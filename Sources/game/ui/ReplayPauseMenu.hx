package game.ui;

import game.ui.PauseMenu.PauseMenuOptions;
import ui.ButtonWidget;
import ui.Menu;
import ui.IListWidget;
import game.actionbuffers.ReplayActionBuffer;

@:structInit
@:build(game.Macros.buildOptionsClass(ReplayPauseMenu))
class ReplayPauseMenuOptions extends PauseMenuOptions {}

class ReplayPauseMenu extends PauseMenu {
	@inject final actionBuffer: ReplayActionBuffer;

	public function new(opts: ReplayPauseMenuOptions) {
		game.Macros.initFromOpts();

		super(opts);
	}

	override function generateInitalPage(_: Menu): Array<IListWidget> {
		final replayOpts = new ListSubPageWidget({
			header: "Replay Options",
			description: ["Change Various Options and Settings", "Specific to Replays"],
			widgetBuilder: (_) -> [
				new ButtonWidget({
					title: "Take Control",
					description: ["Stop Replay Playback And", "Take Control Of The Board"],
					callback: () -> {
						actionBuffer.mode = TAKE_CONTROL;
						pauseMediator.resume();
					}
				})
			]
		});

		final pauseMenuOpts = super.generateInitalPage(_);

		pauseMenuOpts.unshift(replayOpts);

		return pauseMenuOpts;
	}
}
