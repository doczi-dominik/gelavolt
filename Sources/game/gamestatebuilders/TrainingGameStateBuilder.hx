package game.gamestatebuilders;

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
	final gameScreen: GameScreen;

	var primaryProfile: Profile;
	var rngSeed: Int;
	var rule: Rule;

	var rng: Random;
	var randomizer: Randomizer;

	var particleManager: ParticleManager;
	var marginManager: MarginTimeManager;

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

	public function new(gameScreen: GameScreen) {
		this.gameScreen = gameScreen;
	}

	inline function buildRNG() {
		rng = new Random(rngSeed);
	}

	inline function buildRandomizer() {
		randomizer = new Randomizer({
			rng: rng,
			prefsSave: primaryProfile.prefs
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
			rule: rule,
			rng: rng,
			prefsSave: primaryProfile.prefs,
			particleManager: particleManager,
			geometries: BoardGeometries.LEFT,
			tray: CenterGarbageTray.create(primaryProfile.prefs),
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
			garbageDisplay: GarbageTray.create(primaryProfile.prefs),
			accumulatedDisplay: GarbageTray.create(primaryProfile.prefs)
		});
	}

	inline function buildPlayerChainCounter() {
		playerChainCounter = new ChainCounter();
	}

	inline function buildPlayerField() {
		playerField = Field.create({
			prefsSave: primaryProfile.prefs,
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
		playerInputManager = new InputDeviceManager(primaryProfile.input);
	}

	inline function buildPlayerActionBuffer() {
		playerActionBuffer = new LocalActionBuffer({
			gameScreen: gameScreen,
			inputManager: playerInputManager
		});
	}

	inline function buildPlayerGeloGroup() {
		final prefsSave = primaryProfile.prefs;

		playerGeloGroup = new GeloGroup({
			field: playerField,
			rule: rule,
			prefsSave: prefsSave,
			scoreManager: playerScoreManager,
			chainSim: new ChainSimulator({
				rule: rule,
				linkBuilder: NullLinkInfoBuilder.getInstance(),
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
			rule: rule,
			rng: rng,
			prefsSave: primaryProfile.prefs,
			particleManager: particleManager,
			geometries: BoardGeometries.RIGHT,
			tray: CenterGarbageTray.create(primaryProfile.prefs),
			target: infoTargetMediator
		});
	}

	inline function buildInfoState() {
		final prefsSave = primaryProfile.prefs;

		infoState = new TrainingInfoBoardState({
			geometries: BoardGeometries.RIGHT,
			marginManager: marginManager,
			rule: rule,
			rng: rng,
			linkBuilder: new LinkInfoBuilder({
				rule: rule,
				marginManager: marginManager
			}),
			trainingSave: primaryProfile.training,
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
			rule: rule,
			prefsSave: primaryProfile.prefs,
			gameScreen: gameScreen,
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
			trainingSave: primaryProfile.training,
			randomizer: randomizer
		});
	}

	inline function buildEditState() {
		editState = new EditingBoardState({
			geometries: BoardGeometries.LEFT,
			inputManager: playerInputManager,
			field: Field.create({
				prefsSave: primaryProfile.prefs,
				columns: 6,
				playAreaRows: 12,
				hiddenRows: 1,
				garbageRows: 5
			}),
			chainSim: playerChainSim,
			chainCounter: playerChainCounter,
			prefsSave: primaryProfile.prefs
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
			actionBuffer: NullActionBuffer.getInstance(),
			state: infoState
		});
	}

	inline function buildPauseMenu() {
		pauseMenu = new TrainingPauseMenu({
			pauseMediator: pauseMediator,
			rule: rule,
			prefsSave: primaryProfile.prefs,
			randomizer: randomizer,
			queue: playerQueue,
			playState: playState,
			infoState: infoState,
			trainingBoard: playerBoard,
			allClearManager: playerAllClearManager,
			chainSim: playerChainSim,
			marginManager: marginManager,
			trainingSave: primaryProfile.training,
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
					gameScreen: gameScreen,
					geometries: BoardGeometries.LEFT,
					board: playerBoard
				}),
				boardTwo: new SingleBoardManager({
					gameScreen: gameScreen,
					geometries: BoardGeometries.RIGHT,
					board: infoBoard
				})
			}),
			pauseMenu: pauseMenu
		});
	}

	inline function wireMediators() {
		pauseMediator.gameState = gameState;
		playerBorderColorMediator.boardState = playState;
		playerTargetMediator.garbageManager = infoGarbageManager;
		infoTargetMediator.garbageManager = playerGarbageManager;
	}

	public function setPrimaryProfile(value: Profile) {
		primaryProfile = value;

		return this;
	}

	public function setRNGSeed(value: Int) {
		rngSeed = value;

		return this;
	}

	public function setRule(value: Rule) {
		rule = value;

		return this;
	}

	public function build() {
		buildRNG();
		buildRandomizer();

		buildParticleManager();
		buildMarginManager();

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

		gameState.pause(playerInputManager);

		return gameState;
	}
}
