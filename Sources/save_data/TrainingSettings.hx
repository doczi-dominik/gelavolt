package save_data;

import save_data.IClearOnXModeContainer;
import haxe.ds.StringMap;
import save_data.ClearOnXMode;

enum abstract TrainingSettingsKey(String) to String {
	final CLEAR_ON_X_MODE;
	final AUTO_CLEAR;
	final AUTO_ATTACK;
	final MIN_ATTACK_TIME;
	final MAX_ATTACK_TIME;
	final MIN_ATTACK_CHAIN;
	final MAX_ATTACK_CHAIN;
	final MIN_ATTACK_GROUP_DIFF;
	final MAX_ATTACK_GROUP_DIFF;
	final MIN_ATTACK_COLORS;
	final MAX_ATTACK_COLORS;
}

class TrainingSettings implements IClearOnXModeContainer {
	static inline final CLEAR_ON_X_MODE_DEFAULT = RESTART;
	static inline final AUTO_CLEAR_DEFAULT = true;
	static inline final AUTO_ATTACK_DEFAULT = false;
	static inline final ATTACK_TIME_DEFAULT = 10;
	static inline final ATTACK_CHAIN_DEFAULT = 3;
	static inline final ATTACK_GROUP_DIFF_DEFAULT = 0;
	static inline final ATTACK_COLORS_DEFAULT = 1;

	public var clearOnXMode: ClearOnXMode;
	public var autoClear: Bool;
	public var autoAttack: Bool;
	public var minAttackTime: Int;
	public var maxAttackTime: Int;
	public var minAttackChain: Int;
	public var maxAttackChain: Int;
	public var minAttackGroupDiff: Int;
	public var maxAttackGroupDiff: Int;
	public var minAttackColors: Int;
	public var maxAttackColors: Int;

	public function new(overrides: Map<TrainingSettingsKey, Dynamic>) {
		clearOnXMode = CLEAR_ON_X_MODE_DEFAULT;
		autoClear = AUTO_CLEAR_DEFAULT;
		autoAttack = AUTO_ATTACK_DEFAULT;
		minAttackTime = ATTACK_TIME_DEFAULT;
		maxAttackTime = ATTACK_TIME_DEFAULT;
		minAttackChain = ATTACK_CHAIN_DEFAULT;
		maxAttackChain = ATTACK_CHAIN_DEFAULT;
		minAttackGroupDiff = ATTACK_GROUP_DIFF_DEFAULT;
		maxAttackGroupDiff = ATTACK_GROUP_DIFF_DEFAULT;
		minAttackColors = ATTACK_COLORS_DEFAULT;
		maxAttackColors = ATTACK_COLORS_DEFAULT;

		try {
			for (k => v in cast(overrides, Map<Dynamic, Dynamic>)) {
				try {
					switch (cast(k, TrainingSettingsKey)) {
						case CLEAR_ON_X_MODE:
							clearOnXMode = cast(v, ClearOnXMode);
						case AUTO_CLEAR:
							autoClear = cast(v, Bool);
						case AUTO_ATTACK:
							autoAttack = cast(v, Bool);
						case MIN_ATTACK_TIME:
							minAttackTime = cast(v, Int);
						case MAX_ATTACK_TIME:
							maxAttackTime = cast(v, Int);
						case MIN_ATTACK_CHAIN:
							minAttackChain = cast(v, Int);
						case MAX_ATTACK_CHAIN:
							maxAttackChain = cast(v, Int);
						case MIN_ATTACK_GROUP_DIFF:
							minAttackGroupDiff = cast(v, Int);
						case MAX_ATTACK_GROUP_DIFF:
							maxAttackGroupDiff = cast(v, Int);
						case MIN_ATTACK_COLORS:
							minAttackColors = cast(v, Int);
						case MAX_ATTACK_COLORS:
							maxAttackColors = cast(v, Int);
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

		if (autoClear != AUTO_CLEAR_DEFAULT) {
			overrides.set(AUTO_CLEAR, autoClear);
			wereOverrides = true;
		}

		if (minAttackTime != ATTACK_TIME_DEFAULT) {
			overrides.set(MIN_ATTACK_TIME, minAttackTime);
			wereOverrides = true;
		}

		if (maxAttackTime != ATTACK_TIME_DEFAULT) {
			overrides.set(MAX_ATTACK_TIME, maxAttackTime);
			wereOverrides = true;
		}

		if (minAttackChain != ATTACK_CHAIN_DEFAULT) {
			overrides.set(MIN_ATTACK_CHAIN, minAttackChain);
			wereOverrides = true;
		}

		if (maxAttackChain != ATTACK_CHAIN_DEFAULT) {
			overrides.set(MAX_ATTACK_CHAIN, maxAttackChain);
			wereOverrides = true;
		}

		if (minAttackGroupDiff != ATTACK_GROUP_DIFF_DEFAULT) {
			overrides.set(MIN_ATTACK_GROUP_DIFF, minAttackGroupDiff);
			wereOverrides = true;
		}

		if (maxAttackGroupDiff != ATTACK_GROUP_DIFF_DEFAULT) {
			overrides.set(MAX_ATTACK_GROUP_DIFF, maxAttackGroupDiff);
			wereOverrides = true;
		}

		if (minAttackColors != ATTACK_COLORS_DEFAULT) {
			overrides.set(MIN_ATTACK_COLORS, minAttackColors);
			wereOverrides = true;
		}

		if (maxAttackColors != ATTACK_COLORS_DEFAULT) {
			overrides.set(MAX_ATTACK_COLORS, maxAttackColors);
			wereOverrides = true;
		}

		return wereOverrides ? overrides : null;
	}
}
