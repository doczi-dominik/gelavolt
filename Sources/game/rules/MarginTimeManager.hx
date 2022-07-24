package game.rules;

import game.copying.ICopyFrom;

class MarginTimeManager implements ICopyFrom {
	final rule: Rule;

	@copy var changeCounter: Int;

	@copy public var marginTime(default, null): Int;

	@copy public var startMarginTime: Int;
	@copy public var startTargetPoints: Int;
	@copy public var isEnabled: Bool;
	@copy public var targetPoints: Int;

	public function new(rule: Rule) {
		this.rule = rule;

		startMarginTime = rule.marginTime;
		startTargetPoints = rule.startTargetPoints;
		reset();

		isEnabled = true;
		targetPoints = startTargetPoints;
	}

	public function reset() {
		marginTime = -startMarginTime * 60;
		changeCounter = 0;

		targetPoints = startTargetPoints;
	}

	public function update() {
		if (!isEnabled || changeCounter > 12 || targetPoints <= 1)
			return;

		if (marginTime == 0) {
			targetPoints = Std.int(targetPoints * 0.75);
		} else if (marginTime > 0 && marginTime % 960 == 0) {
			targetPoints = Std.int(targetPoints / 2);
			changeCounter++;
		}

		++marginTime;
	}
}
