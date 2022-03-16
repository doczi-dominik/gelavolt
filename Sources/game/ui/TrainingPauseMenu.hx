package game.ui;

import game.mediators.ControlDisplayContainer;
import game.rules.ColorBonusTableType;
import game.rules.PowerTableType;
import ui.NumberRangeWidget;
import ui.YesNoWidget;
import ui.ButtonWidget;
import save_data.SaveManager;
import save_data.ClearOnXMode;
import game.garbage.GarbageManager;
import save_data.TrainingSettings;
import game.rules.MarginTimeManager;
import game.simulation.ChainSimulator;
import game.all_clear.AllClearManager;
import game.boards.TrainingBoard;
import game.boardstates.TrainingInfoBoardState;
import game.boardstates.TrainingBoardState;
import game.Queue;
import game.randomizers.Randomizer;
import game.rules.Rule;
import ui.OptionListWidget;
import ui.Menu;
import ui.IListWidget;
import ui.SubPageWidget;

class TrainingPauseMenu extends PauseMenu {
	final rule: Rule;
	final randomizer: Randomizer;
	final queue: Queue;
	final playState: TrainingBoardState;
	final infoState: TrainingInfoBoardState;
	final trainingBoard: TrainingBoard;
	final allClearManager: AllClearManager;
	final chainSim: ChainSimulator;
	final marginManager: MarginTimeManager;
	final trainingSettings: TrainingSettings;
	final playerGarbageManager: GarbageManager;
	final infoGarbageManager: GarbageManager;
	final controlDisplayContainer: ControlDisplayContainer;

	public function new(opts: TrainingPauseMenuOptions) {
		rule = opts.rule;
		randomizer = opts.randomizer;
		queue = opts.queue;
		playState = opts.playState;
		infoState = opts.infoState;
		trainingBoard = opts.trainingBoard;
		allClearManager = opts.allClearManager;
		chainSim = opts.chainSim;
		marginManager = opts.marginManager;
		trainingSettings = opts.trainingSettings;
		playerGarbageManager = opts.playerGarbageManager;
		infoGarbageManager = opts.infoGarbageManager;
		controlDisplayContainer = opts.controlDisplayContainer;

		super(opts);
	}

