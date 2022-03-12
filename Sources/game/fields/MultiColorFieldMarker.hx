package game.fields;

import game.gelos.GeloColor;
import save_data.PrefsSettings;
import kha.Assets;
import kha.graphics2.Graphics;
import kha.Color;
import utils.Point;

class MultiColorFieldMarker implements IFieldMarker {
	public static function init(m: MultiColorFieldMarker) {
		m.colors = [m.defaultColor];
	}

	public static function create(opts: ConstructorOptions) {
		final m = new MultiColorFieldMarker(opts);

		init(m);

		return m;
	}

	final prefsSettings: PrefsSettings;
	final spriteCoordinates: Point;
	final defaultColor: GeloColor;

	var colors: Array<GeloColor>;

	public final type: FieldMarkerType;

	function new(opts: ConstructorOptions) {
		prefsSettings = opts.prefsSettings;
		spriteCoordinates = opts.spriteCoordinates;
		defaultColor = opts.defaultColor;

		type = opts.type;
	}

	public function copy() {
		final c = new MultiColorFieldMarker({
			prefsSettings: prefsSettings,
			spriteCoordinates: spriteCoordinates,
			defaultColor: defaultColor,
			type: type
		});

		c.colors = colors.copy();

		return c;
	}

	public function onSet(value: IFieldMarker) {
		if (value.type == type) {
			final marker = cast(value, MultiColorFieldMarker);

			for (c in marker.colors) {
				if (colors.contains(c)) {
					colors.remove(c);
				} else {
					colors.push(c);
				}
			}

			return (this : IFieldMarker);
		}

		return value;
	}

	public function render(g: Graphics, x: Float, y: Float) {
		final colorCount = colors.length;
		final width = 64 / colorCount;

		for (i in 0...colorCount) {
			g.color = prefsSettings.primaryColors[colors[i]];

			g.drawSubImage(Assets.images.pixel, x + i * width, y, spriteCoordinates.x + i * width, spriteCoordinates.y, width, 64);
		}

		g.color = White;
	}
}

@:structInit
class ConstructorOptions {
	public final prefsSettings: PrefsSettings;
	public final type: FieldMarkerType;
	public final spriteCoordinates: Point;
	public final defaultColor: GeloColor;
}
