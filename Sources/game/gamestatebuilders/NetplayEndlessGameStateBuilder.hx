package game.gamestatebuilders;

import game.net.logger.NullSessionLogger;
import game.rules.VersusRule;
import game.boardstates.EndlessBoardState;
import game.rules.AnimationsType;
import game.rules.PhysicsType;
import game.rules.PowerTableType;
import game.rules.ColorBonusTableType;
import game.rules.GroupBonusTableType;
import utils.ValueBox;
import game.mediators.RollbackMediator;
import game.actionbuffers.NullActionBuffer;
import game.garbage.trays.NullGarbageTray;
import game.mediators.ControlHintContainer;
import game.boardmanagers.SingleBoardManager;
import game.boardmanagers.DualBoardManager;
import input.NullInputDevice;
import game.actionbuffers.IActionBuffer;
import game.previews.VerticalPreview;
import input.AnyInputDevice;
import game.simulation.NullLinkInfoBuilder;
import game.garbage.trays.GarbageTray;
import game.simulation.LinkInfoBuilder;
import game.garbage.trays.CenterGarbageTray;
import game.geometries.BoardGeometries;
import save_data.Profile;
import game.states.GameState;
import game.ui.PauseMenu;
import game.boards.SingleStateBoard;
import game.boardstates.StandardBoardState;
import game.gelogroups.GeloGroup;
import input.IInputDevice;
import game.fields.Field;
import game.simulation.ChainSimulator;
import game.garbage.GarbageManager;
import game.mediators.GarbageTargetMediator;
import game.mediators.BorderColorMediator;
import game.mediators.PauseMediator;
import game.rules.MarginTimeManager;
import game.particles.ParticleManager;
import game.randomizers.Randomizer;
import game.copying.CopyableRNG;
import game.mediators.FrameCounter;
#if kha_html5
import game.net.SessionManager;
import game.actionbuffers.ReceiveActionBuffer;
import game.actionbuffers.SenderActionBuffer;
#end

using Safety;

@:structInit
@:build(game.Macros.buildOptionsClass(NetplayEndlessGameStateBuilder))
class NetplayEndlessGameStateBuilderOptions {}

@:build(game.Macros.addGameStateBuildMethod())
class NetplayEndlessGameStateBuilder implements INetplayGameStateBuilder {
	@inject final rule: VersusRule;
	@inject final isLocalOnLeft: Bool;
	@inject final session: Null<SessionManager>;

	@inject @copy final frameCounter: FrameCounter;

	var garbageDropLimit: ValueBox<Int>;
	var garbageConfirmGracePeriod: ValueBox<Int>;
	var softDropBonus: ValueBox<Float>;
	var popCount: ValueBox<Int>;
	var vanishHiddenRows: ValueBox<Bool>;
	var groupBonusTableType: ValueBox<GroupBonusTableType>;
	var colorBonusTableType: ValueBox<ColorBonusTableType>;
	var powerTableType: ValueBox<PowerTableType>;
	var dropBonusGarbage: ValueBox<Bool>;
	var allClearReward: ValueBox<Int>;
	var physics: ValueBox<PhysicsType>;
	var animations: ValueBox<AnimationsType>;
	var dropSpeed: ValueBox<Float>;
	var randomizeGarbage: ValueBox<Bool>;

	@copy var rng: CopyableRNG;
	@copy var randomizer: Randomizer;

	@copy var particleManager: ParticleManager;
	@copy var marginManager: MarginTimeManager;

	@copy var leftBorderColorMediator: BorderColorMediator;
	@copy var leftTargetMediator: GarbageTargetMediator;
	@copy var rightBorderColorMediator: BorderColorMediator;
	@copy var rightTargetMediator: GarbageTargetMediator;

