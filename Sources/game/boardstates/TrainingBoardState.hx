package game.boardstates;

import game.randomizers.Randomizer;
import save_data.TrainingSave;
import game.fields.Field;

class TrainingBoardState extends StandardBoardState {
	final infoState: TrainingInfoBoardState;
	final trainingSave: TrainingSave;
	final randomizer: Randomizer;

	public function new(opts: TrainingBoardStateOptions) {
		super(opts);

		infoState = opts.infoState;
		trainingSave = opts.trainingSave;
		randomizer = opts.randomizer;
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
		if (!trainingSave.autoAttack)
			garbageManager.clear();
	}

	override function afterEnd() {
		infoState.saveSplitCategory();

		if (!field.isEmpty(field.centerColumnIndex, field.outerRows)) {
			eraseField();
			garbageManager.clear();
			infoState.resetCurrentSplitStatistics();

			switch (trainingSave.clearOnXMode) {
				case CLEAR:
				case RESTART:
					queue.setIndex(0);
					initSimStepState();
				case NEW:
					regenerateQueue();
					initSimStepState();
			}
		}
	}

	function eraseField() {
		infoState.stopSplitTimer();

		field.forEach((_, x, y) -> {
			field.clear(x, y);
		});

		chainSim.modify(field.copy());
		chainSim.viewLast();
	}

	public function getField() {
		return field;
	}

	public function clearField() {
		eraseField();

		queue.previous();
		initSpawningState();
	}

	public function regenerateQueue() {
		randomizer.generatePools(TSU);
		queue.load(randomizer.createQueueData(Dropsets.CLASSICAL));
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
