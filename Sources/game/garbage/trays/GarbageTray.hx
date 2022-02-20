package game.garbage.trays;

import save_data.PrefsSave;
import game.gelos.Gelo;
import kha.Assets;
import game.garbage.GarbageIcon.GARBAGE_ICON_GEOMETRIES;
import kha.graphics2.Graphics;

private enum abstract InnerState(Int) {
	final IDLE = 0;
	final CLOSING;
	final OPENING;
}

class GarbageTray {
	public static function create(prefsSave: PrefsSave) {
		final a = new GarbageTray(prefsSave);

		init(a);

		return a;
	}

	public static function init(a: GarbageTray) {
		a.state = IDLE;
	}

	public static function copyTo(src: GarbageTray, dest: GarbageTray) {
		dest.state = src.state;
	}

	final prefsSave: PrefsSave;
	final display: Array<GarbageIcon>;

	var state: InnerState;

	public function copyFrom(src: GarbageTray) {
		copyTo(src, this);
	}

	public function copy() {
		final a = new GarbageTray(prefsSave);

		a.copyFrom(this);

		return a;
	}

	function new(prefsSave: PrefsSave) {
		this.prefsSave = prefsSave;
		display = [];
	}

	function pushIcon(garbage: Int, divisor: Int, icon: GarbageIcon) {
		for (_ in 0...Std.int(garbage / divisor))
			display.push(icon);

		return Std.int(garbage % divisor);
	}

	function updateDisplay(garbage: Int) {
		display.resize(0);

		var current = garbage;

		if (!prefsSave.capAtCrowns)
			current = pushIcon(current, 1440, COMET);
		current = pushIcon(current, 720, CROWN);
		current = pushIcon(current, 360, MOON);
		current = pushIcon(current, 180, STAR);
		current = pushIcon(current, 30, ROCK);
		current = pushIcon(current, 6, LARGE);
		current = pushIcon(current, 1, SMALL);

		if (display.length > 6)
			display.resize(6);
	}

	function updateClosingState() {}

	function updateOpeningState() {}

	public function startAnimation(garbage: Int) {
		updateDisplay(garbage);
	}

	public function update() {
		switch (state) {
			case IDLE:
			case CLOSING:
				updateClosingState();
			case OPENING:
				updateOpeningState();
		}
	}

	public function render(g: Graphics, x: Float, y: Float, alpha: Float) {
		for (i in 0...display.length) {
			final icon = GARBAGE_ICON_GEOMETRIES[display[i]];

			g.drawSubImage(Assets.images.pixel, x + i * Gelo.SIZE, y, icon.x, icon.y, icon.width, icon.height);
		}
	}
}