	@copyFrom var leftGarbageTray: CenterGarbageTray;
	@copy var leftGarbageManager: GarbageManager;
	@copy var leftScoreManager: ScoreManager;
	@copyFrom var leftChainSimDisplay: GarbageTray;
	@copyFrom var leftChainSimAccumDisplay: GarbageTray;
	@copy var leftChainSim: ChainSimulator;
	@copy var leftChainCounter: ChainCounter;
	@copy var leftField: Field;
	@copy var leftQueue: Queue;
	var leftInputDevice: IInputDevice;
	var leftActionBuffer: IActionBuffer;
	@copy var leftGeloGroup: GeloGroup;
	@copy var leftAllClearManager: AllClearManager;
	@copy var leftPreview: VerticalPreview;

	@copyFrom var rightGarbageTray: CenterGarbageTray;
	@copy var rightGarbageManager: GarbageManager;
	@copy var rightScoreManager: ScoreManager;
	@copyFrom var rightChainSimDisplay: GarbageTray;
	@copyFrom var rightChainSimAccumDisplay: GarbageTray;
	@copy var rightChainSim: ChainSimulator;
	@copy var rightChainCounter: ChainCounter;
	@copy var rightField: Field;
	@copy var rightQueue: Queue;
	var rightInputDevice: IInputDevice;
	var rightActionBuffer: IActionBuffer;
	@copy var rightGeloGroup: GeloGroup;
	@copy var rightAllClearManager: AllClearManager;
	@copy var rightPreview: VerticalPreview;

	@copy var leftState: StandardBoardState;
	@copy var rightState: StandardBoardState;

	var leftBoard: SingleStateBoard;
	var rightBoard: SingleStateBoard;

	public var pauseMediator(null, default): Null<PauseMediator>;
	@nullCopyFrom public var controlHintContainer(null, default): Null<ControlHintContainer>;
	public var rollbackMediator(null, default): Null<RollbackMediator>;

	public var gameState(default, null): GameState;
	public var pauseMenu(default, null): PauseMenu;

	public function new(opts: NetplayEndlessGameStateBuilderOptions) {
		Macros.initFromOpts();
	}

	public function createBackupBuilder() {
		return new NetplayEndlessGameStateBuilder({
			rule: rule,
			isLocalOnLeft: isLocalOnLeft,
			session: null,
			frameCounter: new FrameCounter()
		});
	}

	inline function initValueBoxes() {
		garbageDropLimit = rule.garbageDropLimit;
		garbageConfirmGracePeriod = rule.garbageConfirmGracePeriod;
		softDropBonus = rule.softDropBonus;
		popCount = rule.popCount;
		vanishHiddenRows = rule.vanishHiddenRows;
		groupBonusTableType = rule.groupBonusTableType;
		colorBonusTableType = rule.colorBonusTableType;
		powerTableType = rule.powerTableType;
		dropBonusGarbage = rule.dropBonusGarbage;
		allClearReward = rule.allClearReward;
		physics = rule.physics;
		animations = rule.animations;
		dropSpeed = rule.dropSpeed;
		randomizeGarbage = rule.randomizeGarbage;
	}

	inline function initPauseMediator() {
		if (pauseMediator == null) {
			pauseMediator = {
				pause: (_) -> {},
				resume: () -> {}
			};
		}
	}

	inline function initControlHintContainer() {
		if (controlHintContainer == null) {
			controlHintContainer = new ControlHintContainer();
		}

		controlHintContainer.isVisible = Profile.primary.trainingSettings.showControlHints;
	}

	inline function initRollbackMediator() {
		if (rollbackMediator == null) {
			rollbackMediator = {
				logger: NullSessionLogger.instance,
				confirmFrame: () -> {},
				rollback: () -> {}
			};
		}
	}

	inline function buildRNG() {
		rng = new CopyableRNG(rule.rngSeed);
	}

	inline function buildRandomizer() {
		randomizer = new Randomizer({
			rng: rng,
			prefsSettings: Profile.primary.prefs
		});

		randomizer.currentPool = FOUR_COLOR;
		randomizer.generatePools(TSU);
	}

