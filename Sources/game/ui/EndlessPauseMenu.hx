package game.ui;

import haxe.Serializer;
import js.html.URL;
import js.html.File;
import js.Browser;
import game.actionbuffers.IActionBuffer;
import ui.ButtonWidget;
import save_data.SaveManager;
import save_data.ClearOnXMode;
import ui.OptionListWidget;
import ui.Menu;
import ui.IListWidget;
import save_data.TrainingSave;

class EndlessPauseMenu extends PauseMenu {
	final trainingSave: TrainingSave;
	final actionBuffer: IActionBuffer;

	public function new(opts: EndlessPauseMenuOptions) {
		trainingSave = opts.trainingSave;
		actionBuffer = opts.actionBuffer;

		super(opts);
	}

	override function generateInitalPage(_: Menu): Array<IListWidget> {
		final endlessOpts = new ListSubPageWidget({
			header: "Endless Options",
			description: ["Change Various Options And Settings", "Specific to Endless Mode"],
			widgetBuilder: (_) -> [
				new OptionListWidget({
					title: "Clear Field on X",
					description: [
						"Clear The Field When A",
						"Gelo Group Locks On The",
						"Top Of The Center Column",
						"",
						"CLEAR: Clear the Field",
						"RESTART: CLEAR + Restart Queue",
						"NEW: CLEAR + Regenerate Queue"
					],
					options: [ClearOnXMode.CLEAR, RESTART, NEW],
					startIndex: switch (trainingSave.clearOnXMode) {
						case CLEAR: 0;
						case RESTART: 1;
						case NEW: 2;
					},
					onChange: (value) -> {
						trainingSave.clearOnXMode = value;
						SaveManager.saveProfiles();
					}
				}),
				new ButtonWidget({
					title: "Save Replay",
					description: [],
					callback: () -> {
						final data = actionBuffer.exportReplayData();

						final file = new File([Serializer.run(data)], "replay.gvr");
						final uri = URL.createObjectURL(file);

						final el = Browser.document.createAnchorElement();

						el.href = uri;
						el.setAttribute("download", "replay.gvr");
						el.click();
					}
				})
			]
		});

		final pauseMenuOpts = super.generateInitalPage(_);

		pauseMenuOpts.unshift(endlessOpts);

		return pauseMenuOpts;
	}
}
