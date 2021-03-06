package save_data;

import save_data.IClearOnXModeContainer;
import haxe.ds.StringMap;
import save_data.ClearOnXMode;

enum abstract EndlessSettingsKey(String) to String {
	final SHOW_CONTROL_HINTS;
	final CLEAR_ON_X_MODE;
}

class EndlessSettings implements IClearOnXModeContainer {
	static inline final SHOW_CONTROL_HINTS_DEFAULT = true;
	static inline final CLEAR_ON_X_MODE_DEFAULT = NEW;

	public var showControlHints: Bool;
	public var clearOnXMode: ClearOnXMode;

	public function new(overrides: Map<EndlessSettingsKey, Any>) {
		showControlHints = SHOW_CONTROL_HINTS_DEFAULT;
		clearOnXMode = CLEAR_ON_X_MODE_DEFAULT;

		try {
			for (k => v in cast(overrides, Map<Dynamic, Dynamic>)) {
				try {
					switch (cast(k, EndlessSettingsKey)) {
						case SHOW_CONTROL_HINTS:
							showControlHints = cast(v, Bool);
						case CLEAR_ON_X_MODE:
							clearOnXMode = cast(v, ClearOnXMode);
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

		if (showControlHints != SHOW_CONTROL_HINTS_DEFAULT) {
			overrides.set(SHOW_CONTROL_HINTS, showControlHints);
			wereOverrides = true;
		}

		if (clearOnXMode != CLEAR_ON_X_MODE_DEFAULT) {
			overrides.set(CLEAR_ON_X_MODE, clearOnXMode);
			wereOverrides = true;
		}

		return wereOverrides ? overrides : null;
	}
}