	inline function buildParticleManager() {
		particleManager = new ParticleManager();
	}

	inline function buildMarginManager() {
		marginManager = new MarginTimeManager(rule.marginTime, rule.targetPoints);
	}

	inline function buildLeftBorderColorMediator() {
		leftBorderColorMediator = new BorderColorMediator();
	}

	inline function buildLeftTargetMediator() {
		leftTargetMediator = new GarbageTargetMediator(BoardGeometries.RIGHT);
	}

	inline function buildRightBorderColorMediator() {
		rightBorderColorMediator = new BorderColorMediator();
	}

	inline function buildRightTargetMediator() {
		rightTargetMediator = new GarbageTargetMediator(BoardGeometries.LEFT);
	}

	inline function buildLeftGarbageTray() {
		leftGarbageTray = CenterGarbageTray.create(Profile.primary.prefs);
	}

	inline function buildLeftGarbageManager() {
		leftGarbageManager = new GarbageManager({
			garbageDropLimit: garbageDropLimit,
			confirmGracePeriod: garbageConfirmGracePeriod,
			rng: rng,
			prefsSettings: Profile.primary.prefs,
			particleManager: particleManager,
			geometries: BoardGeometries.LEFT,
			tray: leftGarbageTray,
			target: leftTargetMediator
		});
	}

	inline function buildLeftScoreManager() {
		leftScoreManager = new ScoreManager({
			softDropBonus: softDropBonus,
			orientation: LEFT
		});
	}

	inline function buildLeftChainSimDisplay() {
		leftChainSimDisplay = GarbageTray.create(Profile.primary.prefs);
	}

	inline function buildLeftChainSimAccumDisplay() {
		leftChainSimAccumDisplay = GarbageTray.create(Profile.primary.prefs);
	}

	inline function buildLeftChainSim() {
		leftChainSim = new ChainSimulator({
			popCount: popCount,
			vanishHiddenRows: vanishHiddenRows,
			linkBuilder: new LinkInfoBuilder({
				groupBonusTableType: groupBonusTableType,
				colorBonusTableType: colorBonusTableType,
				powerTableType: powerTableType,
				dropBonusGarbage: dropBonusGarbage,
				allClearReward: allClearReward,
				marginManager: marginManager
			}),
			garbageDisplay: leftChainSimDisplay,
			accumulatedDisplay: leftChainSimAccumDisplay
		});
	}

	inline function buildLeftChainCounter() {
		leftChainCounter = new ChainCounter();
	}

	inline function buildLeftField() {
		leftField = new Field({
			prefsSettings: Profile.primary.prefs,
			columns: 6,
			playAreaRows: 12,
			hiddenRows: 1,
			garbageRows: 5
		});
	}

	inline function buildLeftQueue() {
		leftQueue = new Queue(randomizer.createQueueData(Dropsets.CLASSICAL));
	}

	inline function buildLeftInputHandling() {
		if (session == null) {
			leftInputDevice = NullInputDevice.instance;
			leftActionBuffer = NullActionBuffer.instance;

			return;
		}

		if (isLocalOnLeft) {
			leftInputDevice = AnyInputDevice.instance;

			leftActionBuffer = new SenderActionBuffer({
				session: session,
				frameCounter: frameCounter,
				inputDevice: leftInputDevice,
				frameDelay: Profile.primary.input.netplayDelay
			});

			return;
		}

		leftInputDevice = NullInputDevice.instance;

		final recvAB = new ReceiveActionBuffer({
			frameCounter: frameCounter,
			rollbackMediator: rollbackMediator
		});

		leftActionBuffer = recvAB;
		session.onInput = recvAB.onInput;
	}

