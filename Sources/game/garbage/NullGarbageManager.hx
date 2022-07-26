package game.garbage;

import game.gelos.ScreenGeloPoint;
import kha.graphics2.Graphics;

class NullGarbageManager implements IGarbageManager {
	public static var instance(get, null): NullGarbageManager;

	static function get_instance() {
		if (instance == null)
			instance = new NullGarbageManager();

		return instance;
	}

	public var canReceiveGarbage: Bool = false;
	public var droppableGarbage(get, never): Int;

	function get_droppableGarbage() {
		return 0;
	}

	function new() {}

	public function init() {}

	public function sendGarbage(amount: Int, beginners: Array<ScreenGeloPoint>) {}

	public function dropGarbage(amount: Int) {}

	public function confirmGarbage(amount: Int) {}

	public function clear() {}

	public function update() {}

	public function render(g: Graphics, x: Float, y: Float, alpha: Float) {}
}
