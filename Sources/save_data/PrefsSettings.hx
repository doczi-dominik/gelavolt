package save_data;

import haxe.ds.StringMap;
import game.gelos.GeloColor;
import kha.Color;

enum abstract PrefsSettingsKey(String) to String {
	final COLOR_TINTS;
	final PRIMARY_COLORS;
	final BOARD_BACKGROUND;
	final MENU_REMEMBER_CURSOR;
	final CAP_AT_CROWNS;
	final SHOW_GROUP_SHADOW;
	final SHADOW_OPACITY;
	final SHADOW_HIGHLIGHT_OTHERS;
	final SHADOW_WILL_TRIGGER_CHAIN;
}

// TODO: Separate into GamePrefs And MenuPrefs
// Should explain that e.g.: OptionsPage uses the provided Prefs
// to adjust a specific profile while Menu's Prefs are tied
class PrefsSettings {
	static final COLOR_TINTS_DEFAULT = [
		COLOR1 => White,
		COLOR2 => White,
		COLOR3 => White,
		COLOR4 => White,
		COLOR5 => White,
		EMPTY => White,
		GARBAGE => White,
	];

	static final PRIMARY_COLORS_DEFAULT = [
		COLOR1 => Color.fromValue(0xFFFF001e),
		COLOR2 => Color.fromValue(0xFF00FF15),
		COLOR3 => Color.fromValue(0xFF006DFF),
		COLOR4 => Color.fromValue(0xFFFFF300),
		COLOR5 => Color.fromValue(0xFFC100FF),
		EMPTY => Transparent,
		GARBAGE => Transparent,
	];

	static final BOARD_BACKGROUND_DEFAULT = Color.fromBytes(64, 32, 32);
	static inline final MENU_REMEMBER_CURSOR_DEFAULT = true;
	static inline final CAP_AT_CROWNS_DEFAULT = true;
	static inline final SHOW_GROUP_SHADOW_DEFAULT = true;
	static inline final SHADOW_OPACITY_DEFAULT = 0.5;
	static inline final SHADOW_HIGHLIGHT_OTHERS_DEFAULT = true;
	static inline final SHADOW_WILL_TRIGGER_CHAIN_DEFAULT = true;

	public final colorTints: Map<GeloColor, Color>;
	public final primaryColors: Map<GeloColor, Color>;

	public var boardBackground: Color;
	public var menuRememberCursor: Bool;
	public var capAtCrowns: Bool;
	public var showGroupShadow: Bool;
	public var shadowOpacity: Float;
	public var shadowHighlightOthers: Bool;
	public var shadowWillTriggerChain: Bool;

	public function new(overrides: Map<PrefsSettingsKey, Any>) {
		colorTints = COLOR_TINTS_DEFAULT.copy();
		primaryColors = PRIMARY_COLORS_DEFAULT.copy();

		boardBackground = BOARD_BACKGROUND_DEFAULT;
		menuRememberCursor = MENU_REMEMBER_CURSOR_DEFAULT;
		capAtCrowns = CAP_AT_CROWNS_DEFAULT;
		showGroupShadow = SHOW_GROUP_SHADOW_DEFAULT;
		shadowOpacity = SHADOW_OPACITY_DEFAULT;
		shadowHighlightOthers = SHADOW_HIGHLIGHT_OTHERS_DEFAULT;
		shadowWillTriggerChain = SHADOW_WILL_TRIGGER_CHAIN_DEFAULT;

		try {
			for (k => v in cast(overrides, Map<Dynamic, Dynamic>)) {
				try {
					switch (cast(k, PrefsSettingsKey)) {
						case COLOR_TINTS:
							for (kk => vv in cast(v, Map<Dynamic, Dynamic>))
								colorTints[cast(kk, GeloColor)] = cast(vv, Color);
						case PRIMARY_COLORS:
							for (kk => vv in cast(v, Map<Dynamic, Dynamic>))
								primaryColors[cast(kk, GeloColor)] = cast(vv, Color);
						case BOARD_BACKGROUND:
							boardBackground = cast(v, Color);
						case MENU_REMEMBER_CURSOR:
							menuRememberCursor = cast(v, Bool);
						case CAP_AT_CROWNS:
							capAtCrowns = cast(v, Bool);
						case SHOW_GROUP_SHADOW:
							showGroupShadow = cast(v, Bool);
						case SHADOW_OPACITY:
							shadowOpacity = cast(v, Float);
						case SHADOW_HIGHLIGHT_OTHERS:
							shadowHighlightOthers = cast(v, Bool);
						case SHADOW_WILL_TRIGGER_CHAIN:
							shadowWillTriggerChain = cast(v, Bool);
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

		final tintOverrides = new Map<GeloColor, Color>();
		var wereTintOverrides = false;

		for (k => v in colorTints) {
			if (v != COLOR_TINTS_DEFAULT[k]) {
				tintOverrides[k] = v;
				wereTintOverrides = true;
			}
		}

		if (wereTintOverrides) {
			overrides.set(COLOR_TINTS, tintOverrides);
			wereOverrides = true;
		}

		final primaryOverrides = new Map<GeloColor, Color>();
		var werePrimaryOverrides = false;

		for (k => v in primaryColors) {
			if (v != PRIMARY_COLORS_DEFAULT[k]) {
				primaryOverrides[k] = v;
				werePrimaryOverrides = true;
			}
		}

		if (werePrimaryOverrides) {
			overrides.set(PRIMARY_COLORS, primaryOverrides);
			wereOverrides = true;
		}

		if (boardBackground != BOARD_BACKGROUND_DEFAULT) {
			overrides.set(BOARD_BACKGROUND, boardBackground);
			wereOverrides = true;
		}

		if (menuRememberCursor != MENU_REMEMBER_CURSOR_DEFAULT) {
			overrides.set(MENU_REMEMBER_CURSOR, menuRememberCursor);
			wereOverrides = true;
		}

		if (capAtCrowns != CAP_AT_CROWNS_DEFAULT) {
			overrides.set(CAP_AT_CROWNS, capAtCrowns);
			wereOverrides = true;
		}

		if (showGroupShadow != SHOW_GROUP_SHADOW_DEFAULT) {
			overrides.set(SHOW_GROUP_SHADOW, showGroupShadow);
			wereOverrides = true;
		}

		if (shadowOpacity != SHADOW_OPACITY_DEFAULT) {
			overrides.set(SHADOW_OPACITY, shadowOpacity);
			wereOverrides = true;
		}

		if (shadowHighlightOthers != SHADOW_HIGHLIGHT_OTHERS_DEFAULT) {
			overrides.set(SHADOW_HIGHLIGHT_OTHERS, shadowHighlightOthers);
			wereOverrides = true;
		}

		if (shadowWillTriggerChain != SHADOW_WILL_TRIGGER_CHAIN_DEFAULT) {
			overrides.set(SHADOW_WILL_TRIGGER_CHAIN, shadowWillTriggerChain);
			wereOverrides = true;
		}

		return wereOverrides ? overrides : null;
	}
}
