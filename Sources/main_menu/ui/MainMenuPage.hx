package main_menu.ui;

import main.ScreenManager;
import game.screens.BackupStateGameScreen;
import game.gamestatebuilders.TrainingGameStateBuilder;
import input.AnyInputDevice;
import game.gamestatebuilders.EndlessGameStateBuilder;
import save_data.PrefsSettings;
import ui.SubPageWidget;
import kha.System;
import game.screens.GameScreen;
import ui.ButtonWidget;
import ui.ListMenuPage;
#if sys
import kha.Window;
#end
#if kha_html5
import js.Browser;
import lobby.LobbyPage;
#end

using Safety;

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
						ScreenManager.switchScreen(new BackupStateGameScreen(new TrainingGameStateBuilder({
							rngSeed: Std.int(System.time * 1000000),
							marginTime: 96,
							targetPoints: 70,
							garbageDropLimit: 30,
							garbageConfirmGracePeriod: 30,
							softDropBonus: 0.5,
							popCount: 4,
							vanishHiddenRows: false,
							groupBonusTableType: TSU,
							colorBonusTableType: TSU,
							powerTableType: TSU,
							dropBonusGarbage: true,
							allClearReward: 30,
							physics: TSU,
							animations: TSU,
							dropSpeed: 2.6,
							randomizeGarbage: true
						})));
					}
				}),
				new ButtonWidget({
					title: "Endless Mode",
					description: ["Play For As Long As You", "Can In Endless Mode And", "Share Your Replays!"],
					callback: () -> {
						ScreenManager.switchScreen(new GameScreen(new EndlessGameStateBuilder({
							rule: {
								rngSeed: Std.int(System.time * 1000000),
								marginTime: 96,
								targetPoints: 70,
								softDropBonus: 0.5,
								popCount: 4,
								vanishHiddenRows: false,
								groupBonusTableType: TSU,
								colorBonusTableType: TSU,
								powerTableType: TSU,
								dropBonusGarbage: true,
								allClearReward: 30,
								physics: TSU,
								animations: TSU,
								dropSpeed: 2.6,
								randomizeGarbage: true,
							},
							inputDevice: AnyInputDevice.instance.sure(),
							replayData: null
						})));
					}
				}),
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
				#if kha_html5
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
