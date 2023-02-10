package game.gamestatebuilders;

import game.rules.VersusRule;
import game.rules.AnimationsType;
import game.rules.PhysicsType;
import game.rules.PowerTableType;
import game.rules.ColorBonusTableType;
import game.rules.GroupBonusTableType;
import utils.ValueBox;
import game.garbage.trays.NullGarbageTray;
import game.auto_attack.AutoAttackManager;
import game.gelogroups.TrainingGeloGroup;
import game.mediators.ControlHintContainer;
import input.AnyInputDevice;
import input.IInputDevice;
import game.mediators.FrameCounter;
import game.gelogroups.GeloGroup;
import game.rules.MarginTimeManager;
import game.states.GameState;
import game.mediators.GarbageTargetMediator;
import game.mediators.BorderColorMediator;
import game.mediators.PauseMediator;
import save_data.Profile;
import game.fields.Field;
import game.ui.TrainingPauseMenu;
import game.boardmanagers.SingleBoardManager;
import game.boardstates.EditingBoardState;
import game.ChainCounter;
import game.AllClearManager;
import game.previews.VerticalPreview;
import game.simulation.NullLinkInfoBuilder;
import game.actionbuffers.LocalActionBuffer;
import game.boardstates.TrainingBoardState;
import game.boards.TrainingBoard;
import game.copying.CopyableRNG;
import game.randomizers.Randomizer;
import game.Queue;
import game.boards.SingleStateBoard;
import game.garbage.trays.CenterGarbageTray;
import game.boardmanagers.DualBoardManager;
import game.particles.ParticleManager;
import game.ScoreManager;
import game.garbage.trays.GarbageTray;
import game.garbage.GarbageManager;
import game.geometries.BoardGeometries;
import game.boardstates.TrainingInfoBoardState;
import game.simulation.LinkInfoBuilder;
import game.simulation.ChainSimulator;
import game.mediators.SaveGameStateMediator;

using Safety;

@:build(game.Macros.addGameStateBuildMethod())
class TrainingGameStateBuilder implements IBackupGameStateBuilder {
	final rule: VersusRule;

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
	@copy var frameCounter: FrameCounter;

	var playerBorderColorMediator: BorderColorMediator;
	var playerTargetMediator: GarbageTargetMediator;
	var infoTargetMediator: GarbageTargetMediator;

	@copyFrom var playerGarbageTray: CenterGarbageTray;
	@copy var playerGarbageManager: GarbageManager;
	@copy var playerScoreManager: ScoreManager;
	@copyFrom var playerChainSimDisplay: GarbageTray;
	@copyFrom var playerChainSimAccumDisplay: GarbageTray;
	@copy var playerChainSim: ChainSimulator;
	@copy var playerChainCounter: ChainCounter;
	@copy var playerField: Field;
	@copy var playerQueue: Queue;
	@copy var playerPreview: VerticalPreview;
	@copy var playerInputDevice: IInputDevice;
	var playerActionBuffer: LocalActionBuffer;
	@copy var playerGeloGroupChainSim: ChainSimulator;
	@copy var playerGeloGroup: GeloGroup;
	@copy var playerAllClearManager: AllClearManager;

	@copyFrom var infoGarbageTray: CenterGarbageTray;
	@copy var infoGarbageManager: GarbageManager;
	@copy var autoAttackChainCounter: ChainCounter;
	@copy var autoAttackManager: AutoAttackManager;
	@copyFrom var infoChainAdvantageDisplay: GarbageTray;
	@copyFrom var infoAfterCounterDisplay: GarbageTray;

	@copy var editField: Field;

	@copy var infoState: TrainingInfoBoardState;
	@copy var playState: TrainingBoardState;
	@copy var editState: EditingBoardState;

	@copy var playerBoard: TrainingBoard;
	@copy var infoBoard: SingleStateBoard;

	public var pauseMediator(null, default): Null<PauseMediator>;
	@nullCopyFrom public var controlHintContainer(null, default): Null<ControlHintContainer>;
	public var saveGameStateMediator(null, default): Null<SaveGameStateMediator>;

	public var gameState(default, null): GameState;
	public var pauseMenu(default, null): TrainingPauseMenu;

	public function new(rule: VersusRule) {
		this.rule = rule;
	}

