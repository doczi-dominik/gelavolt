package game.previews;

import utils.Utils;
import game.Queue;
import game.gelos.Gelo;
import kha.graphics2.Graphics;

class VerticalPreview implements IPreview {
	final queue: Queue;

	@copy var t: Int;
	@copy var queueY: Float;
	@copy var beginY: Float;
	@copy var targetY: Float;

	@copy public var isAnimationFinished(default, null): Bool;

	public function new(queue: Queue) {
		this.queue = queue;

		queueY = Gelo.SIZE;
		targetY = Gelo.SIZE;

		isAnimationFinished = true;
	}

	public function startAnimation(index: Int) {
		t = 0;
		beginY = queueY;
		targetY = -(Gelo.SIZE * 2.5 * index);

		isAnimationFinished = false;
	}

	public function update() {
		if (queueY == targetY) {
			isAnimationFinished = true;
			return;
		}

		queueY = Utils.lerp(beginY, targetY, t / 12);
		t++;
	}

	public function render(g: Graphics, x: Float, y: Float) {
		// "Large" values account for the input repeat mechanism on the
		// PreviousStep/NextStep actions.
		for (i in -5...8) {
			final index = queue.currentIndex + i;

			queue.get(index).render(g, x, queueY + Gelo.SIZE * 2.5 * index + Gelo.SIZE * 1.5);
		}
	}
}
