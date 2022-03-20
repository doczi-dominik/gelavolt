package main_menu.ui;

import ui.AreYouSureSubPageWidget;
import input.GamepadBrand;
import ui.OptionListWidget;
import ui.IListWidget;
import input.IInputDevice;
import input.AnyInputDevice;
import ui.KeyboardConfirmWrapper;
import ui.AnyGamepadDetectWrapper;
import ui.InputLimitedListPage;
import game.ui.ControlsPageWidget;
import ui.SubPageWidget;
import save_data.PrefsSettings;
import save_data.SaveManager;
import ui.NumberRangeWidget;
import ui.YesNoWidget;
import game.ui.ListSubPageWidget;
import ui.ListMenuPage;
#if sys
import kha.Window;
#end

class OptionsPage extends ListMenuPage {
	final prefsSettings: PrefsSettings;

	public function new(prefsSettings: PrefsSettings) {
		this.prefsSettings = prefsSettings;

		super({
			header: "Options",
			widgetBuilder: (_) -> [
				new ListSubPageWidget({
					header: "Controls",
					description: ["Change Keybindings For Keyboard And Gamepads"],
					widgetBuilder: (menu) -> {
						final inputDevice = menu.inputDevice;

						var middle: Array<IListWidget>;

						switch (inputDevice.type) {
							case KEYBOARD | GAMEPAD:
								middle = buildControls(inputDevice);
							case ANY:
								final keyboardDevice = AnyInputDevice.instance.getKeyboard();

								middle = [
									new SubPageWidget({
										title: "Keyboard Controls",
										description: ["Change Keybindings"],
										subPage: new KeyboardConfirmWrapper({
											keyboardDevice: keyboardDevice,
											pageBuilder: () -> new InputLimitedListPage({
												header: "Keyboard Controls",
												inputDevice: keyboardDevice,
												widgetBuilder: (_) -> buildControls(keyboardDevice)
											})
										})
									}),
									new SubPageWidget({
										title: "Gamepad Controls",
										description: ["Change Gamepad Bindings"],
										subPage: new AnyGamepadDetectWrapper({
											keyboardDevice: keyboardDevice,
											pageBuilder: (gamepadDevice) -> new InputLimitedListPage({
												header: "Gamepad Controls",
												inputDevice: gamepadDevice,
												widgetBuilder: (_) -> buildControls(gamepadDevice)
											})
										})
									})
								];
						}

						return buildUniversalTop(inputDevice).concat(middle).concat(buildUniversalBottom(inputDevice));
					}
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
									defaultValue: prefsSettings.showGroupShadow,
									onChange: (value) -> {
										prefsSettings.showGroupShadow = value;
										SaveManager.saveProfiles();
									}
								}),
								new NumberRangeWidget({
									title: "Opacity",
									description: ["Change The Transparency Of The", "Gelo Group Shadow"],
									minValue: 0,
									maxValue: 1,
									delta: 0.1,
									startValue: prefsSettings.shadowOpacity,
									onChange: (value) -> {
										prefsSettings.shadowOpacity = value;
										SaveManager.saveProfiles();
									}
								}),
								new YesNoWidget({
									title: "Highlight Rotating Shadows",
									description: ["Alter The Appearance Of Rotating", "Gelos' Shadow"],
									defaultValue: prefsSettings.shadowHighlightOthers,
									onChange: (value) -> {
										prefsSettings.shadowHighlightOthers = value;
										SaveManager.saveProfiles();
									}
								}),
								new YesNoWidget({
									title: "Show Potential Chain Triggering",
									description: ["Animate The Gelo Group Shadow", "If A Chain Is About To Be", "Triggered"],
									defaultValue: prefsSettings.shadowWillTriggerChain,
									onChange: (value) -> {
										prefsSettings.shadowWillTriggerChain = value;
										SaveManager.saveProfiles();
									}
								})
							]
						})
					]
				}),
				new SubPageWidget({
					title: "Profiles",
					description: ["View and Edit Profiles"],
					subPage: new ProfileListPage()
				})
			]
		});
	}

	function buildUniversalTop(inputDevice: IInputDevice): Array<IListWidget> {
		final inputSettings = inputDevice.inputSettings;

		return [
			new NumberRangeWidget({
				title: "Gamepad Stick Deadzone",
				description: [
					"Adjust The Threshold Where",
					"The Analog Stick Doesn't Respond",
					"To Inputs",
					"",
					"Increase This Value In Small Increments",
					" If You Experience Drifting, Rebounding",
					"or Weird Inputs In General"
				],
				startValue: inputSettings.deadzone,
				minValue: 0,
				maxValue: 0.9,
				delta: 0.05,
				onChange: (value) -> {
					inputSettings.deadzone = value;
					SaveManager.saveProfiles();
				}
			}),
			new OptionListWidget({
				title: "Gamepad Brand",
				description: ["Change The Type Of Button Icons", "To Display"],
				options: [GamepadBrand.DS4, SW_PRO, JOYCON, XBONE, XB360],
				startIndex: switch (inputSettings.gamepadBrand) {
					case DS4: 0;
					case SW_PRO: 1;
					case JOYCON: 2;
					case XBONE: 3;
					case XB360: 4;
				},
				onChange: (value) -> {
					inputSettings.gamepadBrand = value;
					SaveManager.saveProfiles();
				}
			}),
		];
	}

	function buildUniversalBottom(inputDevice: IInputDevice): Array<IListWidget> {
		return [
			new AreYouSureSubPageWidget({
				title: "Reset To Default",
				description: ["Reset Input Settings"],
				content: "This Will IRREVERSIBLY Reset Your Input Settings",
				callback: () -> {
					inputDevice.inputSettings.setDefaults();
					SaveManager.saveProfiles();
				}
			})
		];
	}

	function buildControls(inputDevice: IInputDevice): Array<IListWidget> {
		return [
			new ControlsPageWidget({
				title: "Menu Controls",
				description: ["Change Controls Related To", "Menu Navigation"],
				actions: [PAUSE, MENU_LEFT, MENU_RIGHT, MENU_UP, MENU_DOWN, BACK, CONFIRM],
				inputDevice: inputDevice
			}),
			new ControlsPageWidget({
				title: "Game Controls",
				description: ["Change Controls Related To", "Gameplay"],
				actions: [SHIFT_LEFT, SHIFT_RIGHT, SOFT_DROP, HARD_DROP, ROTATE_LEFT, ROTATE_RIGHT],
				inputDevice: inputDevice
			}),
			new ListSubPageWidget({
				header: "Training Controls",
				description: ["Change Controls Specific To", "Training Mode"],
				widgetBuilder: (_) -> [
					new ControlsPageWidget({
						title: "Universal Controls",
						description: ["Change Controls That Are Used", "Both In Play Mode And", "Edit Mode"],
						actions: [TOGGLE_EDIT_MODE],
						inputDevice: inputDevice
					}),
					new ControlsPageWidget({
						title: "Play Mode Controls",
						description: ["Change Controls That Are Only", "Available In Play Mode"],
						actions: [PREVIOUS_GROUP, NEXT_GROUP],
						inputDevice: inputDevice
					}),
					new ControlsPageWidget({
						title: "Edit Mode Controls",
						description: ["Change Controls That Are Only", "Available In Edit Mode"],
						actions: [
							EDIT_LEFT, EDIT_RIGHT, EDIT_UP, EDIT_DOWN, EDIT_CLEAR, EDIT_SET, PREVIOUS_STEP, NEXT_STEP, PREVIOUS_COLOR, NEXT_COLOR,
							TOGGLE_MARKERS
						],
						inputDevice: inputDevice
					})
				]
			}),
		];
	}
}
