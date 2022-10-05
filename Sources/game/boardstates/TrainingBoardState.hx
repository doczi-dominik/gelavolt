package game.boardstates;

import game.boardstates.EndlessBoardState.EndlessBoardStateOptions;
import game.auto_attack.AutoAttackManager;
import save_data.TrainingSettings;

@:structInit
@:build(game.Macros.buildOptionsClass(TrainingBoardState))
class TrainingBoardStateOptions extends EndlessBoardStateOptions {}

class TrainingBoardState extends EndlessBoardState {
	@inject final trainingSettings: TrainingSettings;
	@inject final infoState: TrainingInfoBoardState;
	@inject final autoAttackManager: AutoAttackManager;

	public function new(opts: TrainingBoardStateOptions) {
		super(opts);

		game.Macros.initFromOpts();
	}

	override function lockGroup() {
		super.lockGroup();

		infoState.loadChain();
		infoState.startSplitTimer();
		infoState.incrementGroupCounter();
		infoState.shouldUpdatePPST = false;
	}

	override function afterDrop() {
		infoState.stopSplitTimer();
	}

	override function afterPop() {
		if (currentPopStep == null) {
			return;
		}

		infoState.updateChain(currentPopStep);
	}

	override function beforeEnd() {
		if (autoAttackManager.isPaused)
			garbageManager.clear();
	}

	override function afterEnd() {
		infoState.saveSplitCategory();
		infoState.shouldUpdatePPST = true;
	}

	override function onLose() {
		super.onLose();

		infoState.resetCurrentSplitStatistics();
		autoAttackManager.reset();
	}

	// Makes regenerateQueue public
	override public function regenerateQueue() {
		randomizer.generatePools(TSU);

		final data = randomizer.createQueueData(Dropsets.CLASSICAL);

		for (i in 0...trainingSettings.keepGroupCount) {
			final d = queue.get(i);

			if (d != null) {
				data[i] = d;
			}
		}

		queue.load(data);
	}

	public function getField() {
		return field;
	}

	public function clearField() {
		eraseField();

		queue.previous();
		initSpawningState();
	}

	public function resume() {
		final vs = chainSim.getViewedStep();

		if (vs == null) {
			return;
		}

		field.copyFrom(vs.fieldSnapshot);

		geloGroup.isVisible = false;
		geloGroup.isShadowVisible = false;

		queue.setIndex(chainSim.findBeginStep().groupIndex);

		initSimStepState();
	}

	public function previousGroup() {
		if (chainSim.viewIndex < 3)
			return;

		chainSim.rewindToPreviousEndStep();

		resume();
	}

	public function nextGroup() {
		chainSim.jumpToBeginStep();
		copyFromSnapshot();

		geloGroup.isVisible = false;
		geloGroup.isShadowVisible = false;

		beginChainSimulation();
	}
}
