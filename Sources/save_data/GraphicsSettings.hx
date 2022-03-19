package save_data;

import haxe.ds.StringMap;

enum abstract GraphicsSettingsKey(String) to String {
	final FULLSCREEN;
}

class GraphicsSettings {
	static inline final FULLSCREEN_DEFAULT = true;

	public var fullscreen: Bool;

	public function new(overrides: Map<GraphicsSettingsKey, Any>) {
		fullscreen = FULLSCREEN_DEFAULT;

		try {
			for (k => v in cast(overrides, Map<Dynamic, Dynamic>)) {
				try {
					switch (cast(k, GraphicsSettingsKey)) {
						case FULLSCREEN:
							fullscreen = cast(v, Bool);
					}
				} catch (_) {
					continue;
				}
			}
		} catch (_) {}
	}

	public function exportOverrides() {
		final overrides = new StringMap<Any>();
		var wereOverrides = false;

		if (fullscreen != FULLSCREEN_DEFAULT) {
			overrides.set(FULLSCREEN, fullscreen);
			wereOverrides = true;
		}

		return wereOverrides ? overrides : null;
	}
}
