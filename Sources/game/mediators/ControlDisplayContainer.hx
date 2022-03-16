package game.mediators;

import ui.ControlDisplay;

class ControlDisplayContainer {
	public var isVisible: Bool;
	public var value: Array<ControlDisplay>;

	public function new() {
		isVisible = true;
		value = [];
	}
}
