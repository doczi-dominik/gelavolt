package game.gamestatebuilders;

import game.boardmanagers.SingleBoardManager;
import game.boardmanagers.DualBoardManager;
import game.previews.VerticalPreview;
import game.garbage.trays.GarbageTray;
import game.simulation.NullLinkInfoBuilder;
import game.simulation.LinkInfoBuilder;
import game.garbage.trays.CenterGarbageTray;
import game.geometries.BoardGeometries;
import game.states.GameState;
import game.ui.PauseMenu;
import game.boards.SingleStateBoard;
import game.boardstates.StandardBoardState;
import game.gelogroups.GeloGroup;
import game.all_clear.AllClearManager;
import game.actionbuffers.LocalActionBuffer;
import input.InputDeviceManager;
import game.fields.Field;
import game.simulation.ChainSimulator;
import game.score.ScoreManager;
import game.garbage.GarbageManager;
import game.mediators.GarbageTargetMediator;
import game.mediators.BorderColorMediator;
import game.mediators.PauseMediator;
import game.rules.MarginTimeManager;
import game.particles.ParticleManager;
import game.randomizers.Randomizer;
import kha.math.Random;
import game.rules.Rule;
import save_data.Profile;
import game.screens.GameScreen;

class VersusGameStateBuilder {
	final gameScreen: GameScreen;

	var primaryProfile: Profile;
	var leftProfile: Profile;
	var rightProfile: Profile;
	var rngSeed: Int;
	var rule: Rule;

	var rng: Random;
	var randomizer: Randomizer;

	var particleManager: ParticleManager;
	var marginManager: MarginTimeManager;

	var pauseMediator: PauseMediator;
	var leftBorderColorMediator: BorderColorMediator;
	var leftTargetMediator: GarbageTargetMediator;
	var rightBorderColorMediator: BorderColorMediator;
	var rightTargetMediator: GarbageTargetMediator;

	var leftGarbageManager: GarbageManager;
	var leftScoreManager: ScoreManager;
	var leftChainSim: ChainSimulator;
	var leftChainCounter: ChainCounter;
	var leftField: Field;
	var leftQueue: Queue;
	var leftInputManager: InputDeviceManager;
	var leftActionBuffer: LocalActionBuffer;
	var leftGeloGroup: GeloGroup;
	var leftAllClearManager: AllClearManager;

	var rightGarbageManager: GarbageManager;
	var rightScoreManager: ScoreManager;
	var rightChainSim: ChainSimulator;
	var rightChainCounter: ChainCounter;
	var rightField: Field;
	var rightQueue: Queue;
	var rightInputManager: InputDeviceManager;
	var rightActionBuffer: LocalActionBuffer;
	var rightGeloGroup: GeloGroup;
	var rightAllClearManager: AllClearManager;

	var leftState: StandardBoardState;
	var rightState: StandardBoardState;

	var leftBoard: SingleStateBoard;
	var rightBoard: SingleStateBoard;

	var pauseMenu: PauseMenu;

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

	inline function buildLeftBorderColorMediator() {
		leftBorderColorMediator = new BorderColorMediator();
	}

	inline function buildLeftTargetMediator() {
		leftTargetMediator = {
			geometries: BoardGeometries.RIGHT
		};
	}

	inline function buildRightBorderColorMediator() {
		rightBorderColorMediator = new BorderColorMediator();
	}

	inline function buildRightTargetMediator() {
		rightTargetMediator = {
			geometries: BoardGeometries.LEFT
		};
	}

	inline function buildLeftGarbageManager() {
		leftGarbageManager = new GarbageManager({
			rule: rule,
			rng: rng,
			prefsSave: primaryProfile.prefs,
			particleManager: particleManager,
			geometries: BoardGeometries.LEFT,
			tray: CenterGarbageTray.create(primaryProfile.prefs),
			target: leftTargetMediator
		});
	}

