package game.gamestatebuilders;

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
import kha.math.Random;
import game.mediators.FrameCounter;

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

	var rng: Random;
	var randomizer: Randomizer;

	var particleManager: ParticleManager;
	var marginManager: MarginTimeManager;

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
	var leftInputDevice: IInputDevice;
	var leftGeloGroup: GeloGroup;
	var leftAllClearManager: AllClearManager;

	var rightGarbageManager: GarbageManager;
	var rightScoreManager: ScoreManager;
	var rightChainSim: ChainSimulator;
	var rightChainCounter: ChainCounter;
	var rightField: Field;
	var rightQueue: Queue;
	var rightInputDevice: IInputDevice;
	var rightGeloGroup: GeloGroup;
	var rightAllClearManager: AllClearManager;

	var leftState: StandardBoardState;
	var rightState: StandardBoardState;

	var leftBoard: SingleStateBoard;
	var rightBoard: SingleStateBoard;

	public var pauseMediator(null, default): PauseMediator;
	public var controlDisplayContainer(null, default): ControlHintContainer;

	public var gameState(default, null): GameState;
	public var pauseMenu(default, null): PauseMenu;

	public function new(opts: VersusGameStateBuilderOptions) {
		Macros.initFromOpts();
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
			prefsSettings: Profile.primary.prefs,
			particleManager: particleManager,
			geometries: BoardGeometries.LEFT,
			tray: CenterGarbageTray.create(Profile.primary.prefs),
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
			garbageDisplay: GarbageTray.create(Profile.primary.prefs),
			accumulatedDisplay: GarbageTray.create(Profile.primary.prefs)
		});
	}

	inline function buildLeftChainCounter() {
		leftChainCounter = new ChainCounter();
	}

	inline function buildLeftField() {
		leftField = Field.create({
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
				garbageDisplay: GarbageTray.create(prefsSettings),
				accumulatedDisplay: GarbageTray.create(prefsSettings)
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

	inline function buildRightGarbageManager() {
		rightGarbageManager = new GarbageManager({
			rule: rule,
			rng: rng,
			prefsSettings: Profile.primary.prefs,
			particleManager: particleManager,
			geometries: BoardGeometries.RIGHT,
			tray: CenterGarbageTray.create(Profile.primary.prefs),
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
			garbageDisplay: GarbageTray.create(Profile.primary.prefs),
			accumulatedDisplay: GarbageTray.create(Profile.primary.prefs)
		});
	}

	inline function buildRightChainCounter() {
		rightChainCounter = new ChainCounter();
	}

	inline function buildRightField() {
		rightField = Field.create({
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
				garbageDisplay: GarbageTray.create(prefsSettings),
				accumulatedDisplay: GarbageTray.create(prefsSettings)
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
			preview: new VerticalPreview(leftQueue),
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
			inputDevice: leftInputDevice,
			state: leftState,
			playActionBuffer: leftActionBuffer
		});
	}

	inline function buildRightBoard() {
		rightBoard = new SingleStateBoard({
			pauseMediator: pauseMediator,
			inputDevice: rightInputDevice,
			state: rightState,
			playActionBuffer: rightActionBuffer
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
		leftBorderColorMediator.boardState = leftState;
		leftTargetMediator.garbageManager = rightGarbageManager;

		rightBorderColorMediator.boardState = rightState;
		rightTargetMediator.garbageManager = leftGarbageManager;
	}
}
