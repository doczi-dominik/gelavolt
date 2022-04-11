package game.boardstates;

import auto_attack.AutoAttackManager;
import save_data.TrainingSettings;

class TrainingBoardState extends EndlessBoardState {
	final trainingSettings: TrainingSettings;
	final infoState: TrainingInfoBoardState;
	final autoAttackManager: AutoAttackManager;

	public function new(opts: TrainingBoardStateOptions) {
		super(opts);

		trainingSettings = opts.trainingSettings;
		infoState = opts.infoState;
		autoAttackManager = opts.autoAttackManager;
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
			data[i] = queue.get(i);
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
		field.copyFrom(chainSim.getViewedStep().fieldSnapshot);

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
