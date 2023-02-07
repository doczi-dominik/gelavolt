package game.fields;

import game.gelos.FieldGeloPoint;
import game.copying.ConstantCopyableMap;
import game.copying.ConstantCopyableArray;
import game.copying.ICopy;
import game.gelos.GeloColor;

class FieldPopInfo implements ICopy {
	@copy public final beginners: ConstantCopyableArray<FieldGeloPoint>;
	@copy public final clears: ConstantCopyableArray<FieldGeloPoint>;
	@copy public final clearsByColor: ConstantCopyableMap<GeloColor, Int>;

	@copy public var hasPops: Bool;

	public function new() {
		beginners = new ConstantCopyableArray([]);
		clears = new ConstantCopyableArray([]);
		clearsByColor = new ConstantCopyableMap([COLOR1 => 0, COLOR2 => 0, COLOR3 => 0, COLOR4 => 0, COLOR5 => 0]);

		hasPops = false;
	}

	public function copy(): Dynamic {
		return new FieldPopInfo().copyFrom(this);
	}

	public function addClear(color: GeloColor, x: Int, y: Int) {
		clears.data.push({color: color, x: x, y: y});

		if (color.isColored()) {
			final c = clearsByColor.data[color];

			if (c != null) {
				clearsByColor.data[color] = c + 1;
			}
		}
	}
}
