package game.rules;

import game.copying.ICopyFrom;

class MarginTimeManager implements ICopyFrom implements hxbit.Serializable {
	@copy var changeCounter: Int;

	@:s @copy public var marginTime(default, null): Int;

	@copy public var startMarginTime: Int;
	@copy public var startTargetPoints: Int;
	@copy public var isEnabled: Bool;
	@copy public var targetPoints: Int;

	public function new(startMarginTime: Int, startTargetPoints: Int) {
		this.startMarginTime = startMarginTime;
		this.startTargetPoints = startTargetPoints;
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
