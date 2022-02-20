package game.rules;

class MarginTimeManager {
	final rule: Rule;

	var changeCounter: Int;

	public var marginTime(default, null): Int;

	public var startMarginTime: Int;
	public var startTargetPoints: Int;
	public var isEnabled: Bool;
	public var targetPoints: Int;

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
