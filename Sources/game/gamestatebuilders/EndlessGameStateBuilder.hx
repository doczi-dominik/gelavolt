package game.gamestatebuilders;

import game.actionbuffers.ReplayActionBuffer;
import game.actionbuffers.LocalActionBuffer;
import input.InputDeviceManager;
import game.gamemodes.EndlessGameMode;
import game.actionbuffers.IActionBuffer;
import input.IInputDeviceManager;
import game.ui.EndlessPauseMenu;
import game.boardstates.EndlessBoardState;
import game.boardmanagers.SingleBoardManager;
import game.previews.VerticalPreview;
import game.garbage.NullGarbageManager;
import game.simulation.LinkInfoBuilder;
import game.garbage.trays.GarbageTray;
import game.simulation.NullLinkInfoBuilder;
import game.geometries.BoardGeometries;
import game.boards.SingleStateBoard;
import game.all_clear.AllClearManager;
import game.gelogroups.GeloGroup;
import game.fields.Field;
import game.simulation.ChainSimulator;
import game.score.ScoreManager;
import game.mediators.BorderColorMediator;
import game.mediators.PauseMediator;
import game.rules.MarginTimeManager;
import game.particles.ParticleManager;
import game.randomizers.Randomizer;
import kha.math.Random;
import game.states.GameState;
import game.screens.GameScreen;

class EndlessGameStateBuilder {
	final gameScreen: GameScreen;

	final gameMode: EndlessGameMode;

	var rng: Random;
	var randomizer: Randomizer;

	var particleManager: ParticleManager;
	var marginManager: MarginTimeManager;

	var pauseMediator: PauseMediator;
	var borderColorMediator: BorderColorMediator;

	var scoreManager: ScoreManager;
	var chainSim: ChainSimulator;
	var chainCounter: ChainCounter;
	var field: Field;
	var queue: Queue;
	var inputManager: InputDeviceManager;
	var actionBuffer: IActionBuffer;
	var geloGroup: GeloGroup;
	var allClearManager: AllClearManager;

	var boardState: EndlessBoardState;

	var board: SingleStateBoard;

	var pauseMenu: EndlessPauseMenu;

	var gameState: GameState;

	public function new(gameScreen: GameScreen, gameMode: EndlessGameMode) {
		this.gameScreen = gameScreen;
		this.gameMode = gameMode;
	}

	inline function buildRNG() {
		rng = new Random(gameMode.rngSeed);
	}

	inline function buildRandomizer() {
		randomizer = new Randomizer({
			rng: rng,
			prefsSave: gameMode.profile.prefs
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

	inline function buildPauseMediator() {
		pauseMediator = new PauseMediator();
	}

	inline function buildBorderColorMediator() {
		borderColorMediator = new BorderColorMediator();
	}

	inline function buildScoreManager() {
		scoreManager = new ScoreManager({
			rule: gameMode.rule,
			orientation: LEFT
		});
	}

	inline function buildChainSim() {
		chainSim = new ChainSimulator({
			rule: gameMode.rule,
			linkBuilder: new LinkInfoBuilder({
				rule: gameMode.rule,
				marginManager: marginManager
			}),
			garbageDisplay: GarbageTray.create(gameMode.profile.prefs),
			accumulatedDisplay: GarbageTray.create(gameMode.profile.prefs)
		});
	}

	inline function buildChainCounter() {
		chainCounter = new ChainCounter();
	}

	inline function buildField() {
		field = Field.create({
			prefsSave: gameMode.profile.prefs,
			columns: 6,
			playAreaRows: 12,
			hiddenRows: 1,
			garbageRows: 5
		});
	}

	inline function buildQueue() {
		queue = new Queue(randomizer.createQueueData(Dropsets.CLASSICAL));
	}

	inline function buildInputManager() {
		inputManager = new InputDeviceManager(gameMode.profile.input);
	}

	inline function buildActionBuffer() {
		if (gameMode.replayData == null) {
			actionBuffer = new LocalActionBuffer({
				gameScreen: gameScreen,
				inputManager: inputManager
			});

			return;
		}

		actionBuffer = new ReplayActionBuffer({
			gameScreen: gameScreen,
			actions: gameMode.replayData
		});
	}

	inline function buildGeloGroup() {
		final prefsSave = gameMode.profile.prefs;

		geloGroup = new GeloGroup({
			field: field,
			rule: gameMode.rule,
			prefsSave: prefsSave,
			scoreManager: scoreManager,
			chainSim: new ChainSimulator({
				rule: gameMode.rule,
				linkBuilder: NullLinkInfoBuilder.getInstance(),
				garbageDisplay: GarbageTray.create(prefsSave),
				accumulatedDisplay: GarbageTray.create(prefsSave)
			})
		});
	}

	inline function buildAllClearManager() {
		allClearManager = new AllClearManager({
			rng: rng,
			particleManager: particleManager,
			geometries: BoardGeometries.CENTERED,
			borderColorMediator: borderColorMediator
		});
	}

	inline function buildBoardState() {
		boardState = new EndlessBoardState({
			rule: gameMode.rule,
			prefsSave: gameMode.profile.prefs,
			gameScreen: gameScreen,
			rng: rng,
			geometries: BoardGeometries.CENTERED,
			particleManager: particleManager,
			geloGroup: geloGroup,
			field: field,
			garbageManager: NullGarbageManager.getInstance(),
			queue: queue,
			preview: new VerticalPreview(queue),
			allClearManager: allClearManager,
			scoreManager: scoreManager,
			actionBuffer: actionBuffer,
			chainCounter: chainCounter,
			chainSim: chainSim,
			trainingSave: gameMode.profile.training,
			randomizer: randomizer
		});
	}

	inline function buildBoard() {
		board = new SingleStateBoard({
			actionBuffer: actionBuffer,
			pauseMediator: pauseMediator,
			inputManager: inputManager,
			state: boardState
		});
	}

	inline function buildPauseMenu() {
		pauseMenu = new EndlessPauseMenu({
			pauseMediator: pauseMediator,
			prefsSave: gameMode.profile.prefs,
			trainingSave: gameMode.profile.training,
			actionBuffer: actionBuffer,
			gameMode: gameMode
		});
	}

	inline function buildGameState() {
		gameState = new GameState({
			particleManager: particleManager,
			marginManager: marginManager,
			boardManager: new SingleBoardManager({
				gameScreen: gameScreen,
				geometries: BoardGeometries.CENTERED,
				board: board
			}),
			pauseMenu: pauseMenu
		});
	}

	inline function wireMediators() {
		pauseMediator.gameState = gameState;
		borderColorMediator.boardState = boardState;
	}

	public function build() {
		buildRNG();
		buildRandomizer();

		buildParticleManager();
		buildMarginManager();

		buildPauseMediator();
		buildBorderColorMediator();

		buildScoreManager();
		buildChainSim();
		buildChainCounter();
		buildField();
		buildQueue();
		buildInputManager();
		buildActionBuffer();
		buildGeloGroup();
		buildAllClearManager();

		buildBoardState();

		buildBoard();

		buildPauseMenu();

		buildGameState();

		wireMediators();

		return gameState;
	}
}