	inline function buildLeftGeloGroup() {
		final prefsSettings = Profile.primary.prefs;

		leftGeloGroup = new GeloGroup({
			physics: physics,
			animations: animations,
			dropSpeed: dropSpeed,
			field: leftField,
			prefsSettings: prefsSettings,
			scoreManager: leftScoreManager,
			chainSim: new ChainSimulator({
				popCount: popCount,
				vanishHiddenRows: vanishHiddenRows,
				linkBuilder: NullLinkInfoBuilder.instance,
				garbageDisplay: NullGarbageTray.instance,
				accumulatedDisplay: NullGarbageTray.instance
			}),
		});
	}

	inline function buildLeftAllClearManager() {
		leftAllClearManager = new AllClearManager({
			rng: rng,
			particleManager: particleManager,
			geometries: BoardGeometries.LEFT,
			borderColorMediator: leftBorderColorMediator
		});
	}

	inline function buildLeftPreview() {
		leftPreview = new VerticalPreview(leftQueue);
	}

	inline function buildRightGarbageTray() {
		rightGarbageTray = CenterGarbageTray.create(Profile.primary.prefs);
	}

	inline function buildRightGarbageManager() {
		rightGarbageManager = new GarbageManager({
			garbageDropLimit: garbageDropLimit,
			confirmGracePeriod: garbageConfirmGracePeriod,
			rng: rng,
			prefsSettings: Profile.primary.prefs,
			particleManager: particleManager,
			geometries: BoardGeometries.RIGHT,
			tray: rightGarbageTray,
			target: rightTargetMediator
		});
	}

	inline function buildRightScoreManager() {
		rightScoreManager = new ScoreManager({
			softDropBonus: softDropBonus,
			orientation: LEFT
		});
	}

	inline function buildRightChainSimDisplay() {
		rightChainSimDisplay = GarbageTray.create(Profile.primary.prefs);
	}

	inline function buildRightChainSimAccumDisplay() {
		rightChainSimAccumDisplay = GarbageTray.create(Profile.primary.prefs);
	}

	inline function buildRightChainSim() {
		rightChainSim = new ChainSimulator({
			popCount: popCount,
			vanishHiddenRows: vanishHiddenRows,
			linkBuilder: new LinkInfoBuilder({
				groupBonusTableType: groupBonusTableType,
				colorBonusTableType: colorBonusTableType,
				powerTableType: powerTableType,
				dropBonusGarbage: dropBonusGarbage,
				allClearReward: allClearReward,
				marginManager: marginManager
			}),
			garbageDisplay: rightChainSimDisplay,
			accumulatedDisplay: rightChainSimAccumDisplay
		});
	}

	inline function buildRightChainCounter() {
		rightChainCounter = new ChainCounter();
	}

	inline function buildRightField() {
		rightField = new Field({
			prefsSettings: Profile.primary.prefs,
			columns: 6,
			playAreaRows: 12,
			hiddenRows: 1,
			garbageRows: 5
		});
	}

	inline function buildRightQueue() {
		rightQueue = new Queue(randomizer.createQueueData(Dropsets.CLASSICAL));
	}

	inline function buildRightInputDevice() {
		rightInputDevice = NullInputDevice.instance;
	}

	inline function buildRightInputHandling() {
		if (session == null) {
			rightInputDevice = NullInputDevice.instance;
			rightActionBuffer = NullActionBuffer.instance;

			return;
		}

		if (isLocalOnLeft) {
			rightInputDevice = NullInputDevice.instance;

			final recvAB = new ReceiveActionBuffer({
				frameCounter: frameCounter,
				rollbackMediator: rollbackMediator
			});

			rightActionBuffer = recvAB;
			session.onInput = recvAB.onInput;

			return;
		}

		rightInputDevice = AnyInputDevice.instance;

		rightActionBuffer = new SenderActionBuffer({
			session: session,
			frameCounter: frameCounter,
			inputDevice: rightInputDevice,
			frameDelay: Profile.primary.input.netplayDelay
		});
	}

