package game.ui;

import ui.ButtonWidget;
import ui.Menu;
import ui.IListWidget;
import game.actionbuffers.ReplayActionBuffer;

class ReplayPauseMenu extends PauseMenu {
	final actionBuffer: ReplayActionBuffer;

	public function new(opts: ReplayPauseMenuOptions) {
		actionBuffer = opts.actionBuffer;

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
