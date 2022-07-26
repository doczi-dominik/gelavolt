package game.garbage.trays;

import game.copying.ConstantCopyableArray;
import save_data.PrefsSettings;
import game.gelos.Gelo;
import kha.Assets;
import game.garbage.GarbageIcon.GARBAGE_ICON_GEOMETRIES;
import kha.graphics2.Graphics;

private enum abstract InnerState(Int) {
	final IDLE = 0;
	final CLOSING;
	final OPENING;
}

class GarbageTray implements IGarbageTray {
	public static function create(prefsSettings: PrefsSettings) {
		final a = new GarbageTray(prefsSettings);

		init(a);

		return a;
	}

	public static function init(a: GarbageTray) {
		a.state = IDLE;
	}

	final prefsSettings: PrefsSettings;

	@copy final display: ConstantCopyableArray<GarbageIcon>;

	@copy var state: InnerState;

	function new(prefsSettings: PrefsSettings) {
		this.prefsSettings = prefsSettings;
		display = new ConstantCopyableArray([]);
	}

	public function copy() {
		return new GarbageTray(prefsSettings).copyFrom(this);
	}

	function pushIcon(garbage: Int, divisor: Int, icon: GarbageIcon) {
		for (_ in 0...Std.int(garbage / divisor))
			display.data.push(icon);

		return Std.int(garbage % divisor);
	}

	function updateDisplay(garbage: Int) {
		final d = display.data;

		d.resize(0);

		var current = garbage;

		if (!prefsSettings.capAtCrowns)
			current = pushIcon(current, 1440, COMET);
		current = pushIcon(current, 720, CROWN);
		current = pushIcon(current, 360, MOON);
		current = pushIcon(current, 180, STAR);
		current = pushIcon(current, 30, ROCK);
		current = pushIcon(current, 6, LARGE);
		current = pushIcon(current, 1, SMALL);

		if (d.length > 6)
			d.resize(6);
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
		for (i in 0...display.data.length) {
			final icon = GARBAGE_ICON_GEOMETRIES[display.data[i]];

			g.drawSubImage(Assets.images.pixel, x + i * Gelo.SIZE, y, icon.x, icon.y, icon.width, icon.height);
		}
	}
}
