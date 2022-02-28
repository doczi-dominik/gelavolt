package game.gamestatebuilders;

import game.mediators.TransformationMediator;
import game.mediators.FrameCounter;
import game.gamemodes.TrainingGameMode;
import game.gelogroups.GeloGroup;
import game.rules.MarginTimeManager;
import game.rules.Rule;
import game.states.GameState;
import game.mediators.GarbageTargetMediator;
import game.mediators.BorderColorMediator;
import game.mediators.PauseMediator;
import save_data.Profile;
import game.simulation.ChainSimulator;
import game.fields.Field;
import game.ui.TrainingPauseMenu;
import game.boardmanagers.SingleBoardManager;
import game.boardstates.EditingBoardState;
import game.ChainCounter;
import game.all_clear.AllClearManager;
import game.previews.VerticalPreview;
import game.simulation.NullLinkInfoBuilder;
import game.gelos.Gelo;
import game.actionbuffers.LocalActionBuffer;
import game.boardstates.TrainingBoardState;
import input.InputDeviceManager;
import game.boards.TrainingBoard;
import kha.math.Random;
import game.randomizers.Randomizer;
import game.Queue;
import game.actionbuffers.NullActionBuffer;
import input.NullInputDeviceManager;
import game.screens.GameScreen;
import game.boards.SingleStateBoard;
import game.garbage.trays.CenterGarbageTray;
import game.boardmanagers.DualBoardManager;
import game.particles.ParticleManager;
import game.score.ScoreManager;
import game.garbage.trays.GarbageTray;
import game.garbage.GarbageManager;
import game.geometries.BoardGeometries;
import game.boardstates.TrainingInfoBoardState;
import game.simulation.LinkInfoBuilder;
import game.simulation.ChainSimulator;
import game.geometries.BoardOrientation;

class TrainingGameStateBuilder {
	final gameMode: TrainingGameMode;
	final transformMediator: TransformationMediator;

	var rng: Random;
	var randomizer: Randomizer;

	var particleManager: ParticleManager;
	var marginManager: MarginTimeManager;
	var frameCounter: FrameCounter;

	var pauseMediator: PauseMediator;
	var playerBorderColorMediator: BorderColorMediator;
	var playerTargetMediator: GarbageTargetMediator;
	var infoTargetMediator: GarbageTargetMediator;

	var playerGarbageManager: GarbageManager;
	var playerScoreManager: ScoreManager;
	var playerChainSim: ChainSimulator;
	var playerChainCounter: ChainCounter;
	var playerField: Field;
	var playerQueue: Queue;
	var playerInputManager: InputDeviceManager;
	var playerActionBuffer: LocalActionBuffer;
	var playerGeloGroup: GeloGroup;
	var playerAllClearManager: AllClearManager;

	var infoGarbageManager: GarbageManager;

	var infoState: TrainingInfoBoardState;
	var playState: TrainingBoardState;
	var editState: EditingBoardState;

	var playerBoard: TrainingBoard;
	var infoBoard: SingleStateBoard;

	var pauseMenu: TrainingPauseMenu;

	var gameState: GameState;

	public function new(opts: TrainingGameStateBuilderOptions) {
		gameMode = opts.gameMode;
		transformMediator = opts.transformMediator;
	}

	inline function buildRNG() {
		rng = new Random(gameMode.rngSeed);
	}

	inline function buildRandomizer() {
		randomizer = new Randomizer({
			rng: rng,
			prefsSave: Profile.primary.prefs
		});

		randomizer.currentPool = FOUR_COLOR;
		randomizer.generatePools(TSU);
	}

	inline function buildParticleManager() {
		particleManager = new ParticleManager();
	}

	inline function buildMarginManager() {
		marginManager = new MarginTimeManager(gameMode.rule);
	}

	inline function buildFrameCounter() {
		frameCounter = new FrameCounter();
	}

	inline function buildPauseMediator() {
		pauseMediator = new PauseMediator();
	}

	inline function buildPlayerBorderColorMediator() {
		playerBorderColorMediator = new BorderColorMediator();
	}

	inline function buildPlayerTargetMediator() {
		playerTargetMediator = {
			geometries: BoardGeometries.RIGHT
		};
	}

	inline function buildInfoTargetMediator() {
		infoTargetMediator = {
			geometries: BoardGeometries.LEFT
		};
	}

	inline function buildPlayerGarbageManager() {
		playerGarbageManager = new GarbageManager({
			rule: gameMode.rule,
			rng: rng,
			prefsSave: Profile.primary.prefs,
			particleManager: particleManager,
			geometries: BoardGeometries.LEFT,
			tray: CenterGarbageTray.create(Profile.primary.prefs),
			target: playerTargetMediator
		});
	}

	inline function buildPlayerScoreManager() {
		playerScoreManager = new ScoreManager({
			rule: gameMode.rule,
			orientation: LEFT
		});
	}

