package main_menu.ui;

import save_data.PrefsSave;
import ui.SubPageWidget;
import game.gamemodes.EndlessGameMode;
import kha.System;
import game.gamemodes.TrainingGameMode;
import game.screens.GameScreen;
import Screen.GlobalScreenSwitcher;
import ui.ButtonWidget;
import ui.ListMenuPage;
#if sys
import kha.Window;
#end
#if js
import js.Browser;
#end

class MainMenuPage extends ListMenuPage {
	static inline final DISCORD_INVITE = "https://discord.gg/wsWArpAFJK";
	static inline final RELEASES_URL = "https://github.com/doczi-dominik/gelavolt/releases";

	final prefsSave: PrefsSave;

	public function new(prefsSave: PrefsSave) {
		this.prefsSave = prefsSave;

		super({
			header: "GelaVolt",
			widgetBuilder: (_) -> [
				new ButtonWidget({
					title: "Training Mode",
					description: ["Practice In GelaVolt's", "Signature Training Mode!"],
					callback: () -> {
						GlobalScreenSwitcher.switchScreen(GameScreen.create(({
							rngSeed: Std.int(System.time * 1000000),
							rule: {},
						} : TrainingGameMode)));
					}
				}),
				new ButtonWidget({
					title: "Endless Mode",
					description: ["Play For As Long As You", "Can In Endless Mode And", "Share Your Replays!"],
					callback: () -> {
						GlobalScreenSwitcher.switchScreen(GameScreen.create(({
							rngSeed: Std.int(System.time * 1000000),
							rule: {},
						} : EndlessGameMode)));
					}
				}),
				new SubPageWidget({
					title: "Options",
					description: ["Change Various Options and Settings"],
					subPage: new OptionsPage(prefsSave)
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
				#if js
				new ButtonWidget({
					title: "Download Desktop Version",
					description: [
						"Download GelaVolt's",
						"Desktop Version For",
						"Better Performance",
						"And Offline Play"
					],
					callback: () -> {
						Browser.window.open(RELEASES_URL);
					}
				}), new ButtonWidget({
					title: "Official Discord",
					description: ["Join The Official", "Development Server", "For GelaVolt!", "", DISCORD_INVITE],
					callback: () -> {
						Browser.window.open(DISCORD_INVITE);
					}
				})
				#end
			]
		});
	}
}