	public function createBackupBuilder() {
		return new TrainingGameStateBuilder(rule);
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

	inline function initSaveGameStateMediator() {
		if (saveGameStateMediator == null) {
			saveGameStateMediator = {
				loadState: () -> {},
				saveState: () -> {},
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

	inline function buildFrameCounter() {
		frameCounter = new FrameCounter();
	}

	inline function buildPlayerBorderColorMediator() {
		playerBorderColorMediator = new BorderColorMediator();
	}

	inline function buildPlayerTargetMediator() {
		playerTargetMediator = new GarbageTargetMediator(BoardGeometries.INFO);
	}

	inline function buildInfoTargetMediator() {
		infoTargetMediator = new GarbageTargetMediator(BoardGeometries.LEFT);
	}

	inline function buildPlayerGarbageTray() {
		playerGarbageTray = CenterGarbageTray.create(Profile.primary.prefs);
	}

	inline function buildPlayerGarbageManager() {
		playerGarbageManager = new GarbageManager({
			garbageDropLimit: garbageDropLimit,
			confirmGracePeriod: garbageConfirmGracePeriod,
			rng: rng,
			prefsSettings: Profile.primary.prefs,
			particleManager: particleManager,
			geometries: BoardGeometries.LEFT,
			tray: playerGarbageTray,
			target: playerTargetMediator
		});
	}

	inline function buildPlayerScoreManager() {
		playerScoreManager = new ScoreManager({
			softDropBonus: softDropBonus,
			orientation: LEFT
		});
	}

	inline function buildPlayerChainSimDisplay() {
		playerChainSimDisplay = GarbageTray.create(Profile.primary.prefs);
	}

	inline function buildPlayerChainSimAccumDisplay() {
		playerChainSimAccumDisplay = GarbageTray.create(Profile.primary.prefs);
	}

	inline function buildPlayerChainSim() {
		playerChainSim = new ChainSimulator({
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
			garbageDisplay: playerChainSimDisplay,
			accumulatedDisplay: playerChainSimAccumDisplay
		});
	}

	inline function buildPlayerChainCounter() {
		playerChainCounter = new ChainCounter();
	}

	inline function buildPlayerField() {
		playerField = new Field({
			prefsSettings: Profile.primary.prefs,
			columns: 6,
			playAreaRows: 12,
			hiddenRows: 1,
			garbageRows: 5
		});
	}

	inline function buildPlayerQueue() {
		playerQueue = new Queue(randomizer.createQueueData(Dropsets.CLASSICAL));
	}

	inline function buildPlayerPreview() {
		playerPreview = new VerticalPreview(playerQueue);
	}

	inline function buildPlayerInputDevice() {
		playerInputDevice = AnyInputDevice.instance;
	}

	inline function buildPlayerActionBuffer() {
		playerActionBuffer = new LocalActionBuffer({
			frameCounter: frameCounter,
			inputDevice: playerInputDevice,
			frameDelay: Profile.primary.input.localDelay
		});
	}

	inline function buildPlayerGeloGroupChainSim() {
		playerGeloGroupChainSim = new ChainSimulator({
			popCount: popCount,
			vanishHiddenRows: vanishHiddenRows,
			linkBuilder: NullLinkInfoBuilder.instance,
			garbageDisplay: NullGarbageTray.instance,
			accumulatedDisplay: NullGarbageTray.instance
		});
	}

	inline function buildPlayerGeloGroup() {
		playerGeloGroup = new TrainingGeloGroup({
			physics: physics,
			animations: animations,
			dropSpeed: dropSpeed,
			field: playerField,
			prefsSettings: Profile.primary.prefs,
			scoreManager: playerScoreManager,
			chainSim: playerGeloGroupChainSim,
			trainingSettings: Profile.primary.trainingSettings
		});
	}

	inline function buildPlayerAllClearManager() {
		playerAllClearManager = new AllClearManager({
			rng: rng,
			particleManager: particleManager,
			geometries: BoardGeometries.LEFT,
			borderColorMediator: playerBorderColorMediator
		});
	}

	inline function buildInfoGarbageTray() {
		infoGarbageTray = CenterGarbageTray.create(Profile.primary.prefs);
	}

	inline function buildInfoGarbageManager() {
		infoGarbageManager = new GarbageManager({
			garbageDropLimit: garbageDropLimit,
			confirmGracePeriod: garbageConfirmGracePeriod,
			rng: rng,
			prefsSettings: Profile.primary.prefs,
			particleManager: particleManager,
			geometries: BoardGeometries.INFO,
			tray: infoGarbageTray,
			target: infoTargetMediator
		});
	}

	inline function buildAutoAttackChainCounter() {
		autoAttackChainCounter = new ChainCounter();
	}

	inline function buildAutoAttackManager() {
		autoAttackManager = new AutoAttackManager({
			popCount: popCount,
			rng: rng,
			geometries: BoardGeometries.INFO,
			trainingSettings: Profile.primary.trainingSettings,
			prefsSettings: Profile.primary.prefs,
			linkBuilder: new LinkInfoBuilder({
				groupBonusTableType: groupBonusTableType,
				colorBonusTableType: colorBonusTableType,
				powerTableType: powerTableType,
				dropBonusGarbage: dropBonusGarbage,
				allClearReward: allClearReward,
				marginManager: marginManager
			}),
			garbageManager: infoGarbageManager,
			chainCounter: autoAttackChainCounter,
			particleManager: particleManager
		});
	}

	inline function buildInfoChainAdvantageDisplay() {
		infoChainAdvantageDisplay = GarbageTray.create(Profile.primary.prefs);
	}

	inline function buildInfoAfterCounterDisplay() {
		infoAfterCounterDisplay = GarbageTray.create(Profile.primary.prefs);
	}

	inline function buildInfoState() {
		infoState = new TrainingInfoBoardState({
			popCount: popCount,
			geometries: BoardGeometries.INFO,
			marginManager: marginManager,
			linkBuilder: new LinkInfoBuilder({
				groupBonusTableType: groupBonusTableType,
				colorBonusTableType: colorBonusTableType,
				powerTableType: powerTableType,
				dropBonusGarbage: dropBonusGarbage,
				allClearReward: allClearReward,
				marginManager: marginManager
			}),
			trainingSettings: Profile.primary.trainingSettings,
			chainAdvantageDisplay: infoChainAdvantageDisplay,
			afterCounterDisplay: infoAfterCounterDisplay,
			prefsSettings: Profile.primary.prefs,
			autoAttackManager: autoAttackManager,
			playerScoreManager: playerScoreManager,
			playerChainSim: playerChainSim,
			garbageManager: infoGarbageManager,
		});
	}

	inline function buildPlayState() {
		playState = new TrainingBoardState({
			animations: animations,
			randomizeGarbage: randomizeGarbage,
			infoState: infoState,
			prefsSettings: Profile.primary.prefs,
			rng: rng,
			geometries: BoardGeometries.LEFT,
			particleManager: particleManager,
			geloGroup: playerGeloGroup,
			field: playerField,
			garbageManager: playerGarbageManager,
			queue: playerQueue,
			preview: playerPreview,
			allClearManager: playerAllClearManager,
			scoreManager: playerScoreManager,
			actionBuffer: playerActionBuffer,
			chainCounter: playerChainCounter,
			chainSim: playerChainSim,
			trainingSettings: Profile.primary.trainingSettings,
			randomizer: randomizer,
			clearOnXModeContainer: Profile.primary.trainingSettings,
			marginManager: marginManager,
			autoAttackManager: autoAttackManager
		});
	}

	inline function buildEditField() {
		editField = new Field({
			prefsSettings: Profile.primary.prefs,
			columns: 6,
			playAreaRows: 12,
			hiddenRows: 1,
			garbageRows: 5
		});
	}

	inline function buildEditState() {
		editState = new EditingBoardState({
			geometries: BoardGeometries.LEFT,
			inputDevice: playerInputDevice,
			field: editField,
			chainSim: playerChainSim,
			chainCounter: playerChainCounter,
			prefsSettings: Profile.primary.prefs
		});
	}

	inline function buildPlayerBoard() {
		playerBoard = new TrainingBoard({
			pauseMediator: pauseMediator,
			inputDevice: playerInputDevice,
			controlHintContainer: controlHintContainer,
			saveGameStateMediator: saveGameStateMediator,
			playState: playState,
			editState: editState,
			infoState: infoState,
		});
	}

	inline function buildInfoBoard() {
		infoBoard = new SingleStateBoard({
			pauseMediator: pauseMediator,
			inputDevice: playerInputDevice,
			state: infoState
		});
	}

	inline function buildPauseMenu() {
		pauseMenu = new TrainingPauseMenu({
			popCount: popCount,
			vanishHiddenRows: vanishHiddenRows,
			dropSpeed: dropSpeed,
			physics: physics,
			powerTableType: powerTableType,
			colorBonusTableType: colorBonusTableType,
			groupBonusTableType: groupBonusTableType,
			dropBonusGarbage: dropBonusGarbage,
			allClearReward: allClearReward,
			pauseMediator: pauseMediator,
			prefsSettings: Profile.primary.prefs,
			randomizer: randomizer,
			queue: playerQueue,
			playState: playState,
			trainingBoard: playerBoard,
			allClearManager: playerAllClearManager,
			chainSim: playerChainSim,
			marginManager: marginManager,
			trainingSettings: Profile.primary.trainingSettings,
			playerGarbageManager: playerGarbageManager,
			infoGarbageManager: infoGarbageManager,
			controlHintContainer: controlHintContainer,
			autoAttackManager: autoAttackManager
		});
	}

	inline function buildGameState() {
		gameState = new GameState({
			particleManager: particleManager,
			marginManager: marginManager,
			boardManager: new DualBoardManager({
				doesBoardOneHavePriority: true,
				boardOne: new SingleBoardManager({
					geometries: BoardGeometries.LEFT,
					board: playerBoard
				}),
				boardTwo: new SingleBoardManager({
					geometries: BoardGeometries.INFO,
					board: infoBoard
				})
			}),
			frameCounter: frameCounter,
		});
	}

	inline function wireMediators() {
		playerBorderColorMediator.changeColor = playState.changeBorderColor;
		playerTargetMediator.garbageManager = infoGarbageManager;
		infoTargetMediator.garbageManager = playerGarbageManager;
	}
}
