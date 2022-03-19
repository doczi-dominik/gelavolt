package save_data;

import save_data.IClearOnXModeContainer;
import haxe.ds.StringMap;
import save_data.ClearOnXMode;

enum abstract EndlessSettingsKey(String) to String {
	final CLEAR_ON_X_MODE;
}

class EndlessSettings implements IClearOnXModeContainer {
	static inline final CLEAR_ON_X_MODE_DEFAULT = NEW;

	public var clearOnXMode: ClearOnXMode;

	public function new(overrides: Map<EndlessSettingsKey, Any>) {
		clearOnXMode = CLEAR_ON_X_MODE_DEFAULT;

		try {
			for (k => v in cast(overrides, Map<Dynamic, Dynamic>)) {
				try {
					switch (cast(k, EndlessSettingsKey)) {
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

		if (clearOnXMode != CLEAR_ON_X_MODE_DEFAULT) {
			overrides.set(CLEAR_ON_X_MODE, clearOnXMode);
			wereOverrides = true;
		}

		return wereOverrides ? overrides : null;
	}
}
