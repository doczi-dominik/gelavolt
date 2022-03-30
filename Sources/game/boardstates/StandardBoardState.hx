package game.boardstates;

import game.mediators.TransformationMediator;
import game.rules.Rule;
import utils.Utils;
import game.simulation.SimulationStepType;
import save_data.PrefsSettings;
import game.fields.Field;
import game.gelos.GeloPoint;
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
import game.score.ScoreManager;
import game.all_clear.AllClearManager;
import game.actionbuffers.ActionSnapshot;
import game.previews.IPreview;
import game.Queue;
import game.gelogroups.GeloGroup;
import kha.math.Random;
import game.garbage.IGarbageManager;
import kha.graphics2.Graphics;
import kha.graphics4.Graphics as Graphics4;

private enum InnerState {
	SPAWNING;
	CONTROLLING;
	SIM_STEP(type: SimulationStepType);
	POP_PAUSE;
}

class StandardBoardState implements IBoardState {
	final rule: Rule;
	final prefsSettings: PrefsSettings;

	final transformMediator: TransformationMediator;
	final rng: Random;
	final geometries: BoardGeometries;
	final particleManager: ParticleManager;

	final geloGroup: GeloGroup;
	final queue: Queue;
	final preview: IPreview;
	final allClearManager: AllClearManager;
	final scoreManager: ScoreManager;
	final actionBuffer: IActionBuffer;
	final chainCounter: ChainCounter;
	final field: Field;
	final chainSim: ChainSimulator;
	final garbageManager: IGarbageManager;

	var popPauseMaxT: Int;

	var currentActions: ActionSnapshot;

	var popPauseT: Int;

	var firstDropFrame: Bool;

	var borderColor: Color;
	var beginBorderColor: Color;
	var targetBorderColor: Color;
	var borderColorT: Int;

	var currentBeginStep: Null<BeginSimStep>;
	var currentDropStep: Null<DropSimStep>;
	var currentPopStep: Null<PopSimStep>;
	var currentEndStep: Null<EndSimStep>;

	var canDropGarbage: Bool;

	var state: InnerState;

	public function new(opts: StandardBoardStateOptions) {
		rule = opts.rule;
		prefsSettings = opts.prefsSettings;

		transformMediator = opts.transformMediator;
		rng = opts.rng;
		geometries = opts.geometries;
		particleManager = opts.particleManager;

		geloGroup = opts.geloGroup;

		queue = opts.queue;
		preview = opts.preview;
		allClearManager = opts.allClearManager;
		scoreManager = opts.scoreManager;
		actionBuffer = opts.actionBuffer;
		chainCounter = opts.chainCounter;
		field = opts.field;
		chainSim = opts.chainSim;
		garbageManager = opts.garbageManager;

		popPauseMaxT = 30;

		borderColor = White;
		beginBorderColor = White;
		targetBorderColor = White;
		borderColorT = 15;

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
		beginChainSimulation();
	}

	function afterDrop() {}

	function afterPop() {}

	function beforeEnd() {}

	function afterEnd() {}

	function controlGroup() {
		if (currentActions.rotateLeft) {
			geloGroup.rotateLeft();
		} else if (currentActions.rotateRight) {
			geloGroup.rotateRight();
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
			if (rule.animations == TSU) {
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
			for (c in currentPopStep.popInfo.clears) {
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
		for (c in clears) {
			if (field.getAtPoint(c).state == POPPING)
				return;
		}

		for (c in clears) {
			field.clear(c.x, c.y);
		}

		initPopPauseState();

		afterPop();
	}

	function initPopPauseState() {
		popPauseT = 0;

		final absPos = geometries.absolutePosition;
		final popInfo = currentPopStep.popInfo;
		final beginnerScreenCoords: Array<GeloPoint> = [];

		for (b in popInfo.beginners) {
			final screenCoords = field.cellToScreen(b.x, b.y);

			beginnerScreenCoords.push({
				x: Std.int(screenCoords.x),
				y: Std.int(screenCoords.y),
				color: b.color
			});
		}

		final firstPop = beginnerScreenCoords[0];

		chainCounter.startAnimation(currentPopStep.chain, {x: firstPop.x, y: firstPop.y}, currentPopStep.linkInfo.isPowerful);

		for (c in popInfo.clears) {
			if (c.color.isGarbage())
				continue;

			final screenCoords = field.cellToScreen(c.x, c.y);
			final absCoords = absPos.add(screenCoords);

			for (i in 0...8) {
				particleManager.add(FRONT, GeloPopParticle.create({
					x: absCoords.x + Gelo.HALFSIZE * rng.GetFloatIn(-1, 1),
					y: absCoords.y + Gelo.HALFSIZE * rng.GetFloatIn(-1, 1),
					dx: ((i % 2 == 0) ? -8 : 8) * rng.GetFloatIn(0.5, 1.5),
					dy: -10 * rng.GetFloatIn(0.5, 1.5),
					dyIncrement: 0.75 * rng.GetFloatIn(0.5, 1.5),
					maxT: Std.int((30 + i * 6) * rng.GetFloatIn(0.5, 1.5)),
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

			if (rule.randomizeGarbage) {
				columnIndex = rng.GetUpTo(columnPositions.length - 1);
			} else {
				columnIndex = 0;
			}

			final row = field.garbageRows - 1 - Std.int(i / columns);
			final column = columnPositions[columnIndex];
			final accel = accels[fallInBulk ? column : accelCenterIndex];

			field.newGarbage(column, row, rule.garbageColor).startGarbageFalling(accel);

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

	public function update() {
		currentActions = actionBuffer.latestAction;
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
		final absPreviewPos = geometries.absolutePosition.add(previewPos);

		transformMediator.setTransformedScissor(g, absPreviewPos.x - Gelo.HALFSIZE, absPreviewPos.y - Gelo.HALFSIZE, Gelo.SIZE, Gelo.SIZE * 4.5);

		preview.render(g, previewPos.x, previewPos.y);

		g.disableScissor();

		final garbageTrayPos = geometries.garbageTray;

		garbageManager.render(g, garbageTrayPos.x, garbageTrayPos.y, alpha);
	};
}