	inline function buildRightGeloGroup() {
		final prefsSettings = Profile.primary.prefs;

		rightGeloGroup = new GeloGroup({
			physics: physics,
			animations: animations,
			dropSpeed: dropSpeed,
			field: rightField,
			prefsSettings: prefsSettings,
			scoreManager: rightScoreManager,
			chainSim: new ChainSimulator({
				popCount: popCount,
				vanishHiddenRows: vanishHiddenRows,
				linkBuilder: NullLinkInfoBuilder.instance,
				garbageDisplay: NullGarbageTray.instance,
				accumulatedDisplay: NullGarbageTray.instance
			}),
		});
	}

	inline function buildRightAllClearManager() {
		rightAllClearManager = new AllClearManager({
			rng: rng,
			particleManager: particleManager,
			geometries: BoardGeometries.RIGHT,
			borderColorMediator: rightBorderColorMediator
		});
	}

	inline function buildRightPreview() {
		rightPreview = new VerticalPreview(rightQueue);
	}

	inline function buildLeftBoardState() {
		leftState = new EndlessBoardState({
			animations: animations,
			randomizeGarbage: randomizeGarbage,
			prefsSettings: Profile.primary.prefs,
			rng: rng,
			geometries: BoardGeometries.LEFT,
			particleManager: particleManager,
			geloGroup: leftGeloGroup,
			field: leftField,
			garbageManager: leftGarbageManager,
			queue: leftQueue,
			preview: leftPreview,
			allClearManager: leftAllClearManager,
			scoreManager: leftScoreManager,
			actionBuffer: leftActionBuffer,
			chainCounter: leftChainCounter,
			chainSim: leftChainSim,
			randomizer: randomizer,
			marginManager: marginManager,
			clearOnXModeContainer: Profile.primary.endlessSettings
		});
	}

	inline function buildRightBoardState() {
		rightState = new EndlessBoardState({
			animations: animations,
			randomizeGarbage: randomizeGarbage,
			prefsSettings: Profile.primary.prefs,
			rng: rng,
			geometries: BoardGeometries.RIGHT,
			particleManager: particleManager,
			geloGroup: rightGeloGroup,
			field: rightField,
			garbageManager: rightGarbageManager,
			queue: rightQueue,
			preview: rightPreview,
			allClearManager: rightAllClearManager,
			scoreManager: rightScoreManager,
			actionBuffer: rightActionBuffer,
			chainCounter: rightChainCounter,
			chainSim: rightChainSim,
			randomizer: randomizer,
			marginManager: marginManager,
			clearOnXModeContainer: Profile.primary.endlessSettings
		});
	}

	inline function buildLeftBoard() {
		leftBoard = new SingleStateBoard({
			pauseMediator: pauseMediator,
			inputDevice: leftInputDevice,
			state: leftState,
		});
	}

	inline function buildRightBoard() {
		rightBoard = new SingleStateBoard({
			pauseMediator: pauseMediator,
			inputDevice: rightInputDevice,
			state: rightState,
		});
	}

	inline function buildPauseMenu() {
		pauseMenu = new PauseMenu({
			pauseMediator: pauseMediator,
			prefsSettings: Profile.primary.prefs
		});
	}

	inline function buildGameState() {
		final priority = (session != null) ? session.localID < session.remoteID : true;

		gameState = new GameState({
			particleManager: particleManager,
			marginManager: marginManager,
			boardManager: new DualBoardManager({
				doesBoardOneHavePriority: priority,
				boardOne: new SingleBoardManager({
					board: leftBoard,
					geometries: BoardGeometries.LEFT
				}),
				boardTwo: new SingleBoardManager({
					board: rightBoard,
					geometries: BoardGeometries.RIGHT
				})
			}),
			frameCounter: frameCounter
		});
	}

	inline function wireMediators() {
		leftBorderColorMediator.changeColor = leftState.changeBorderColor;
		leftTargetMediator.garbageManager = rightGarbageManager;

		rightBorderColorMediator.changeColor = rightState.changeBorderColor;
		rightTargetMediator.garbageManager = leftGarbageManager;
	}
}
