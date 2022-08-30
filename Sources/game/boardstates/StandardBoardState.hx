package game.boardstates;

import hxbit.Serializer;
import utils.ValueBox;
import game.rules.AnimationsType;
import utils.Utils;
import game.simulation.SimulationStepType;
import save_data.PrefsSettings;
import game.fields.Field;
import game.gelos.ScreenGeloPoint;
import game.gelos.Gelo;
import kha.Color;
import game.particles.GeloPopParticle;
import game.particles.ParticleManager;
import game.ChainCounter;
import game.simulation.EndSimStep;
import game.simulation.PopSimStep;
import game.simulation.DropSimStep;
import game.simulation.BeginSimStep;
import game.simulation.ChainSimulator;
import game.geometries.BoardGeometries;
import kha.Assets;
import game.actionbuffers.IActionBuffer;
import game.ScoreManager;
import game.AllClearManager;
import game.actionbuffers.ActionSnapshot;
import game.previews.IPreview;
import game.Queue;
import game.gelogroups.GeloGroup;
import game.copying.CopyableRNG;
import game.garbage.IGarbageManager;
import kha.graphics2.Graphics;
import kha.graphics4.Graphics as Graphics4;

private enum InnerState {
	SPAWNING;
	CONTROLLING;
	SIM_STEP(type: SimulationStepType);
	POP_PAUSE;
}

@:structInit
@:build(game.Macros.buildOptionsClass(StandardBoardState))
class StandardBoardStateOptions {}

class StandardBoardState implements IBoardState {
	@inject final animations: ValueBox<AnimationsType>;
	@inject final randomizeGarbage: ValueBox<Bool>;
	@inject final prefsSettings: PrefsSettings;

	@inject final rng: CopyableRNG;
	@inject final geometries: BoardGeometries;
	@inject final particleManager: ParticleManager;

	@inject final geloGroup: GeloGroup;
	@inject final queue: Queue;
	@inject final preview: IPreview;
	@inject final allClearManager: AllClearManager;
	@inject final scoreManager: ScoreManager;
	@inject final actionBuffer: IActionBuffer;
	@inject final chainCounter: ChainCounter;
	@inject final field: Field;
	@inject final chainSim: ChainSimulator;
	@inject final garbageManager: IGarbageManager;

	@copy var popPauseMaxT: Int;

	@copy var currentActions: ActionSnapshot;

	@copy var popPauseT: Int;

	@copy var firstDropFrame: Bool;

	@copy var canRotateLeft: Bool;
	@copy var canRotateRight: Bool;

	@copy var borderColor: Color;
	@copy var beginBorderColor: Color;
	@copy var targetBorderColor: Color;
	@copy var borderColorT: Int;

	@copy var currentBeginStep: Null<BeginSimStep>;
	@copy var currentDropStep: Null<DropSimStep>;
	@copy var currentPopStep: Null<PopSimStep>;
	@copy var currentEndStep: Null<EndSimStep>;

	@copy var canDropGarbage: Bool;

	@copy var state: InnerState;

	public function new(opts: StandardBoardStateOptions) {
		game.Macros.initFromOpts();

		popPauseMaxT = 30;

		borderColor = White;
		beginBorderColor = White;
		targetBorderColor = White;
		borderColorT = 15;

		canRotateLeft = true;
		canRotateRight = true;

		canDropGarbage = true;

		beginChainSimulation();
	}

	inline function copyFromSnapshot() {
		field.copyFrom(chainSim.getViewedStep().fieldSnapshot);
	}

	function nextStep() {
		chainSim.viewNext();
		initSimStepState();
	}

	function beginChainSimulation() {
		chainSim.simulate({
			groupData: queue.getCurrent(),
			field: field.copy(),
			sendAllClearBonus: allClearManager.sendAllClearBonus,
			dropBonus: scoreManager.dropBonus,
			groupIndex: queue.currentIndex
		});

		copyFromSnapshot();

		initSimStepState();
	}

	function lockGroup() {
		canDropGarbage = true;
		actionBuffer.isActive = false;
		beginChainSimulation();
	}

	function afterDrop() {}

	function afterPop() {}

	function beforeEnd() {}

	function afterEnd() {}

	function controlGroup() {
		if (currentActions.rotateLeft) {
			if (canRotateLeft) {
				geloGroup.rotateLeft();
				canRotateLeft = false;
			}
		} else {
			canRotateLeft = true;
		}

		if (currentActions.rotateRight) {
			if (canRotateRight) {
				geloGroup.rotateRight();
				canRotateRight = false;
			}
		} else {
			canRotateRight = true;
		}

		if (currentActions.shiftLeft) {
			geloGroup.chargeDASLeft();
			geloGroup.shiftLeft();
		} else if (currentActions.shiftRight) {
			geloGroup.chargeDASRight();
			geloGroup.shiftRight();
		} else {
			geloGroup.stopDAS();
		}
	}

