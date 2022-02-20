package game.fields;

import save_data.PrefsSave;
import game.gelos.GeloColor;
import kha.Color;

class ColorConflictFieldMarker {
	public static function create(prefsSave: PrefsSave, defaultColor: GeloColor) {
		return MultiColorFieldMarker.create({
			prefsSave: prefsSave,
			type: ColorConflict,
			spriteCoordinates: {x: 770, y: 519},
			defaultColor: defaultColor
		});
	}
}
