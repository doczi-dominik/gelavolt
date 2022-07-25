package game.fields;

import save_data.PrefsSettings;
import game.gelos.GeloColor;

class ColorConflictFieldMarker {
	public static function create(prefsSettings: PrefsSettings, defaultColor: GeloColor) {
		return new MultiColorFieldMarker({
			prefsSettings: prefsSettings,
			type: ColorConflict,
			spriteCoordinates: {x: 770, y: 519},
			defaultColor: defaultColor
		});
	}
}
