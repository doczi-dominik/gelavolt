package game.previews;

import kha.graphics2.Graphics;

interface IPreview {
	public var isAnimationFinished(default, null): Bool;

	public function startAnimation(index: Int): Void;

	public function update(): Void;
	public function render(g: Graphics, x: Float, y: Float): Void;
}
