package main;

import kha.graphics2.Graphics;

final class NullScreen implements IScreen {
	public static final instance = new NullScreen();

	function new() {}

	public function dispose() {}

	public function update() {}

	public function render(g: Graphics, g4: kha.graphics4.Graphics, alpha: Float) {}
}
