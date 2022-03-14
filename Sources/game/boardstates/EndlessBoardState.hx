package game.boardstates;

import save_data.IClearOnXModeContainer;
import game.randomizers.Randomizer;

class EndlessBoardState extends StandardBoardState {
	final clearOnXModeContainer: IClearOnXModeContainer;
	final randomizer: Randomizer;

	public function new(opts: EndlessBoardStateOptions) {
		super(opts);

		clearOnXModeContainer = opts.clearOnXModeContainer;
		randomizer = opts.randomizer;
	}

	override function onLose() {
		eraseField();
		garbageManager.clear();

		switch (clearOnXModeContainer.clearOnXMode) {
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
