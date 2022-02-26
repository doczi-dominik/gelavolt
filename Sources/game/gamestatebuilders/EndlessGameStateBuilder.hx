package game.gamestatebuilders;

import game.actionbuffers.IActionBuffer;
import input.IInputDeviceManager;
import game.ui.EndlessPauseMenu;
import game.boardstates.EndlessBoardState;
import game.boardmanagers.SingleBoardManager;
import game.boardmanagers.DualBoardManager;
import game.previews.VerticalPreview;
import game.garbage.NullGarbageManager;
import game.simulation.LinkInfoBuilder;
import game.garbage.trays.GarbageTray;
import game.simulation.NullLinkInfoBuilder;
import game.geometries.BoardGeometries;
import game.boards.SingleStateBoard;
import game.boardstates.StandardBoardState;
import game.all_clear.AllClearManager;
import game.gelogroups.GeloGroup;
import game.actionbuffers.LocalActionBuffer;
import input.InputDeviceManager;
import game.fields.Field;
import game.simulation.ChainSimulator;
import game.score.ScoreManager;
import game.mediators.BorderColorMediator;
import game.mediators.PauseMediator;
import game.rules.MarginTimeManager;
import game.particles.ParticleManager;
import game.randomizers.Randomizer;
import kha.math.Random;
import game.rules.Rule;
import save_data.Profile;
import game.states.GameState;
import game.ui.PauseMenu;
import game.screens.GameScreen;

class EndlessGameStateBuilder {
	final gameScreen: GameScreen;

	var primaryProfile: Profile;
	var rngSeed: Int;
	var rule: Rule;
	var inputManager: IInputDeviceManager;
	var actionBuffer: IActionBuffer;

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
	var geloGroup: GeloGroup;
	var allClearManager: AllClearManager;

	var boardState: EndlessBoardState;

	var board: SingleStateBoard;

	var pauseMenu: EndlessPauseMenu;

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

	inline function buildBorderColorMediator() {
		borderColorMediator = new BorderColorMediator();
	}

	inline function buildScoreManager() {
		scoreManager = new ScoreManager({
			rule: rule,
			orientation: LEFT
		});
	}

	inline function buildChainSim() {
		chainSim = new ChainSimulator({
			rule: rule,
			linkBuilder: new LinkInfoBuilder({
				rule: rule,
				marginManager: marginManager
			}),
			garbageDisplay: GarbageTray.create(primaryProfile.prefs),
			accumulatedDisplay: GarbageTray.create(primaryProfile.prefs)
		});
	}

	inline function buildChainCounter() {
		chainCounter = new ChainCounter();
	}

	inline function buildField() {
		field = Field.create({
			prefsSave: primaryProfile.prefs,
			columns: 6,
			playAreaRows: 12,
			hiddenRows: 1,
			garbageRows: 5
		});
	}

	inline function buildQueue() {
		queue = new Queue(randomizer.createQueueData(Dropsets.CLASSICAL));
	}

	inline function buildGeloGroup() {
		final prefsSave = primaryProfile.prefs;

		geloGroup = new GeloGroup({
			field: field,
			rule: rule,
			prefsSave: prefsSave,
			scoreManager: scoreManager,
			chainSim: new ChainSimulator({
				rule: rule,
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
			rule: rule,
			prefsSave: primaryProfile.prefs,
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
			trainingSave: primaryProfile.training,
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
			prefsSave: primaryProfile.prefs,
			trainingSave: primaryProfile.training,
			actionBuffer: actionBuffer
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

	public function setInputManager(value: InputDeviceManager) {
		inputManager = value;

		return this;
	}

	public function setActionBuffer(value: IActionBuffer) {
		actionBuffer = value;

		return this;
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
