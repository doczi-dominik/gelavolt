package game.simulation;

import utils.ValueBox;
import game.garbage.trays.IGarbageTray;
import game.copying.ConstantCopyableArray;
import game.copying.CopyableArray;
import game.copying.ICopyFrom;
import game.gelogroups.GeloGroupData;
import game.fields.Field;
import game.fields.FieldPopInfo;
import utils.Utils.intClamp;

@:structInit
private class SimOptions {
	public final field: Field;
	public final sendAllClearBonus: Bool;
	public final dropBonus: Float;
	public final groupIndex: Null<Int>;
	public final groupData: Null<GeloGroupData>;
}

@:structInit
@:build(game.Macros.buildOptionsClass(ChainSimulator))
class ChainSimulatorOptions {}

class ChainSimulator implements ICopyFrom {
	@inject final popCount: ValueBox<Int>;
	@inject final vanishHiddenRows: ValueBox<Bool>;
	@inject final linkBuilder: ILinkInfoBuilder;
	@inject final garbageDisplay: IGarbageTray;
	@inject final accumulatedDisplay: IGarbageTray;

	public final steps: CopyableArray<SimulationStep>;

	@copy public var latestChainCounter(default, null): Int;
	@copy public var latestGarbageCounter(default, null): Int;
	@copy public var viewIndex(default, null): Int;
	@copy public var stepIndex: Int;

	public function new(opts: ChainSimulatorOptions) {
		game.Macros.initFromOpts();

		steps = new CopyableArray([]);

		latestGarbageCounter = 0;
		viewIndex = -1;
		stepIndex = 0;
	}

	inline function pushStep(step: SimulationStep) {
		steps.data[stepIndex++] = step;
	}

	function pop(field: Field) {
		final popInfo = new FieldPopInfo();

		field.checkConnections((connected) -> {
			if (connected.length >= popCount.v) {
				popInfo.hasPops = true;

				final firstInGroup = connected[0];

				popInfo.beginners.data.push({
					color: firstInGroup.color,
					x: firstInGroup.x,
					y: firstInGroup.y
				});

				for (c in connected) {
					final gelo = field.getAtPoint(c);

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

	function sim(opts: SimOptions) {
		final field = opts.field;
		final sendsAllClearBonus = opts.sendAllClearBonus;

		final links: Array<LinkInfo> = [];

		var lastRemainder = 0.0;
		var currentACBonus = sendsAllClearBonus;
		var currentDropBonus = opts.dropBonus;

		pushStep(new BeginSimStep({
			groupData: opts.groupData,
			chain: latestChainCounter,
			fieldSnapshot: field.copy(),
			sendsAllClearBonus: sendsAllClearBonus,
			dropBonus: opts.dropBonus,
			groupIndex: opts.groupIndex
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
				clearsByColor: popInfo.clearsByColor.data,
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

			final gDisplay: IGarbageTray = garbageDisplay.copy();
			final accumDisplay: IGarbageTray = accumulatedDisplay.copy();

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

		if (vanishHiddenRows.v) {
			field.customForEach(field.garbageRows, field.outerRows, (_, x, y) -> {
				field.clear(x, y);
			});
		}

		field.setSpriteVariations();

		// Check for All Clear
		final bottomRow = field.totalRows - 1;
		var allClear = true;

		field.customForEach(bottomRow, bottomRow - 1, (_, _, _) -> {
			allClear = false;
		});

		pushStep(new EndSimStep({
			chain: latestChainCounter,
			fieldSnapshot: field.copy(),
			links: new ConstantCopyableArray(links),
			endsInAllClear: allClear
		}));
	}

	function view(delta: Int) {
		viewIndex = intClamp(0, viewIndex + delta, steps.data.length - 1);
	}

	public function simulate(opts: SimOptions) {
		latestChainCounter = 0;
		latestGarbageCounter = 0;
		viewIndex = stepIndex;
		sim(opts);
	}

	public function clear() {
		steps.data.resize(0);
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
					stepIndex = viewIndex + 1;
					return;
				}

				passedOne = true;
			}

			viewPrevious();
		}
	}

	public function jumpToBeginStep() {
		var i = viewIndex;

		while (++i < steps.data.length) {
			if (steps.data[i].type == BEGIN) {
				viewIndex = i;
				editViewed();

				return;
			}
		}
	}

	public function findBeginStep() {
		var i = viewIndex;

		while (true) {
			final step = steps.data[i];

			if (step.type == BEGIN)
				return cast(step, BeginSimStep);

			i--;
		}
	}

	public function modify(field: Field) {
		var sendsAllClearBonus: Bool;
		var dropBonus: Float;
		var groupIndex: Null<Int>;

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
			groupIndex = null;
		}

		sim({
			groupData: null,
			groupIndex: groupIndex,
			field: field,
			sendAllClearBonus: sendsAllClearBonus,
			dropBonus: dropBonus,
		});
	}

	inline public function getViewedStep() {
		return steps.data[viewIndex];
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
		viewIndex = steps.data.length - 1;
	}

	public function reset() {
		steps.data.resize(0);
	}
}