	inline function buildLeftScoreManager() {
		leftScoreManager = new ScoreManager({
			rule: rule,
			orientation: LEFT
		});
	}

	inline function buildLeftChainSim() {
		leftChainSim = new ChainSimulator({
			rule: rule,
			linkBuilder: new LinkInfoBuilder({
				rule: rule,
				marginManager: marginManager
			}),
			garbageDisplay: GarbageTray.create(primaryProfile.prefs),
			accumulatedDisplay: GarbageTray.create(primaryProfile.prefs)
		});
	}

	inline function buildLeftChainCounter() {
		leftChainCounter = new ChainCounter();
	}

	inline function buildLeftField() {
		leftField = Field.create({
			prefsSave: primaryProfile.prefs,
			columns: 6,
			playAreaRows: 12,
			hiddenRows: 1,
			garbageRows: 5
		});
	}

	inline function buildLeftQueue() {
		leftQueue = new Queue(randomizer.createQueueData(Dropsets.CLASSICAL));
	}

	inline function buildLeftInputManager() {
		leftInputManager = new InputDeviceManager(leftProfile.input, null);
	}

	inline function buildLeftActionBuffer() {
		leftActionBuffer = new LocalActionBuffer({
			gameScreen: gameScreen,
			inputManager: leftInputManager
		});
	}