	override function generateInitalPage(_: Menu): Array<IListWidget> {
		final trainingSettings = new ListSubPageWidget({
			header: "Training Options",
			description: ["Change Various Options And Settings", "To Help Elevate Your Practice!"],
			widgetBuilder: (_) -> [
				new ListSubPageWidget({
					header: "Misc. Options",
					description: ["Change Miscelaneous", "Training Options"],
					widgetBuilder: (_) -> [
						new YesNoWidget({
							title: "Show Control Hints",
							description: ["Show Or Hide The Control Display", "At The Bottom"],
							defaultValue: controlDisplayContainer.isVisible,
							onChange: (value) -> {
								controlDisplayContainer.isVisible = value;
							}
						}),
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
							startIndex: switch (trainingSettings.clearOnXMode) {
								case CLEAR: 0;
								case RESTART: 1;
								case NEW: 2;
							},
							onChange: (value) -> {
								trainingSettings.clearOnXMode = value;
								SaveManager.saveProfiles();
							}
						}),
						new ButtonWidget({
							title: "Clear Player Garbage Tray",
							description: ["Clear The Garbage Tray Above", "The Board You Control"],
							callback: playerGarbageManager.clear
						}),
						new ButtonWidget({
							title: "Clear Info Garbage Tray",
							description: ["Clear The Garbage Tray Above", "The Information Display"],
							callback: infoGarbageManager.clear
						}),
						new YesNoWidget({
							title: "Garbage Auto-Clear",
							description: [
								"Automatically Clear The",
								"Garbage Tray Above The",
								"Information Display Before",
								"Every Chain"
							],
							defaultValue: trainingSettings.autoClear,
							onChange: (value) -> {
								trainingSettings.autoClear = value;
								SaveManager.saveProfiles();
							}
						}),
						new ListSubPageWidget({
							header: "Auto-Attack Options",
							description: [
								"Practice Your Neutral Skills",
								"By Defending Against",
								" Periodically Sent Chains!"
							],
							widgetBuilder: (_) -> [
								new YesNoWidget({
									title: "Enable",
									description: ["Enable Or Disable", "Auto-Attacking"],
									defaultValue: trainingSettings.autoAttack,
									onChange: (value) -> {
										trainingSettings.autoAttack = value;
										SaveManager.saveProfiles();
									}
								}),
								new ButtonWidget({
									title: "Reset Timer",
									description: ["Reset The Auto-Attack", "Timer"],
									callback: infoState.resetAutoAttackWaitingState
								}),
								new NumberRangeWidget({
									title: "Min. Delay",
									description: ["Set The Minimum Delay Before", "The Chain Is Triggered", "In Seconds"],
									minValue: 1,
									maxValue: 90,
									delta: 1,
									startValue: trainingSettings.minAttackTime,
									onChange: (value) -> {
										trainingSettings.minAttackTime = Std.int(value);
										infoState.resetAutoAttackWaitingState();
										SaveManager.saveProfiles();
									}
								}),
								new NumberRangeWidget({
									title: "Max. Delay",
									description: ["Set The Maximum Delay Before", "The Chain Is Triggered", "In Seconds"],
									minValue: 1,
									maxValue: 90,
									delta: 1,
									startValue: trainingSettings.maxAttackTime,
									onChange: (value) -> {
										trainingSettings.maxAttackTime = Std.int(value);
										infoState.resetAutoAttackWaitingState();
										SaveManager.saveProfiles();
									}
								}),
								new NumberRangeWidget({
									title: "Min. Chain",
									description: ["Set The Smallest Chain", "That Can Be Sent"],
									minValue: 1,
									maxValue: 50,
									delta: 1,
									startValue: trainingSettings.minAttackChain,
									onChange: (value) -> {
										trainingSettings.minAttackChain = Std.int(value);
										SaveManager.saveProfiles();
									}
								}),
								new NumberRangeWidget({
									title: "Max. Chain",
									description: ["Set The Largest Chain", "That Can Be Sent"],
									minValue: 1,
									maxValue: 50,
									delta: 1,
									startValue: trainingSettings.maxAttackChain,
									onChange: (value) -> {
										trainingSettings.maxAttackChain = Std.int(value);
										SaveManager.saveProfiles();
									}
								}),
								new NumberRangeWidget({
									title: "Min. Colors",
									description: ["Set The Minimum Number of", "Colors That Can Be Used", "In The Chain"],
									minValue: 1,
									maxValue: 5,
									delta: 1,
									startValue: trainingSettings.minAttackColors,
									onChange: (value) -> {
										trainingSettings.minAttackColors = Std.int(value);
										SaveManager.saveProfiles();
									}
								}),
								new NumberRangeWidget({
									title: "Max. Colors",
									description: ["Set The Maximum Number of", "Colors That Can Be Used", "In the Chain"],
									minValue: 1,
									maxValue: 5,
									delta: 1,
									startValue: trainingSettings.maxAttackColors,
									onChange: (value) -> {
										trainingSettings.maxAttackColors = Std.int(value);
										SaveManager.saveProfiles();
									}
								}),
								new NumberRangeWidget({
									title: "Min. Plus Gelos/Color",
									description: ["Set The Minimum", " Number of Gelos That", "Can Be Added To", "The Pop Count"],
									minValue: 0,
									maxValue: 14,
									delta: 1,
									startValue: trainingSettings.minAttackGroupDiff,
									onChange: (value) -> {
										trainingSettings.minAttackGroupDiff = Std.int(value);
										SaveManager.saveProfiles();
									}
								}),
								new NumberRangeWidget({
									title: "Max. Plus Gelos/Color",
									description: ["Set The Maximum", " Number Of Gelos That", "Can Be Added To", "The Pop Count"],
									minValue: 0,
									maxValue: 14,
									delta: 1,
									startValue: trainingSettings.maxAttackGroupDiff,
									onChange: (value) -> {
										trainingSettings.maxAttackGroupDiff = Std.int(value);
										SaveManager.saveProfiles();
									}
								})
							]
						})
					]
				}),
				new ListSubPageWidget({
					header: "Queue Options",
					description: ["Change Options Related To The NEXT Queue"],
					widgetBuilder: (_) -> [
						new SubPageWidget({
							title: "Edit Queue",
							description: ["View And Edit Gelo Groups", "In The Current Queue"],
							subPage: new QueueEditorPage({
								queue: queue,
								groupEditor: new GroupEditorPage(queue)
							})
						}),
						new ButtonWidget({
							title: "Randomizer: TSU",
							description: ["Change The Randomizer Algorithm", "(Sorry, Only TSU For Now)"],
							callback: doNothing,
						}),
						new ButtonWidget({
							title: "Dropset: CLASSICAL",
							description: [
								"Change The Dropset Used For",
								"Queue Generation",
								"(Sorry, Only CLASSICAL For Now)"
							],
							callback: doNothing,
						}),
						new NumberRangeWidget({
							title: "Colors",
							description: ["Change The Number Of Possible", "Gelo Colors"],
							minValue: 3,
							maxValue: 5,
							delta: 1,
							startValue: randomizer.currentPool,
							onChange: (value) -> {
								randomizer.currentPool = Std.int(value);
							}
						}),
						new ButtonWidget({
							title: "Regenerate Queue",
							description: ["Regenerate Groups Based On", "The Settings Above"],
							callback: () -> {
								playState.regenerateQueue();
								playState.previousGroup();
							}
						})
					]
				}),
				new ListSubPageWidget({
					header: "Field Options",
					description: ["Change Options Related to the Field"],
					widgetBuilder: (_) -> [
						new ButtonWidget({
							title: "Trigger All Clear",
							description: ["Trigger An All Clear", "Without Changing The Field"],
							callback: () -> {
								allClearManager.startAnimation();
							},
						}),
						new ButtonWidget({
							title: "Clear Field (No AC)",
							description: ["Clear The Field Of Gelos", "Without Triggering An All Clear"],
							callback: () -> {
								trainingBoard.clearField();
							},
						}),
						new ButtonWidget({
							title: "Clear Field (Trigger All Clear)",
							description: ["Clear The Field Of Gelos", "And Trigger an All Clear"],
							callback: () -> {
								trainingBoard.clearField();
								allClearManager.startAnimation();
							}
						}),
						new NumberRangeWidget({
							title: "Change Pop Count",
							description: ["Change The Number Of Gelos", "You Need To Connect", "To Pop Them"],
							minValue: 2,
							maxValue: 14,
							delta: 1,
							startValue: rule.popCount,
							onChange: (value) -> {
								rule.popCount = Std.int(value);
							}
						}),
						new YesNoWidget({
							title: "Vanish Ghost Row",
							description: ["Set Whether Gelos That", "Lock In the Ghost Row", "Disappear Or Not"],
							defaultValue: rule.vanishHiddenRows,
							onChange: (value) -> {
								rule.vanishHiddenRows = value;
							}
						}),
						new ListSubPageWidget({
							header: "Grid Options",
							description: ["Modify The Number Of Columns", "And Rows"],
							widgetBuilder: (_) -> [
								new NumberRangeWidget({
									title: "Change Ghost Rows",
									description: ["Change The Number Of Ghost Rows"],
									minValue: 1,
									maxValue: 2,
									delta: 1,
									startValue: trainingBoard.getField().hiddenRows,
									onChange: (value) -> {
										trainingBoard.getField().hiddenRows = Std.int(value);
									}
								}),
								new ButtonWidget({
									title: "Apply Changes",
									description: [
										"Modify The Field According to",
										"The Settings Above",
										"(WARNING: All Gelos Will Be Erased!)"
									],
									callback: () -> {
										trainingBoard.getField().createData();
									}
								}),
							]
						})
					]
				}),
				new ListSubPageWidget({
					header: "Gelo Group Options",
					description: ["Change Options Related", "to Gelo Group Handling"],
					widgetBuilder: (_) -> [
						new NumberRangeWidget({
							title: "Change Drop Speed",
							description: ["Change How Fast The", "Gelo Group Falls", "(Without Soft Drop)"],
							minValue: 0,
							maxValue: 31,
							delta: 0.1,
							startValue: rule.dropSpeed,
							onChange: (value) -> {
								rule.dropSpeed = value;
							}
						}),
						new OptionListWidget({
							title: "Physics Type",
							description: [
								"Alternate Between 'TSU' And 'FEVER'",
								"Physics Types. 'FEVER' Physics Allow",
								"You To Climb Over Adjacent",
								"Gelos More Freely!"
							],
							options: ["TSU", "FEVER"],
							startIndex: 0,
							onChange: (value) -> {
								rule.physics = (value == "FEVER") ? FEVER : TSU;
							}
						})
					]
				}),
				new ListSubPageWidget({
					header: "Ruleset Options",
					description: ["Change Options Related to the Ruleset"],
					widgetBuilder: (_) -> [
						new OptionListWidget({
							title: "Power Table",
							description: ["Choose Between 'OPP', 'TSU' And", "'TSU (Singleplayer)' Chain Power", "Tables"],
							options: [PowerTableType.OPP, TSU, TSU_SINGLEPLAYER],
							startIndex: switch (rule.powerTableType) {
								case OPP: 0;
								case TSU: 1;
								case TSU_SINGLEPLAYER: 2;
							},
							onChange: (value) -> {
								rule.powerTableType = value;
							}
						}),
						new OptionListWidget({
							title: "Color Bonus Table",
							description: ["Alternate Between 'TSU' And 'FEVER'", "Color Bonus Tables",],
							options: [ColorBonusTableType.TSU, FEVER],
							startIndex: switch (rule.colorBonusTableType) {
								case TSU: 0;
								case FEVER: 1;
							},
							onChange: (value) -> {
								rule.colorBonusTableType = value;
							}
						}),
						new OptionListWidget({
							title: "Group Bonus Table",
							description: ["Alternate Between 'TSU' And 'FEVER'", "Group Bonus Tables",],
							options: [ColorBonusTableType.TSU, FEVER],
							startIndex: switch (rule.groupBonusTableType) {
								case TSU: 0;
								case FEVER: 1;
							},
							onChange: (value) -> {
								rule.groupBonusTableType = value;
							}
						}),
						new YesNoWidget({
							title: "Enable Margin Time",
							description: ["Enable Or Disable Margin Time"],
							defaultValue: marginManager.isEnabled,
							onChange: (value) -> {
								marginManager.isEnabled = value;
							}
						}),
						new NumberRangeWidget({
							title: "Change Initial Margin Time",
							description: ["Set The Number Of Seconds", "Before The First Margin Change", "Takes Effect"],
							minValue: 0,
							maxValue: 256,
							delta: 32,
							startValue: marginManager.startMarginTime,
							onChange: (value) -> {
								marginManager.startMarginTime = Std.int(value);
							}
						}),
						new NumberRangeWidget({
							title: "Change Target Points",
							description: ["Set the Current Target Points"],
							minValue: 10,
							maxValue: 990,
							delta: 1,
							startValue: marginManager.targetPoints,
							onChange: (value) -> {
								marginManager.targetPoints = Std.int(value);
							}
						}),
						new NumberRangeWidget({
							title: "Change Initial Target Points",
							description: ["Set The Target Points Before", "The First Margin Change Takes", "Effect"],
							minValue: 10,
							maxValue: 990,
							delta: 10,
							startValue: marginManager.startTargetPoints,
							onChange: (value) -> {
								marginManager.startTargetPoints = Std.int(value);
							}
						}),
						new ButtonWidget({
							title: "Reset Margin Time + Target Points",
							description: [
								"Reset Both The Margin Timer",
								"And The Target Points To",
								"Their Initial Values"
							],
							callback: marginManager.reset
						}),
					]
				})
			]
		});

		final pauseMenuOptions = super.generateInitalPage(_);

		pauseMenuOptions.unshift(trainingSettings);

		return pauseMenuOptions;
	}

	final function doNothing() {}
}
