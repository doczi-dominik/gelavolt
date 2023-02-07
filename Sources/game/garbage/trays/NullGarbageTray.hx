package game.garbage.trays;

import kha.graphics2.Graphics;

class NullGarbageTray implements IGarbageTray {
	public static var instance(default, null) = new NullGarbageTray();

	function new() {}

	public function copy(): Dynamic {
		return instance;
	}

	public function startAnimation(garbage: Int) {}

	public function update() {}

	public function render(g: Graphics, x: Float, y: Float, alpha: Float) {}
}
