package game.boardstates;

import save_data.TrainingSettings;

class TrainingBoardState extends EndlessBoardState {
	final trainingSettings: TrainingSettings;
	final infoState: TrainingInfoBoardState;

	public function new(opts: TrainingBoardStateOptions) {
		super(opts);

		trainingSettings = opts.trainingSettings;
		infoState = opts.infoState;
	}

	override function lockGroup() {
		super.lockGroup();

		infoState.loadChain();
		infoState.startSplitTimer();
	}

	override function afterDrop() {
		infoState.stopSplitTimer();
	}

	override function afterPop() {
		infoState.updateChain(currentPopStep);
	}

	override function beforeEnd() {
		if (!trainingSettings.autoAttack)
			garbageManager.clear();
	}

	override function afterEnd() {
		infoState.saveSplitCategory();
	}

	override function onLose() {
		super.onLose();

		infoState.resetCurrentSplitStatistics();
	}

	// Makes regenerateQueue public
	override public function regenerateQueue() {
		super.regenerateQueue();
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
		// Must call twice since initSpawningState() calls next()
		queue.previous();
		queue.previous();

		chainSim.rewindToPreviousEndStep();
		copyFromSnapshot();

		geloGroup.isVisible = false;

		initSimStepState();
	}

	public function nextGroup() {
		geloGroup.isVisible = false;

		lockGroup();
	}
}
