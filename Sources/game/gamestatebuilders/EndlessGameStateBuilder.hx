package game.gamestatebuilders;

import game.rules.EndlessRule;
import game.rules.AnimationsType;
import game.rules.PhysicsType;
import game.rules.PowerTableType;
import game.rules.ColorBonusTableType;
import game.rules.GroupBonusTableType;
import utils.ValueBox;
import game.actionbuffers.ReplayData;
import game.mediators.ControlHintContainer;
import game.boards.EndlessBoard;
import input.IInputDevice;
import game.ui.PauseMenu;
import game.ui.ReplayPauseMenu;
import game.mediators.FrameCounter;
import save_data.Profile;
import game.actionbuffers.ReplayActionBuffer;
import game.actionbuffers.LocalActionBuffer;
import game.actionbuffers.IActionBuffer;
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
import game.AllClearManager;
import game.gelogroups.GeloGroup;
import game.fields.Field;
import game.simulation.ChainSimulator;
import game.ScoreManager;
import game.mediators.BorderColorMediator;
import game.mediators.PauseMediator;
import game.rules.MarginTimeManager;
import game.particles.ParticleManager;
import game.randomizers.Randomizer;
import game.copying.CopyableRNG;
import game.states.GameState;
import game.mediators.SaveGameStateMediator;

@:structInit
@:build(game.Macros.buildOptionsClass(EndlessGameStateBuilder))
class EndlessGameStateBuilderOptions {}

@:build(game.Macros.addGameStateBuildMethod())
class EndlessGameStateBuilder implements IGameStateBuilder {
	@inject final rule: EndlessRule;
	@inject final inputDevice: IInputDevice;
	@inject final replayData: Null<ReplayData>;

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

	var borderColorMediator: BorderColorMediator;

	@copy var scoreManager: ScoreManager;
	@copy var chainSim: ChainSimulator;
	@copy var chainCounter: ChainCounter;
	@copy var field: Field;
	@copy var queue: Queue;
	var actionBuffer: IActionBuffer;
	@copy var geloGroup: GeloGroup;
	@copy var allClearManager: AllClearManager;

	@copy var boardState: EndlessBoardState;

	@copy var board: SingleStateBoard;

	public var pauseMediator(null, default): PauseMediator;
	@copy public var controlHintContainer(null, default): ControlHintContainer;
	public var saveGameStateMediator(null, default): SaveGameStateMediator;

	public var gameState(default, null): GameState;
	public var pauseMenu(default, null): PauseMenu;

	public function new(opts: EndlessGameStateBuilderOptions) {
		game.Macros.initFromOpts();
	}

	inline function initValueBoxes() {
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

	inline function initControlHintContainer() {
		controlHintContainer.isVisible = Profile.primary.endlessSettings.showControlHints;
		controlHintContainer.value.data.push({actions: [QUICK_RESTART], description: "Quick Restart"});
	}

	inline function buildBorderColorMediator() {
		borderColorMediator = new BorderColorMediator();
	}

	inline function buildScoreManager() {
		scoreManager = new ScoreManager({
			softDropBonus: softDropBonus,
			orientation: LEFT
		});
	}

	inline function buildChainSim() {
		chainSim = new ChainSimulator({
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
			garbageDisplay: GarbageTray.create(Profile.primary.prefs),
			accumulatedDisplay: GarbageTray.create(Profile.primary.prefs)
		});
	}

	inline function buildChainCounter() {
		chainCounter = new ChainCounter();
	}

	inline function buildField() {
		field = new Field({
			prefsSettings: Profile.primary.prefs,
			columns: 6,
			playAreaRows: 12,
			hiddenRows: 1,
			garbageRows: 5
		});
	}

	inline function buildQueue() {
		queue = new Queue(randomizer.createQueueData(Dropsets.CLASSICAL));
	}

	inline function buildActionBuffer() {
		if (replayData == null) {
			actionBuffer = new LocalActionBuffer({
				frameCounter: frameCounter,
				inputDevice: inputDevice,
				frameDelay: Profile.primary.input.localDelay
			});

			return;
		}

		actionBuffer = new ReplayActionBuffer({
			frameCounter: frameCounter,
			inputDevice: inputDevice,
			replayData: replayData,
			frameDelay: 0
		});
	}

	inline function buildGeloGroup() {
		final prefsSettings = Profile.primary.prefs;

		geloGroup = new GeloGroup({
			physics: physics,
			animations: animations,
			dropSpeed: dropSpeed,
			field: field,
			prefsSettings: prefsSettings,
			scoreManager: scoreManager,
			chainSim: new ChainSimulator({
				popCount: popCount,
				vanishHiddenRows: vanishHiddenRows,
				linkBuilder: NullLinkInfoBuilder.instance,
				garbageDisplay: GarbageTray.create(prefsSettings),
				accumulatedDisplay: GarbageTray.create(prefsSettings)
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
			animations: animations,
			randomizeGarbage: randomizeGarbage,
			prefsSettings: Profile.primary.prefs,
			rng: rng,
			geometries: BoardGeometries.CENTERED,
			particleManager: particleManager,
			geloGroup: geloGroup,
			field: field,
			garbageManager: NullGarbageManager.instance,
			queue: queue,
			preview: new VerticalPreview(queue),
			allClearManager: allClearManager,
			scoreManager: scoreManager,
			actionBuffer: actionBuffer,
			chainCounter: chainCounter,
			chainSim: chainSim,
			clearOnXModeContainer: Profile.primary.endlessSettings,
			randomizer: randomizer,
			marginManager: marginManager
		});
	}

	inline function buildBoard() {
		board = new EndlessBoard({
			pauseMediator: pauseMediator,
			inputDevice: inputDevice,
			state: boardState,
			endlessState: boardState
		});
	}

	inline function buildPauseMenu() {
		if (replayData == null) {
			pauseMenu = new EndlessPauseMenu({
				pauseMediator: pauseMediator,
				prefsSettings: Profile.primary.prefs,
				endlessSettings: Profile.primary.endlessSettings,
				controlHintContainer: controlHintContainer,
				actionBuffer: actionBuffer,
			});

			return;
		}

		pauseMenu = new ReplayPauseMenu({
			pauseMediator: pauseMediator,
			prefsSettings: Profile.primary.prefs,
			actionBuffer: cast(actionBuffer, ReplayActionBuffer),
		});
	}

	inline function buildGameState() {
		gameState = new GameState({
			particleManager: particleManager,
			marginManager: marginManager,
			boardManager: new SingleBoardManager({
				geometries: BoardGeometries.CENTERED,
				board: board
			}),
			frameCounter: frameCounter,
		});
	}

	inline function wireMediators() {
		borderColorMediator.changeColor = boardState.changeBorderColor;
	}
}