	function initSpawningState() {
		final screenCoords = field.cellToScreen(field.centerColumnIndex, field.outerRows - 1);

		geloGroup.load(screenCoords.x, screenCoords.y + Gelo.HALFSIZE, queue.getCurrent());
		queue.next();

		preview.startAnimation(queue.currentIndex);

		actionBuffer.isActive = true;

		state = SPAWNING;
	}

	function updateSpawningState() {
		controlGroup();

		if (preview.isAnimationFinished) {
			geloGroup.isVisible = true;

			initControllingState();
		}
	}

	function initControllingState() {
		state = CONTROLLING;
	}

	function updateControllingState() {
		controlGroup();

		if (currentActions.hardDrop) {
			geloGroup.hardDrop();
			lockGroup();

			return;
		}

		if (geloGroup.drop(currentActions.softDrop)) {
			lockGroup();
		}
	}

	function initSimStepState() {
		final step = chainSim.getViewedStep();

		switch (step.type) {
			case BEGIN:
				currentBeginStep = cast(step, BeginSimStep);
				initBeginStepHandling();
			case DROP:
				currentDropStep = cast(step, DropSimStep);
				initDropStepHandling();
			case POP:
				currentPopStep = cast(step, PopSimStep);
				initPopStepHandling();
			case END:
				currentEndStep = cast(step, EndSimStep);
				initEndStepHandling();
		}
	}

	function initBeginStepHandling() {
		nextStep();
	}

	function handleBeginStep() {}

	function initDropStepHandling() {
		field.forEach((gelo, _, _) -> {
			if (gelo.state == IDLE)
				gelo.startDropping();
		});

		firstDropFrame = true;

		state = SIM_STEP(DROP);
	}

	function handleDropStep() {
		if (field.updateFall(field.totalRows - 1, 0)) {
			if (animations == TSU) {
				field.setSpriteVariations();
			}

			nextStep();
			afterDrop();
		}

		// Avoids the graphical issue of a non-falling Gelo still connecting
		// to one that is currently falling. Since every Gelo's state is set
		// to DROPPING in initDropStepHandling(), setSpriteVariation() would
		// have no effect, so updateFall() has to be called first to reset
		// the states of non-falling Gelos to IDLE.
		if (firstDropFrame) {
			field.setSpriteVariations();
			firstDropFrame = false;
		}
	}

	function initPopStepHandling() {
		// Progress to POP_PAUSE state if Gelos have already popped. This can
		// happen easily when continuing from a PopSimStep because field
		// snapshots show the field state AFTER the Gelos have popped.
		try {
			for (c in currentPopStep.popInfo.clears.data) {
				field.getAtPoint(c).startPopping(TSU);
			}
		} catch (_) {
			initPopPauseState();

			return;
		}

		state = SIM_STEP(POP);
	}

	function handlePopStep() {
		final clears = currentPopStep.popInfo.clears;

		// Wait for Gelos to finish popping animation
		for (c in clears.data) {
			if (field.getAtPoint(c).state == POPPING)
				return;
		}

		for (c in clears.data) {
			field.clear(c.x, c.y);
		}

		initPopPauseState();

		afterPop();
	}

	function initPopPauseState() {
		popPauseT = 0;

		final absPos = geometries.absolutePosition;
		final popInfo = currentPopStep.popInfo;
		final beginnerScreenCoords = new Array<ScreenGeloPoint>();

		for (b in popInfo.beginners.data) {
			final screenCoords = field.cellToScreen(b.x, b.y);

			beginnerScreenCoords.push({
				x: screenCoords.x,
				y: screenCoords.y,
				color: b.color
			});
		}

		final firstPop = beginnerScreenCoords[0];

		chainCounter.startAnimation(currentPopStep.chain, {x: firstPop.x, y: firstPop.y}, currentPopStep.linkInfo.isPowerful);

		for (c in popInfo.clears.data) {
			if (c.color.isGarbage())
				continue;

			final screenCoords = field.cellToScreen(c.x, c.y);
			final absCoords = absPos.add(screenCoords);

			for (i in 0...8) {
				particleManager.add(FRONT, GeloPopParticle.create({
					x: absCoords.x + Gelo.HALFSIZE * rng.data.GetFloatIn(-1, 1),
					y: absCoords.y + Gelo.HALFSIZE * rng.data.GetFloatIn(-1, 1),
					dx: ((i % 2 == 0) ? -8 : 8) * rng.data.GetFloatIn(0.5, 1.5),
					dy: -10 * rng.data.GetFloatIn(0.5, 1.5),
					dyIncrement: 0.75 * rng.data.GetFloatIn(0.5, 1.5),
					maxT: Std.int((30 + i * 6) * rng.data.GetFloatIn(0.5, 1.5)),
					color: prefsSettings.primaryColors[c.color]
				}));
			}
		}

		allClearManager.stopAnimation();

		final linkInfo = currentPopStep.linkInfo;

		scoreManager.addScoreFromLink(linkInfo);

		garbageManager.sendGarbage(linkInfo.garbage, beginnerScreenCoords);

		scoreManager.resetDropBonus();

		state = POP_PAUSE;
	}

