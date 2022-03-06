package game.fields;

import save_data.PrefsSettings;
import game.gelos.GeloColor;
import kha.Color;

class ColorConflictFieldMarker {
	public static function create(prefsSettings: PrefsSettings, defaultColor: GeloColor) {
		return MultiColorFieldMarker.create({
			prefsSettings: prefsSettings,
			type: ColorConflict,
			spriteCoordinates: {x: 770, y: 519},
			defaultColor: defaultColor
		});
	}
}
