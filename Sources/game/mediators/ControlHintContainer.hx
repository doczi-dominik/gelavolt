package game.mediators;

import ui.ControlHint;

class ControlHintContainer {
	public var isVisible: Bool;
	public var value: Array<ControlHint>;

	public function new() {
		isVisible = false;
		value = [];
	}
}
