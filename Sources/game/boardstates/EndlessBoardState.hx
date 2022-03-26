package game.boardstates;

import game.rules.MarginTimeManager;
import save_data.IClearOnXModeContainer;
import game.randomizers.Randomizer;

class EndlessBoardState extends StandardBoardState {
	final clearOnXModeContainer: IClearOnXModeContainer;
	final randomizer: Randomizer;
	final marginManager: MarginTimeManager;

	public function new(opts: EndlessBoardStateOptions) {
		super(opts);

		clearOnXModeContainer = opts.clearOnXModeContainer;
		randomizer = opts.randomizer;
		marginManager = opts.marginManager;
	}

	// public for EndlessBoard
	override public function onLose() {
		eraseField();
		garbageManager.clear();
		marginManager.reset();
		allClearManager.stopAnimation();

		switch (clearOnXModeContainer.clearOnXMode) {
			case CLEAR:
			case RESTART:
				queue.setIndex(0);
			case NEW:
				regenerateQueue();
		}

		initSimStepState();
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
