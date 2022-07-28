package game.gamestatebuilders;

import game.garbage.trays.NullGarbageTray;
import game.rules.Rule;
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
import game.actionbuffers.NullActionBuffer;
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

@:structInit
@:build(game.Macros.buildOptionsClass(TrainingGameStateBuilder))
class TrainingGameStateBuilderOptions {
	static final type = 0;

	public function getType() {
		return type;
	}
}

@:build(game.Macros.addGameStateBuildMethod())
class TrainingGameStateBuilder implements IGameStateBuilder {
	@inject final rngSeed: Int;
	@inject final rule: Rule;

	@copy var rng: CopyableRNG;
	@copy var randomizer: Randomizer;

	@copy var particleManager: ParticleManager;
	@copy var marginManager: MarginTimeManager;
	@copy var frameCounter: FrameCounter;

	var playerBorderColorMediator: BorderColorMediator;
	var playerTargetMediator: GarbageTargetMediator;
	var infoTargetMediator: GarbageTargetMediator;

	@copy var playerGarbageTray: CenterGarbageTray;
	@copy var playerGarbageManager: GarbageManager;
	@copy var playerScoreManager: ScoreManager;
	@copy var playerChainSimDisplay: GarbageTray;
	@copy var playerChainSimAccumDisplay: GarbageTray;
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

	@copy var infoGarbageTray: CenterGarbageTray;
	@copy var infoGarbageManager: GarbageManager;
	@copy var autoAttackChainCounter: ChainCounter;
	@copy var autoAttackManager: AutoAttackManager;
	@copy var infoChainAdvantageDisplay: GarbageTray;
	@copy var infoAfterCounterDisplay: GarbageTray;

	@copy var editField: Field;

	@copy var infoState: TrainingInfoBoardState;
	@copy var playState: TrainingBoardState;
	@copy var editState: EditingBoardState;

	@copy var playerBoard: TrainingBoard;
	@copy var infoBoard: SingleStateBoard;

	public var pauseMediator(null, default): PauseMediator;
	@copy public var controlHintContainer(null, default): ControlHintContainer;
	public var saveGameStateMediator(null, default): SaveGameStateMediator;

	public var gameState(default, null): GameState;
	public var pauseMenu(default, null): TrainingPauseMenu;

	public function new(opts: TrainingGameStateBuilderOptions) {
		game.Macros.initFromOpts();
	}

	public function copy() {
		return new TrainingGameStateBuilder({
			rngSeed: rngSeed,
			rule: rule
		});
	}

	inline function buildRNG() {
		rng = new CopyableRNG(rngSeed);
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
		marginManager = new MarginTimeManager(rule);
	}

	inline function buildFrameCounter() {
		frameCounter = new FrameCounter();
	}

	inline function initControlHintContainer() {
		controlHintContainer.isVisible = Profile.primary.trainingSettings.showControlHints;
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
			rule: rule,
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
			rule: rule,
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
			rule: rule,
			linkBuilder: new LinkInfoBuilder({
				rule: rule,
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
			frameDelay: 0
		});
	}

	inline function buildPlayerGeloGroupChainSim() {
		playerGeloGroupChainSim = new ChainSimulator({
			rule: rule,
			linkBuilder: NullLinkInfoBuilder.instance,
			garbageDisplay: NullGarbageTray.instance,
			accumulatedDisplay: NullGarbageTray.instance
		});
	}

	inline function buildPlayerGeloGroup() {
		playerGeloGroup = new TrainingGeloGroup({
			field: playerField,
			rule: rule,
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
			rule: rule,
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
			rule: rule,
			rng: rng,
			geometries: BoardGeometries.INFO,
			trainingSettings: Profile.primary.trainingSettings,
			prefsSettings: Profile.primary.prefs,
			linkBuilder: new LinkInfoBuilder({
				rule: rule,
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
			geometries: BoardGeometries.INFO,
			marginManager: marginManager,
			rule: rule,
			linkBuilder: new LinkInfoBuilder({
				rule: rule,
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
			infoState: infoState,
			rule: rule,
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
			pauseMediator: pauseMediator,
			rule: rule,
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