	inline function buildPlayerChainSim() {
		playerChainSim = new ChainSimulator({
			rule: gameMode.rule,
			linkBuilder: new LinkInfoBuilder({
				rule: gameMode.rule,
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
			prefsSave: Profile.primary.prefs,
			columns: 6,
			playAreaRows: 12,
			hiddenRows: 1,
			garbageRows: 5
		});
	}

	inline function buildPlayerQueue() {
		playerQueue = new Queue(randomizer.createQueueData(Dropsets.CLASSICAL));
	}

	inline function buildPlayerInputManager() {
		playerInputManager = new InputDeviceManager(Profile.primary.input, KEYBOARD);
	}

	inline function buildPlayerActionBuffer() {
		playerActionBuffer = new LocalActionBuffer({
			frameCounter: frameCounter,
			inputManager: playerInputManager
		});
	}

	inline function buildPlayerGeloGroup() {
		final prefsSave = Profile.primary.prefs;

		playerGeloGroup = new GeloGroup({
			field: playerField,
			rule: gameMode.rule,
			prefsSave: prefsSave,
			scoreManager: playerScoreManager,
			chainSim: new ChainSimulator({
				rule: gameMode.rule,
				linkBuilder: NullLinkInfoBuilder.instance,
				garbageDisplay: GarbageTray.create(prefsSave),
				accumulatedDisplay: GarbageTray.create(prefsSave)
			})
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
			rule: gameMode.rule,
			rng: rng,
			prefsSave: Profile.primary.prefs,
			particleManager: particleManager,
			geometries: BoardGeometries.RIGHT,
			tray: CenterGarbageTray.create(Profile.primary.prefs),
			target: infoTargetMediator
		});
	}

	inline function buildInfoState() {
		final prefsSave = Profile.primary.prefs;

		infoState = new TrainingInfoBoardState({
			geometries: BoardGeometries.RIGHT,
			marginManager: marginManager,
			rule: gameMode.rule,
			rng: rng,
			linkBuilder: new LinkInfoBuilder({
				rule: gameMode.rule,
				marginManager: marginManager
			}),
			trainingSave: Profile.primary.training,
			chainAdvantageDisplay: GarbageTray.create(prefsSave),
			afterCounterDisplay: GarbageTray.create(prefsSave),
			autoChainCounter: new ChainCounter(),
			garbageManager: infoGarbageManager,
			playerScoreManager: playerScoreManager,
			playerChainSim: playerChainSim,
		});
	}

	inline function buildPlayState() {
		playState = new TrainingBoardState({
			infoState: infoState,
			rule: gameMode.rule,
			prefsSave: Profile.primary.prefs,
			transformMediator: transformMediator,
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
			trainingSave: Profile.primary.training,
			randomizer: randomizer
		});
	}

	inline function buildEditState() {
		editState = new EditingBoardState({
			geometries: BoardGeometries.LEFT,
			inputManager: playerInputManager,
			field: Field.create({
				prefsSave: Profile.primary.prefs,
				columns: 6,
				playAreaRows: 12,
				hiddenRows: 1,
				garbageRows: 5
			}),
			chainSim: playerChainSim,
			chainCounter: playerChainCounter,
			prefsSave: Profile.primary.prefs
		});
	}

	inline function buildPlayerBoard() {
		playerBoard = new TrainingBoard({
			pauseMediator: pauseMediator,
			inputManager: playerInputManager,
			playActionBuffer: playerActionBuffer,
			playState: playState,
			editState: editState,
			infoState: infoState
		});
	}

	inline function buildInfoBoard() {
		infoBoard = new SingleStateBoard({
			pauseMediator: pauseMediator,
			inputManager: playerInputManager,
			actionBuffer: NullActionBuffer.instance,
			state: infoState
		});
	}

	inline function buildPauseMenu() {
		pauseMenu = new TrainingPauseMenu({
			pauseMediator: pauseMediator,
			rule: gameMode.rule,
			prefsSave: Profile.primary.prefs,
			randomizer: randomizer,
			queue: playerQueue,
			playState: playState,
			infoState: infoState,
			trainingBoard: playerBoard,
			allClearManager: playerAllClearManager,
			chainSim: playerChainSim,
			marginManager: marginManager,
			trainingSave: Profile.primary.training,
			playerGarbageManager: playerGarbageManager,
			infoGarbageManager: infoGarbageManager
		});
	}

	inline function buildGameState() {
		gameState = new GameState({
			particleManager: particleManager,
			marginManager: marginManager,
			boardManager: new DualBoardManager({
				boardOne: new SingleBoardManager({
					transformMediator: transformMediator,
					geometries: BoardGeometries.LEFT,
					board: playerBoard
				}),
				boardTwo: new SingleBoardManager({
					transformMediator: transformMediator,
					geometries: BoardGeometries.RIGHT,
					board: infoBoard
				})
			}),
			pauseMenu: pauseMenu,
			frameCounter: frameCounter
		});
	}

	inline function wireMediators() {
		pauseMediator.gameState = gameState;
		playerBorderColorMediator.boardState = playState;
		playerTargetMediator.garbageManager = infoGarbageManager;
		infoTargetMediator.garbageManager = playerGarbageManager;
	}

	public function build() {
		buildRNG();
		buildRandomizer();

		buildParticleManager();
		buildMarginManager();
		buildFrameCounter();

		buildPauseMediator();
		buildPlayerBorderColorMediator();
		buildPlayerTargetMediator();
		buildInfoTargetMediator();

		buildPlayerGarbageManager();
		buildPlayerScoreManager();
		buildPlayerChainSim();
		buildPlayerChainCounter();
		buildPlayerField();
		buildPlayerQueue();
		buildPlayerInputManager();
		buildPlayerActionBuffer();
		buildPlayerGeloGroup();
		buildPlayerAllClearManager();

		buildInfoGarbageManager();

		buildInfoState();
		buildPlayState();
		buildEditState();

		buildPlayerBoard();
		buildInfoBoard();

		buildPauseMenu();

		buildGameState();

		wireMediators();

		return gameState;
	}
}
