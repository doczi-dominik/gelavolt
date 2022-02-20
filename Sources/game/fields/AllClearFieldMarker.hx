package game.fields;

import save_data.PrefsSave;
import game.gelos.GeloColor;
import kha.Color;

class AllClearFieldMarker {
	public static function create(prefsSave: PrefsSave, defaultColor: GeloColor) {
		return MultiColorFieldMarker.create({
			prefsSave: prefsSave,
			type: AllClear,
			spriteCoordinates: {x: 834, y: 455},
			defaultColor: defaultColor
		});
	}
}
