package game.boardstates;

import game.randomizers.Randomizer;
import save_data.TrainingSave;

class EndlessBoardState extends StandardBoardState {
	final trainingSave: TrainingSave;
	final randomizer: Randomizer;

	public function new(opts: EndlessBoardStateOptions) {
		super(opts);

		trainingSave = opts.trainingSave;
		randomizer = opts.randomizer;
	}

	override function onLose() {
		eraseField();
		garbageManager.clear();

		switch (trainingSave.clearOnXMode) {
			case CLEAR:
			case RESTART:
				queue.setIndex(0);
				initSimStepState();
			case NEW:
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
