package main_menu.ui;

import ui.SubPageWidget;
import save_data.PrefsSave;
import save_data.SaveManager;
import ui.NumberRangeWidget;
import ui.YesNoWidget;
import game.ui.ControlsPageWidget;
import game.ui.ListSubPageWidget;
import ui.ListMenuPage;
#if sys
import kha.Window;
#end

class OptionsPage extends ListMenuPage {
	final prefsSave: PrefsSave;

	public function new(prefsSave: PrefsSave) {
		this.prefsSave = prefsSave;

		super({
			header: "Options",
			widgetBuilder: (_) -> [
				new ListSubPageWidget({
					header: "Controls",
					description: ["Change Keybindings For Keyboard And Gamepads"],
					widgetBuilder: (_) -> [
						new ControlsPageWidget(MENU),
						new ControlsPageWidget(GAME),
						new ControlsPageWidget(TRAINING)
					]
				}),
				#if sys
				new SubPageWidget({
					title: "Graphics",
					description: ["Change Video Output Options"],
					subPage: new ListMenuPage({
						header: "Graphics",
						widgetBuilder: (_) -> [
							new YesNoWidget({
								title: "Fullscreen",
								description: [
									"Change Whether GelaVolt Uses A",
									"Borderless Fullscreen Window Or A",
									"Regular Window With Window Decorations"
								],
								defaultValue: SaveManager.graphics.fullscreen,
								onChange: (value) -> {
									Window.get(0).mode = value ? Fullscreen : Windowed;
									SaveManager.graphics.fullscreen = value;
									SaveManager.saveGraphics();
								}
							})
						]
					})
				}),
				#end
				new ListSubPageWidget({
					header: "Personalization",
					description: ["Change Various Options Related", "To Appearance And Game Mechanics"],
					widgetBuilder: (_) -> [
						new ListSubPageWidget({
							header: "Gelo Group Shadow Options",
							description: ["Change Various Options Related", "To the Gelo Group Shadow Appearance"],
							widgetBuilder: (_) -> [
								new YesNoWidget({
									title: "Enable",
									description: ["Enable Or Disable The Shadow", "That Shows Where Gelo", "Groups Will Fall"],
									defaultValue: prefsSave.showGroupShadow,
									onChange: (value) -> {
										prefsSave.showGroupShadow = value;
										SaveManager.saveProfiles();
									}
								}),
								new NumberRangeWidget({
									title: "Opacity",
									description: ["Change The Transparency Of The", "Gelo Group Shadow"],
									minValue: 0,
									maxValue: 1,
									delta: 0.1,
									startValue: prefsSave.shadowOpacity,
									onChange: (value) -> {
										prefsSave.shadowOpacity = value;
										SaveManager.saveProfiles();
									}
								}),
								new YesNoWidget({
									title: "Highlight Rotating Shadows",
									description: ["Alter The Appearance Of Rotating", "Gelos' Shadow"],
									defaultValue: prefsSave.shadowHighlightOthers,
									onChange: (value) -> {
										prefsSave.shadowHighlightOthers = value;
										SaveManager.saveProfiles();
									}
								}),
								new YesNoWidget({
									title: "Show Potential Chain Triggering",
									description: ["Animate The Gelo Group Shadow", "If A Chain Is About To Be", "Triggered"],
									defaultValue: prefsSave.shadowWillTriggerChain,
									onChange: (value) -> {
										prefsSave.shadowWillTriggerChain = value;
										SaveManager.saveProfiles();
									}
								})
							]
						})
					]
				})
			]
		});
	}
}
