package game.garbage.trays;

import utils.Utils;
import save_data.PrefsSettings;
import game.geometries.BoardGeometries;
import game.garbage.GarbageIcon.GARBAGE_ICON_GEOMETRIES;
import kha.Assets;
import kha.graphics2.Graphics;

class CenterGarbageTray extends GarbageTray {
	public static function create(prefsSettings: PrefsSettings) {
		final a = new CenterGarbageTray(prefsSettings);

		init(a);

		return a;
	}

	public static function init(a: CenterGarbageTray) {
		GarbageTray.init(a);

		a.lastScaleX = 0;
		a.scaleX = 0;
		a.garbage = 0;

		a.state = OPENING;
	}

	@copy var lastScaleX: Float;
	@copy var scaleX: Float;
	@copy var garbage: Int;

	override function copy(): Dynamic {
		return new CenterGarbageTray(prefsSettings).copyFrom(this);
	}

	function new(prefsSettings: PrefsSettings) {
		super(prefsSettings);
	}

	override function updateClosingState() {
		if (scaleX > 0) {
			scaleX = Math.max(scaleX - 0.125, 0);
		} else {
			updateDisplay(garbage);

			state = OPENING;
		}
	}

	override function updateOpeningState() {
		if (scaleX < 1) {
			scaleX = Math.min(scaleX + 0.125, 1);
		} else {
			state = IDLE;
		}
	}

	override function startAnimation(garbage: Int) {
		this.garbage = garbage;
		state = CLOSING;
	}

	override function update() {
		lastScaleX = scaleX;

		super.update();
	}

	override function render(g: Graphics, x: Float, y: Float, alpha: Float) {
		final lerpScaleX = Utils.lerp(lastScaleX, scaleX, alpha);

		for (i in 0...display.data.length) {
			final icon = GARBAGE_ICON_GEOMETRIES[display.data[i]];
			final iconX = BoardGeometries.CENTER.x + (i - 3) * 64 * lerpScaleX;

			g.drawSubImage(Assets.images.pixel, x + iconX, y, icon.x, icon.y, icon.width, icon.height);
		}
	}
}
