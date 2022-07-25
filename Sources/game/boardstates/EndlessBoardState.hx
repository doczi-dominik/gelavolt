package game.boardstates;

import game.boardstates.StandardBoardState.StandardBoardStateOptions;
import game.rules.MarginTimeManager;
import save_data.IClearOnXModeContainer;
import game.randomizers.Randomizer;

@:structInit
@:build(game.Macros.buildOptionsClass(EndlessBoardState))
class EndlessBoardStateOptions extends StandardBoardStateOptions {}

class EndlessBoardState extends StandardBoardState {
	@inject final clearOnXModeContainer: IClearOnXModeContainer;
	@inject final randomizer: Randomizer;
	@inject final marginManager: MarginTimeManager;

	public function new(opts: EndlessBoardStateOptions) {
		super(opts);

		game.Macros.initFromOpts();
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
