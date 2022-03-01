package game.fields;

import save_data.PrefsSettings;
import game.gelos.GeloColor;
import kha.Color;

// TODO: Use abstracts for these?
class DependencyFieldMarker {
	public static function create(prefsSettings: PrefsSettings, defaultColor: GeloColor) {
		return MultiColorFieldMarker.create({
			prefsSettings: prefsSettings,
			type: Dependency,
			spriteCoordinates: {x: 898, y: 455},
			defaultColor: defaultColor
		});
	}
}
