package game.mediators;

class FrameCounter {
	public var value(default, null): Int;

	public function new() {
		value = 0;
	}

	public function update() {
		++value;
	}
}
