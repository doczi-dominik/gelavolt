package game.gamestatebuilders;

import game.garbage.trays.NullGarbageTray;
import game.mediators.ControlHintContainer;
import game.rules.Rule;
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
import game.mediators.SaveGameStateMediator;

@:structInit
@:build(game.Macros.buildOptionsClass(VersusGameStateBuilder))
@:build(game.Macros.addGameStateBuilderType(VERSUS))
class VersusGameStateBuilderOptions implements IGameStateBuilderOptions {}

@:build(game.Macros.addGameStateBuildMethod())
class VersusGameStateBuilder implements IGameStateBuilder {
	@inject final rngSeed: Int;
	@inject final rule: Rule;
	@inject final frameCounter: FrameCounter;
	@inject final leftActionBuffer: IActionBuffer;
	@inject final rightActionBuffer: IActionBuffer;

	@copy var rng: CopyableRNG;
	@copy var randomizer: Randomizer;

	@copy var particleManager: ParticleManager;
	@copy var marginManager: MarginTimeManager;

	@copy var leftBorderColorMediator: BorderColorMediator;
	@copy var leftTargetMediator: GarbageTargetMediator;
	@copy var rightBorderColorMediator: BorderColorMediator;
	@copy var rightTargetMediator: GarbageTargetMediator;

	@copy var leftGarbageTray: CenterGarbageTray;
	@copy var leftGarbageManager: GarbageManager;
	@copy var leftScoreManager: ScoreManager;
	@copy var leftChainSimDisplay: GarbageTray;
	@copy var leftChainSimAccumDisplay: GarbageTray;
	@copy var leftChainSim: ChainSimulator;
	@copy var leftChainCounter: ChainCounter;
	@copy var leftField: Field;
	@copy var leftQueue: Queue;
	var leftInputDevice: IInputDevice;
	@copy var leftGeloGroup: GeloGroup;
	@copy var leftAllClearManager: AllClearManager;
	@copy var leftPreview: VerticalPreview;

	@copy var rightGarbageTray: CenterGarbageTray;
	@copy var rightGarbageManager: GarbageManager;
	@copy var rightScoreManager: ScoreManager;
	@copy var rightChainSimDisplay: GarbageTray;
	@copy var rightChainSimAccumDisplay: GarbageTray;
	@copy var rightChainSim: ChainSimulator;
	@copy var rightChainCounter: ChainCounter;
	@copy var rightField: Field;
	@copy var rightQueue: Queue;
	@copy var rightInputDevice: IInputDevice;
	@copy var rightGeloGroup: GeloGroup;
	@copy var rightAllClearManager: AllClearManager;
	@copy var rightPreview: VerticalPreview;

	@copy var leftState: StandardBoardState;
	@copy var rightState: StandardBoardState;

	var leftBoard: SingleStateBoard;
	var rightBoard: SingleStateBoard;

	public var pauseMediator(null, default): PauseMediator;
	@copy public var controlHintContainer(null, default): ControlHintContainer;
	public var saveGameStateMediator(null, default): SaveGameStateMediator;

	public var gameState(default, null): GameState;
	public var pauseMenu(default, null): PauseMenu;

	public function new(opts: VersusGameStateBuilderOptions) {
		Macros.initFromOpts();
	}

	public function copy() {
		return new VersusGameStateBuilder({
			rngSeed: rngSeed,
			rule: rule,
			frameCounter: new FrameCounter().copyFrom(frameCounter),
			leftActionBuffer: null,
			rightActionBuffer: null
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
			rule: rule,
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
			rule: rule,
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
			rule: rule,
			linkBuilder: new LinkInfoBuilder({
				rule: rule,
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

	inline function buildLeftInputDevice() {
		leftInputDevice = AnyInputDevice.instance;
	}

	inline function buildLeftGeloGroup() {
		final prefsSettings = Profile.primary.prefs;

		leftGeloGroup = new GeloGroup({
			field: leftField,
			rule: rule,
			prefsSettings: prefsSettings,
			scoreManager: leftScoreManager,
			chainSim: new ChainSimulator({
				rule: rule,
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
			rule: rule,
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
			rule: rule,
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
			rule: rule,
			linkBuilder: new LinkInfoBuilder({
				rule: rule,
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

	inline function buildRightGeloGroup() {
		final prefsSettings = Profile.primary.prefs;

		rightGeloGroup = new GeloGroup({
			field: rightField,
			rule: rule,
			prefsSettings: prefsSettings,
			scoreManager: rightScoreManager,
			chainSim: new ChainSimulator({
				rule: rule,
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
		leftState = new StandardBoardState({
			rule: rule,
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
		});
	}

	inline function buildRightBoardState() {
		rightState = new StandardBoardState({
			rule: rule,
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
		gameState = new GameState({
			particleManager: particleManager,
			marginManager: marginManager,
			boardManager: new DualBoardManager({
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
