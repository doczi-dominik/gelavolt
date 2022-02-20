package game.ui;

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

	function generateInitalPage(_: Menu): Array<IListWidget> {
		return [
			new ButtonWidget({
				title: "Resume",
				description: ["Continue Chaining!"],
				callback: pauseMediator.resume
			}),
			new ListSubPageWidget({
				header: "Options",
				description: ["Change Various Options and Settings"],
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
			}),
			#if sys
			new ButtonWidget({
				title: "Exit",
				description: ["Leave GelaVolt"],
				callback: () -> {
					Sys.exit(0);
				}
			})
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
