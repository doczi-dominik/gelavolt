package game.fields;

import save_data.PrefsSave;
import game.gelos.GeloColor;
import kha.Color;

// TODO: Use abstracts for these?
class DependencyFieldMarker {
	public static function create(prefsSave: PrefsSave, defaultColor: GeloColor) {
		return MultiColorFieldMarker.create({
			prefsSave: prefsSave,
			type: Dependency,
			spriteCoordinates: {x: 898, y: 455},
			defaultColor: defaultColor
		});
	}
}
