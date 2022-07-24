package game.mediators;

import game.copying.ICopyFrom;

class FrameCounter implements ICopyFrom {
	@copy public var value(default, null): Int;

	public function new() {
		value = 0;
	}

	public function update() {
		++value;
	}
}
