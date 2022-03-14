package game.ui;

import save_data.EndlessSettings;
import game.gamemodes.EndlessGameMode;
import haxe.Serializer;
import game.actionbuffers.IActionBuffer;
import ui.ButtonWidget;
import save_data.SaveManager;
import save_data.ClearOnXMode;
import ui.OptionListWidget;
import ui.Menu;
import ui.IListWidget;
import save_data.TrainingSettings;
#if js
import js.html.URL;
import js.html.File;
import js.Browser;
#else
import sys.io.File;
#end

using DateTools;

class EndlessPauseMenu extends PauseMenu {
	final gameMode: EndlessGameMode;
	final endlessSettings: EndlessSettings;
	final actionBuffer: IActionBuffer;

	public function new(opts: EndlessPauseMenuOptions) {
		gameMode = opts.gameMode;
		endlessSettings = opts.endlessSettings;
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
					startIndex: switch (endlessSettings.clearOnXMode) {
						case CLEAR: 0;
						case RESTART: 1;
						case NEW: 2;
					},
					onChange: (value) -> {
						endlessSettings.clearOnXMode = value;
						SaveManager.saveProfiles();
					}
				}),
				new ButtonWidget({
					title: "Save Replay",
					description: [
						#if kha_html5 "Download A Replay File Of This Session", #else "Save A Replay File To GelaVolt's Folder",
						#end
						"",
						"To View It, Just Drag & Drop The File",
						"On The GelaVolt Window",
					],
					callback: () -> {
						final data = gameMode.copyWithReplay(actionBuffer.exportReplayData());
						final serialized = Serializer.run(data);
						final filename = 'replay-${Date.now().format("%Y-%m-%d_%H-%M")}.gvr';

						#if js
						final file = new File([Serializer.run(data)], "replay.gvr");
						final uri = URL.createObjectURL(file);

						final el = Browser.document.createAnchorElement();

						el.href = uri;
						el.setAttribute("download", filename);
						el.click();
						#else
						File.saveContent(filename, serialized);
						#end
					}
				})
			]
		});

		final pauseMenuOpts = super.generateInitalPage(_);

		pauseMenuOpts.unshift(endlessOpts);

		return pauseMenuOpts;
	}
}
