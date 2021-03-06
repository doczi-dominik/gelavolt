package game.gamestatebuilders;

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
import kha.math.Random;
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

	var rng: Random;
	var randomizer: Randomizer;

	var particleManager: ParticleManager;
	var marginManager: MarginTimeManager;
	var frameCounter: FrameCounter;

	var playerBorderColorMediator: BorderColorMediator;
	var playerTargetMediator: GarbageTargetMediator;
	var infoTargetMediator: GarbageTargetMediator;

	var playerGarbageManager: GarbageManager;
	var playerScoreManager: ScoreManager;
	var playerChainSim: ChainSimulator;
	var playerChainCounter: ChainCounter;
	var playerField: Field;
	var playerQueue: Queue;
	var playerInputDevice: IInputDevice;
	var playerActionBuffer: LocalActionBuffer;
	var playerGeloGroup: GeloGroup;
	var playerAllClearManager: AllClearManager;

	var infoGarbageManager: GarbageManager;
	var autoAttackManager: AutoAttackManager;

	var infoState: TrainingInfoBoardState;
	var playState: TrainingBoardState;
	var editState: EditingBoardState;

	var playerBoard: TrainingBoard;
	var infoBoard: SingleStateBoard;

	public var pauseMediator(null, default): PauseMediator;
	public var controlDisplayContainer(null, default): ControlHintContainer;

	public var gameState(default, null): GameState;
	public var pauseMenu(default, null): TrainingPauseMenu;

	public function new(opts: TrainingGameStateBuilderOptions) {
		game.Macros.initFromOpts();
	}

	inline function buildRNG() {
		rng = new Random(rngSeed);
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
		controlDisplayContainer.isVisible = Profile.primary.trainingSettings.showControlHints;
	}

	inline function buildPlayerBorderColorMediator() {
		playerBorderColorMediator = new BorderColorMediator();
	}

	inline function buildPlayerTargetMediator() {
		playerTargetMediator = {
			geometries: BoardGeometries.INFO
		};
	}

	inline function buildInfoTargetMediator() {
		infoTargetMediator = {
			geometries: BoardGeometries.LEFT
		};
	}

	inline function buildPlayerGarbageManager() {
		playerGarbageManager = new GarbageManager({
			rule: rule,
			rng: rng,
			prefsSettings: Profile.primary.prefs,
			particleManager: particleManager,
			geometries: BoardGeometries.LEFT,
			tray: CenterGarbageTray.create(Profile.primary.prefs),
			target: playerTargetMediator
		});
	}

	inline function buildPlayerScoreManager() {
		playerScoreManager = new ScoreManager({
			rule: rule,
			orientation: LEFT
		});
	}

	inline function buildPlayerChainSim() {
		playerChainSim = new ChainSimulator({
			rule: rule,
			linkBuilder: new LinkInfoBuilder({
				rule: rule,
				marginManager: marginManager
			}),
			garbageDisplay: GarbageTray.create(Profile.primary.prefs),
			accumulatedDisplay: GarbageTray.create(Profile.primary.prefs)
		});
	}

	inline function buildPlayerChainCounter() {
		playerChainCounter = new ChainCounter();
	}

	inline function buildPlayerField() {
		playerField = Field.create({
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

	inline function buildPlayerInputDevice() {
		playerInputDevice = AnyInputDevice.instance;
	}

	inline function buildPlayerActionBuffer() {
		playerActionBuffer = new LocalActionBuffer({
			frameCounter: frameCounter,
			inputDevice: playerInputDevice
		});
	}

	inline function buildPlayerGeloGroup() {
		final prefsSettings = Profile.primary.prefs;

		playerGeloGroup = new TrainingGeloGroup({
			field: playerField,
			rule: rule,
			prefsSettings: prefsSettings,
			scoreManager: playerScoreManager,
			chainSim: new ChainSimulator({
				rule: rule,
				linkBuilder: NullLinkInfoBuilder.instance,
				garbageDisplay: GarbageTray.create(prefsSettings),
				accumulatedDisplay: GarbageTray.create(prefsSettings)
			}),
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

	inline function buildInfoGarbageManager() {
		infoGarbageManager = new GarbageManager({
			rule: rule,
			rng: rng,
			prefsSettings: Profile.primary.prefs,
			particleManager: particleManager,
			geometries: BoardGeometries.INFO,
			tray: CenterGarbageTray.create(Profile.primary.prefs),
			target: infoTargetMediator
		});
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
			chainCounter: new ChainCounter(),
			particleManager: particleManager
		});
	}

	inline function buildInfoState() {
		final prefsSettings = Profile.primary.prefs;

		infoState = new TrainingInfoBoardState({
			geometries: BoardGeometries.INFO,
			marginManager: marginManager,
			rule: rule,
			linkBuilder: new LinkInfoBuilder({
				rule: rule,
				marginManager: marginManager
			}),
			trainingSettings: Profile.primary.trainingSettings,
			chainAdvantageDisplay: GarbageTray.create(prefsSettings),
			afterCounterDisplay: GarbageTray.create(prefsSettings),
			prefsSettings: prefsSettings,
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
			preview: new VerticalPreview(playerQueue),
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

	inline function buildEditState() {
		editState = new EditingBoardState({
			geometries: BoardGeometries.LEFT,
			inputDevice: playerInputDevice,
			field: Field.create({
				prefsSettings: Profile.primary.prefs,
				columns: 6,
				playAreaRows: 12,
				hiddenRows: 1,
				garbageRows: 5
			}),
			chainSim: playerChainSim,
			chainCounter: playerChainCounter,
			prefsSettings: Profile.primary.prefs
		});
	}

	inline function buildPlayerBoard() {
		playerBoard = new TrainingBoard({
			pauseMediator: pauseMediator,
			inputDevice: playerInputDevice,
			playActionBuffer: playerActionBuffer,
			controlDisplayContainer: controlDisplayContainer,
			playState: playState,
			editState: editState,
			infoState: infoState,
		});
	}

	inline function buildInfoBoard() {
		infoBoard = new SingleStateBoard({
			pauseMediator: pauseMediator,
			inputDevice: playerInputDevice,
			playActionBuffer: NullActionBuffer.instance,
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
			controlDisplayContainer: controlDisplayContainer,
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
		playerBorderColorMediator.boardState = playState;
		playerTargetMediator.garbageManager = infoGarbageManager;
		infoTargetMediator.garbageManager = playerGarbageManager;
	}
}
