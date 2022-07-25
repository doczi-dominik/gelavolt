package game.fields;

import save_data.PrefsSettings;
import game.gelos.GeloColor;

class DependencyFieldMarker {
	public static function create(prefsSettings: PrefsSettings, defaultColor: GeloColor) {
		return new MultiColorFieldMarker({
			prefsSettings: prefsSettings,
			type: Dependency,
			spriteCoordinates: {x: 898, y: 455},
			defaultColor: defaultColor
		});
	}
}