	function updatePopPauseState() {
		if (popPauseT < popPauseMaxT) {
			popPauseT++;
			return;
		}

		nextStep();
	}

	function initEndStepHandling() {
		beforeEnd();

		garbageManager.confirmGarbage(currentEndStep.totalGarbage);

		if (currentEndStep.endsInAllClear) {
			allClearManager.startAnimation();
		}

		if (currentEndStep.isLastLinkPowerful) {
			final chain = currentEndStep.chain;

			if (chain == 1) {
				scoreManager.displayActionText("THORN", Magenta);
			}

			if (chain == 2) {
				scoreManager.displayActionText("HELLFIRE", Color.fromValue(0xFFFF1744));
			}

			if (chain == 3) {
				scoreManager.displayActionText("KILLER ICE", Cyan);
			}
		}

		copyFromSnapshot();

		if (!field.isEmpty(field.centerColumnIndex, field.outerRows)) {
			onLose();
		} else {
			state = SIM_STEP(END);
		}
	}

	function handleEndStep() {
		final amount = garbageManager.droppableGarbage;

		if (amount == 0 || !canDropGarbage) {
			initSpawningState();
			afterEnd();
			return;
		}

		final columns = field.columns;
		final accels = field.garbageAccelerations;
		final accelCenterIndex = Utils.intClamp(0, accels.length / 2, accels.length - 1);
		final fallInBulk = amount >= columns;

		var columnPositions: Array<Int> = [];

		for (i in 0...amount) {
			if (i % columns == 0) {
				columnPositions = field.garbageColumns.copy();
			}

			var columnIndex: Int;

			if (randomizeGarbage) {
				columnIndex = rng.data.GetUpTo(columnPositions.length - 1);
			} else {
				columnIndex = 0;
			}

			final row = field.garbageRows - 1 - Std.int(i / columns);
			final column = columnPositions[columnIndex];
			final accel = accels[fallInBulk ? column : accelCenterIndex];

			field.newGarbage(column, row, GARBAGE).startGarbageFalling(accel);

			columnPositions.remove(column);
		}

		garbageManager.dropGarbage(amount);

		canDropGarbage = false;
		beginChainSimulation();
		afterEnd();
	}

	function updateColorChange() {
		if (borderColorT == 15)
			return;

		borderColor = Utils.rgbLerp(beginBorderColor, targetBorderColor, borderColorT / 15);
		borderColorT++;
	}

	function onLose() {}

	public function changeBorderColor(target: Color) {
		beginBorderColor = borderColor;
		targetBorderColor = target;
		borderColorT = 0;
	}

	public function addDesyncInfo(ctx: Serializer) {
		field.addDesyncInfo(ctx);
		garbageManager.addDesyncInfo(ctx);
	}

	public function update() {
		currentActions = actionBuffer.update();
		geloGroup.update();
		field.update();
		preview.update();

		switch (state) {
			case SPAWNING:
				updateSpawningState();
			case CONTROLLING:
				updateControllingState();
			case SIM_STEP(type):
				switch (type) {
					case BEGIN: handleBeginStep();
					case DROP: handleDropStep();
					case POP: handlePopStep();
					case END: handleEndStep();
				}
			case POP_PAUSE:
				updatePopPauseState();
		}

		allClearManager.update();
		scoreManager.update();
		chainCounter.update();
		garbageManager.update();

		updateColorChange();
	}

	public function renderScissored(g: Graphics, g4: Graphics4, alpha: Float) {
		g.color = prefsSettings.boardBackground;
		g.fillRect(0, 0, BoardGeometries.WIDTH, BoardGeometries.HEIGHT);
		g.color = White;

		allClearManager.renderBackground(g);
		field.render(g, g4, alpha);
		allClearManager.renderForeground(g);

		geloGroup.render(g, g4, alpha);
	};

	public function renderFloating(g: Graphics, g4: Graphics4, alpha: Float) {
		g.color = borderColor;
		g.drawImage(Assets.images.Border, -12, -12);
		g.color = White;

		scoreManager.render(g, geometries.scoreDisplayY, alpha);

		chainCounter.render(g, alpha);

		final previewPos = geometries.preview;

		ScaleManager.transformedScissor(g, previewPos.x - Gelo.HALFSIZE, previewPos.y - Gelo.HALFSIZE, Gelo.SIZE, Gelo.SIZE * 4.5);

		preview.render(g, previewPos.x, previewPos.y);

		g.disableScissor();

		final garbageTrayPos = geometries.garbageTray;

		garbageManager.render(g, garbageTrayPos.x, garbageTrayPos.y, alpha);
	};
}
