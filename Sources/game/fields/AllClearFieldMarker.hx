package game.fields;

import save_data.PrefsSettings;
import game.gelos.GeloColor;
import kha.Color;

class AllClearFieldMarker {
	public static function create(prefsSettings: PrefsSettings, defaultColor: GeloColor) {
		return new MultiColorFieldMarker({
			prefsSettings: prefsSettings,
			type: AllClear,
			spriteCoordinates: {x: 834, y: 455},
			defaultColor: defaultColor
		});
	}
}
