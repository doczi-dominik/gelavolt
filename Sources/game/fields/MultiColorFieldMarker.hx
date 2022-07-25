package game.fields;

import game.copying.ConstantCopyableArray;
import game.gelos.GeloColor;
import save_data.PrefsSettings;
import kha.Assets;
import kha.graphics2.Graphics;
import utils.Point;

@:structInit
@:build(game.Macros.buildOptionsClass(MultiColorFieldMarker))
class MultiColorFieldMarkerOptions {}

class MultiColorFieldMarker implements IFieldMarker {
	@inject final prefsSettings: PrefsSettings;
	@inject final spriteCoordinates: Point;
	@inject final defaultColor: GeloColor;
	@copy final colors: ConstantCopyableArray<GeloColor>;

	@inject public final type: FieldMarkerType;

	public function new(opts: MultiColorFieldMarkerOptions) {
		Macros.initFromOpts();

		colors = new ConstantCopyableArray([defaultColor]);
	}

	public function copy() {
		return new MultiColorFieldMarker({
			prefsSettings: prefsSettings,
			spriteCoordinates: spriteCoordinates,
			defaultColor: defaultColor,
			type: type
		}).copyFrom(this);
	}

	public function onSet(value: IFieldMarker) {
		final colorData = colors.data;

		if (value.type == type) {
			final marker = cast(value, MultiColorFieldMarker);

			for (c in marker.colors.data) {
				if (colorData.contains(c)) {
					colorData.remove(c);
				} else {
					colorData.push(c);
				}
			}

			return (this : IFieldMarker);
		}

		return value;
	}

	public function render(g: Graphics, x: Float, y: Float) {
		final colorCount = colors.data.length;
		final width = 64 / colorCount;

		for (i in 0...colorCount) {
			g.color = prefsSettings.primaryColors[colors.data[i]];

			g.drawSubImage(Assets.images.pixel, x + i * width, y, spriteCoordinates.x + i * width, spriteCoordinates.y, width, 64);
		}

		g.color = White;
	}
}