	inline function buildLeftGeloGroup() {
		final prefsSave = primaryProfile.prefs;

		leftGeloGroup = new GeloGroup({
			field: leftField,
			rule: rule,
			prefsSave: prefsSave,
			scoreManager: leftScoreManager,
			chainSim: new ChainSimulator({
				rule: rule,
				linkBuilder: NullLinkInfoBuilder.getInstance(),
				garbageDisplay: GarbageTray.create(prefsSave),
				accumulatedDisplay: GarbageTray.create(prefsSave)
			})
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

	inline function buildRightGarbageManager() {
		rightGarbageManager = new GarbageManager({
			rule: rule,
			rng: rng,
			prefsSave: primaryProfile.prefs,
			particleManager: particleManager,
			geometries: BoardGeometries.RIGHT,
			tray: CenterGarbageTray.create(primaryProfile.prefs),
			target: rightTargetMediator
		});
	}

	inline function buildRightScoreManager() {
		rightScoreManager = new ScoreManager({
			rule: rule,
			orientation: LEFT
		});
	}

	inline function buildRightChainSim() {
		rightChainSim = new ChainSimulator({
			rule: rule,
			linkBuilder: new LinkInfoBuilder({
				rule: rule,
				marginManager: marginManager
			}),
			garbageDisplay: GarbageTray.create(primaryProfile.prefs),
			accumulatedDisplay: GarbageTray.create(primaryProfile.prefs)
		});
	}

	inline function buildRightChainCounter() {
		rightChainCounter = new ChainCounter();
	}

	inline function buildRightField() {
		rightField = Field.create({
			prefsSave: primaryProfile.prefs,
			columns: 6,
			playAreaRows: 12,
			hiddenRows: 1,
			garbageRows: 5
		});
	}

	inline function buildRightQueue() {
		rightQueue = new Queue(randomizer.createQueueData(Dropsets.CLASSICAL));
	}

	inline function buildRightInputManager() {
		rightInputManager = new InputDeviceManager(rightProfile.input, null);
	}

	inline function buildRightActionBuffer() {
		rightActionBuffer = new LocalActionBuffer({
			gameScreen: gameScreen,
			inputManager: rightInputManager
		});
	}

	inline function buildRightGeloGroup() {
		final prefsSave = primaryProfile.prefs;

		rightGeloGroup = new GeloGroup({
			field: rightField,
			rule: rule,
			prefsSave: prefsSave,
			scoreManager: rightScoreManager,
			chainSim: new ChainSimulator({
				rule: rule,
				linkBuilder: NullLinkInfoBuilder.getInstance(),
				garbageDisplay: GarbageTray.create(prefsSave),
				accumulatedDisplay: GarbageTray.create(prefsSave)
			})
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

	inline function buildLeftState() {
		leftState = new StandardBoardState({
			rule: rule,
			prefsSave: primaryProfile.prefs,
			gameScreen: gameScreen,
			rng: rng,
			geometries: BoardGeometries.LEFT,
			particleManager: particleManager,
			geloGroup: leftGeloGroup,
			field: leftField,
			garbageManager: leftGarbageManager,
			queue: leftQueue,
			preview: new VerticalPreview(leftQueue),
			allClearManager: leftAllClearManager,
			scoreManager: leftScoreManager,
			actionBuffer: leftActionBuffer,
			chainCounter: leftChainCounter,
			chainSim: leftChainSim,
		});
	}

	inline function buildRightState() {
		rightState = new StandardBoardState({
			rule: rule,
			prefsSave: primaryProfile.prefs,
			gameScreen: gameScreen,
			rng: rng,
			geometries: BoardGeometries.RIGHT,
			particleManager: particleManager,
			geloGroup: rightGeloGroup,
			field: rightField,
			garbageManager: rightGarbageManager,
			queue: rightQueue,
			preview: new VerticalPreview(rightQueue),
			allClearManager: rightAllClearManager,
			scoreManager: rightScoreManager,
			actionBuffer: rightActionBuffer,
			chainCounter: rightChainCounter,
			chainSim: rightChainSim,
		});
	}

	inline function buildLeftBoard() {
		leftBoard = new SingleStateBoard({
			pauseMediator: pauseMediator,
			inputManager: leftInputManager,
			actionBuffer: leftActionBuffer,
			state: leftState
		});
	}

	inline function buildRightBoard() {
		rightBoard = new SingleStateBoard({
			pauseMediator: pauseMediator,
			inputManager: rightInputManager,
			actionBuffer: rightActionBuffer,
			state: rightState
		});
	}

	inline function buildPauseMenu() {
		pauseMenu = new PauseMenu({
			pauseMediator: pauseMediator,
			prefsSave: primaryProfile.prefs
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
					board: leftBoard
				}),
				boardTwo: new SingleBoardManager({
					gameScreen: gameScreen,
					geometries: BoardGeometries.RIGHT,
					board: rightBoard
				})
			}),
			pauseMenu: pauseMenu
		});
	}

	inline function wireMediators() {
		pauseMediator.gameState = gameState;
		leftBorderColorMediator.boardState = leftState;
		leftTargetMediator.garbageManager = rightGarbageManager;
		rightBorderColorMediator.boardState = rightState;
		rightTargetMediator.garbageManager = leftGarbageManager;
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

	public function setLeftProfile(value: Profile) {
		leftProfile = value;

		return this;
	}

	public function setRightProfile(value: Profile) {
		rightProfile = value;

		return this;
	}

	public function build() {
		buildRNG();
		buildRandomizer();

		buildParticleManager();
		buildMarginManager();

		buildPauseMediator();
		buildLeftBorderColorMediator();
		buildLeftTargetMediator();
		buildRightBorderColorMediator();
		buildRightTargetMediator();

		buildLeftGarbageManager();
		buildLeftScoreManager();
		buildLeftChainSim();
		buildLeftChainCounter();
		buildLeftField();
		buildLeftQueue();
		buildLeftInputManager();
		buildLeftActionBuffer();
		buildLeftGeloGroup();
		buildLeftAllClearManager();

		buildRightGarbageManager();
		buildRightScoreManager();
		buildRightChainSim();
		buildRightChainCounter();
		buildRightField();
		buildRightQueue();
		buildRightInputManager();
		buildRightActionBuffer();
		buildRightGeloGroup();
		buildRightAllClearManager();

		buildLeftState();
		buildRightState();

		buildLeftBoard();
		buildRightBoard();

		buildPauseMenu();

		buildGameState();

		wireMediators();

		return gameState;
	}
}
