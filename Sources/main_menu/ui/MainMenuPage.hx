package main_menu.ui;

import game.gamestatebuilders.TrainingGameStateBuilder;
import input.AnyInputDevice;
import game.gamestatebuilders.EndlessGameStateBuilder;
import save_data.PrefsSettings;
import ui.SubPageWidget;
import kha.System;
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

	final prefsSettings: PrefsSettings;

	public function new(prefsSettings: PrefsSettings) {
		this.prefsSettings = prefsSettings;

		super({
			header: "GelaVolt",
			widgetBuilder: (_) -> [
				new ButtonWidget({
					title: "Training Mode",
					description: ["Practice In GelaVolt's", "Signature Training Mode!"],
					callback: () -> {
						GlobalScreenSwitcher.switchScreen(new GameScreen(new TrainingGameStateBuilder({
							rule: {},
							rngSeed: Std.int(System.time * 1000000),
						})));
					}
				}),
				new ButtonWidget({
					title: "Endless Mode",
					description: ["Play For As Long As You", "Can In Endless Mode And", "Share Your Replays!"],
					callback: () -> {
						GlobalScreenSwitcher.switchScreen(new GameScreen(new EndlessGameStateBuilder({
							rule: {},
							rngSeed: Std.int(System.time * 1000000),
							inputDevice: AnyInputDevice.instance,
							replayData: null
						})));
					}
				}),
				/*
					new SubPageWidget({
						title: "Netplay Test",
						description: [],
						subPage: new NetplaySyncPage()
					}),
				 */
				new SubPageWidget({
					title: "Options",
					description: ["Change Various Options and Settings"],
					subPage: new OptionsPage(prefsSettings)
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
