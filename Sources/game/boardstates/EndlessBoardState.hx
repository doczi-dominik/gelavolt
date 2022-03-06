package game.boardstates;

import game.randomizers.Randomizer;
import save_data.TrainingSettings;

class EndlessBoardState extends StandardBoardState {
	final trainingSettings: TrainingSettings;
	final randomizer: Randomizer;

	public function new(opts: EndlessBoardStateOptions) {
		super(opts);

		trainingSettings = opts.trainingSettings;
		randomizer = opts.randomizer;
	}

	override function onLose() {
		eraseField();
		garbageManager.clear();

		switch (trainingSettings.clearOnXMode) {
			case CLEAR:
			case RESTART:
				queue.setIndex(0);
				initSimStepState();
			case NEW:
				regenerateQueue();
				initSimStepState();
		}
	}

	function eraseField() {
		field.forEach((_, x, y) -> {
			field.clear(x, y);
		});

		chainSim.modify(field.copy());
		chainSim.viewLast();
	}

	function regenerateQueue() {
		randomizer.generatePools(TSU);
		queue.load(randomizer.createQueueData(Dropsets.CLASSICAL));
	}
}
