package game.garbage.trays;

import utils.Utils;
import save_data.PrefsSave;
import game.geometries.BoardGeometries;
import game.garbage.GarbageIcon.GARBAGE_ICON_GEOMETRIES;
import kha.Assets;
import kha.graphics2.Graphics;

class CenterGarbageTray extends GarbageTray {
	public static function create(prefsSave: PrefsSave) {
		final a = new CenterGarbageTray(prefsSave);

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

	public static function copyTo(src: CenterGarbageTray, dest: CenterGarbageTray) {
		GarbageTray.copyTo(src, dest);

		dest.lastScaleX = src.lastScaleX;
		dest.scaleX = src.scaleX;
		dest.garbage = src.garbage;
	}

	var lastScaleX: Float;
	var scaleX: Float;
	var garbage: Int;

	override function copyFrom(src: GarbageTray) {
		copyTo(cast(src, CenterGarbageTray), this);
	}

	override function copy(): GarbageTray {
		final a = new CenterGarbageTray(prefsSave);

		a.copyFrom(this);

		return a;
	}

	function new(prefsSave: PrefsSave) {
		super(prefsSave);
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

		for (i in 0...display.length) {
			final icon = GARBAGE_ICON_GEOMETRIES[display[i]];
			final iconX = BoardGeometries.CENTER.x + (i - 3) * 64 * lerpScaleX;

			g.drawSubImage(Assets.images.pixel, x + iconX, y, icon.x, icon.y, icon.width, icon.height);
		}
	}
}
