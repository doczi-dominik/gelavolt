package game.simulation;

import game.rules.Rule;
import game.garbage.trays.GarbageTray;
import game.fields.Field;
import game.fields.FieldPopInfo;
import utils.Utils.intClamp;

class ChainSimulator {
	final rule: Rule;
	final linkBuilder: ILinkInfoBuilder;
	final garbageDisplay: GarbageTray;
	final accumulatedDisplay: GarbageTray;

	var stepIndex: Int;

	public final steps: Array<SimulationStep> = [];

	public var latestChainCounter(default, null): Int;
	public var latestGarbageCounter(default, null): Int;
	public var viewIndex(default, null): Int;

	public function new(opts: ChainSimulatorOptions) {
		rule = opts.rule;
		linkBuilder = opts.linkBuilder;
		garbageDisplay = opts.garbageDisplay;
		accumulatedDisplay = opts.accumulatedDisplay;

		stepIndex = 0;
		latestGarbageCounter = 0;

		viewIndex = -1;
	}

	inline function pushStep(step: SimulationStep) {
		steps[stepIndex++] = step;
	}

	function pop(field: Field) {
		final popInfo = new FieldPopInfo();

		field.checkConnections((connected) -> {
			if (connected.length >= rule.popCount) {
				popInfo.hasPops = true;

				final firstInGroup = connected[0];

				popInfo.beginners.push({
					color: firstInGroup.gelo.color,
					x: firstInGroup.x,
					y: firstInGroup.y
				});

				for (c in connected) {
					final gelo = c.gelo;
					if (!gelo.damage())
						continue;

					final x = c.x;
					final y = c.y;

					popInfo.addClear(gelo.color, x, y);
					field.clear(x, y);

					field.checkAround(x, y, (aroundGelo, aroundX, aroundY, _) -> {
						final aroundColor = aroundGelo.color;

						if (!aroundColor.isGarbage())
							return;
						if (!aroundGelo.damage())
							return;

						popInfo.addClear(aroundColor, aroundX, aroundY);
						field.clear(aroundX, aroundY);
					});
				}
			}
		});

		return popInfo;
	}

	function sim(field: Field, sendsAllClearBonus: Bool, dropBonus: Float, groupIndex: Int) {
		final links: Array<LinkInfo> = [];

		var lastRemainder = 0.0;
		var currentACBonus = sendsAllClearBonus;
		var currentDropBonus = dropBonus;

		pushStep(new BeginSimStep({
			chain: latestChainCounter,
			fieldSnapshot: field.copy(),
			sendsAllClearBonus: sendsAllClearBonus,
			dropBonus: dropBonus,
			groupIndex: groupIndex
		}));

		while (true) {
			// DROP
			field.drop();

			field.setSpriteVariations();

			pushStep(new DropSimStep({
				chain: latestChainCounter,
				fieldSnapshot: field.copy()
			}));

			// POP
			final popInfo = pop(field);

			// Add step and LinkInfo if Gelos were popped
			if (!popInfo.hasPops)
				break;

			final linkInfo = linkBuilder.build({
				clearsByColor: popInfo.clearsByColor,
				chain: ++latestChainCounter,
				dropBonus: currentDropBonus,
				garbageRemainder: lastRemainder,
				sendsAllClearBonus: currentACBonus,
				totalGarbage: latestGarbageCounter
			});

			latestGarbageCounter = linkInfo.accumulatedGarbage;
			lastRemainder = linkInfo.garbageRemainder;
			currentACBonus = false;
			currentDropBonus = 0;

			links.push(linkInfo);

			final gDisplay = garbageDisplay.copy();
			final accumDisplay = accumulatedDisplay.copy();

			gDisplay.startAnimation(linkInfo.garbage);
			accumDisplay.startAnimation(linkInfo.accumulatedGarbage);

			pushStep(new PopSimStep({
				chain: latestChainCounter,
				fieldSnapshot: field.copy(),
				popInfo: popInfo,
				linkInfo: linkInfo,
				garbageDisplay: gDisplay,
				accumulatedDisplay: accumDisplay
			}));
		}

		field.forEach((gelo, _, _) -> {
			gelo.stopFalling();
		});

		if (rule.vanishHiddenRows) {
			field.customForEach(field.garbageRows, field.outerRows, (_, x, y) -> {
				field.clear(x, y);
			});
		}

		field.setSpriteVariations();

		pushStep(new EndSimStep({
			chain: latestChainCounter,
			fieldSnapshot: field.copy(),
			chainInfo: new ChainInfo(links)
		}));
	}

	function view(delta: Int) {
		viewIndex = intClamp(0, viewIndex + delta, steps.length - 1);
	}

	public function simulate(field: Field, sendsAllClearBonus: Bool, dropBonus: Float, groupIndex: Int) {
		latestChainCounter = 0;
		latestGarbageCounter = 0;
		viewIndex = stepIndex;
		sim(field, sendsAllClearBonus, dropBonus, groupIndex);
	}

	public function clear() {
		steps.resize(0);
		stepIndex = 0;
		viewIndex = -1;
	}

	public function rewindToPreviousEndStep() {
		var passedOne = false;

		while (true) {
			if (viewIndex == 0) {
				editViewed();
				return;
			}

			if (getViewedStep().type == END) {
				if (passedOne) {
					editViewed();
					return;
				}

				passedOne = true;
			}

			viewPrevious();
		}
	}

	public function findBeginStep() {
		var i = viewIndex;

		while (true) {
			final step = steps[i];

			if (step.type == BEGIN)
				return cast(step, BeginSimStep);

			i--;
		}
	}

	public function modify(field: Field) {
		var sendsAllClearBonus: Bool;
		var dropBonus: Float;
		var groupIndex: Int;

		editViewed();

		final currentStep = getViewedStep();

		latestChainCounter = currentStep.chain;

		if (currentStep.type == BEGIN) {
			final beginStep = cast(currentStep, BeginSimStep);
			sendsAllClearBonus = beginStep.sendsAllClearBonus;
			dropBonus = beginStep.dropBonus;
			groupIndex = beginStep.groupIndex;
		} else {
			sendsAllClearBonus = false;
			dropBonus = 0;
			groupIndex = -1;
		}

		sim(field, sendsAllClearBonus, dropBonus, groupIndex);
	}

	inline public function getViewedStep() {
		return steps[viewIndex];
	}

	public inline function viewNext() {
		view(1);
	}

	public inline function viewPrevious() {
		view(-1);
	}

	public function editViewed() {
		stepIndex = viewIndex;
	}

	public function nextStep() {
		stepIndex++;
	}

	public function viewLast() {
		viewIndex = steps.length - 1;
	}
}
