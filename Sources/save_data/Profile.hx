package save_data;

import haxe.ds.StringMap;
import save_data.TrainingSettings;
import save_data.PrefsSettings;
import save_data.InputSettings;

enum abstract ProfileKey(String) to String {
	final NAME;
	final INPUT;
	final PREFS;
	final TRAINING_SETTINGS;
	final ENDLESS_SETTINGS;
}

class Profile {
	static inline final NAME_DEFAULT = "GUGU";

	static final onChangePrimary: Array<Void->Void> = [];

	/**
	 * The `primary` profile is used for storing session-universal information.
	 * These can (or will) include: background type, music, personalization
	 * options and even the input bindings in singleplayer gamemodes. The
	 * `primary` field must be set before calling `create()`.
	 * 
	 * Previously, `primaryProfile` fields were supplied to every components
	 * that needed them. During experimenting with replays, I found coupling
	 * primaryProfile difficult when sharing between hosts since the exact
	 * same Profile object would have to be constructed on the remote side,
	 * which is unnecessary.
	 * 
	 * Also, decoupling primaryProfile allows for more freedom, e.g.: changing
	 * the BGM or skin of a recorded replay!
	 */
	public static var primary(default, null): Profile;

	public static function addOnChangePrimaryCallback(callback: Void->Void) {
		onChangePrimary.push(callback);
		callback();
	}

	public static function changePrimary(p: Profile) {
		primary = p;

		for (f in onChangePrimary) {
			f();
		}
	}

	public var name: String;

	public var input(default, null): InputSettings;
	public var prefs(default, null): PrefsSettings;
	public var trainingSettings(default, null): TrainingSettings;
	public var endlessSettings(default, null): EndlessSettings;

	public function new(overrides: Map<ProfileKey, Any>) {
		name = NAME_DEFAULT;

		var inputOverrides = new Map();
		var prefsOverrides = new Map();
		var trainingOverrides = new Map();
		var endlessOverrides = new Map();

		try {
			for (k => v in cast(overrides, Map<Dynamic, Dynamic>)) {
				try {
					switch (cast(k, ProfileKey)) {
						case NAME:
							name = cast(v, String);

						// Validated in respective constructors
						case INPUT:
							inputOverrides = v;
						case PREFS:
							prefsOverrides = v;
						case TRAINING_SETTINGS:
							trainingOverrides = v;
						case ENDLESS_SETTINGS:
							endlessOverrides = v;
					}
				} catch (_) {
					continue;
				}
			}
		} catch (_) {}

		input = new InputSettings(inputOverrides);
		prefs = new PrefsSettings(prefsOverrides);
		trainingSettings = new TrainingSettings(trainingOverrides);
		endlessSettings = new EndlessSettings(endlessOverrides);
	}

	public inline function setInputDefaults() {
		input.setDefaults();
	}

	public inline function setPrefsDefaults() {
		prefs = new PrefsSettings([]);
	}

	public inline function setTrainingDefaults() {
		trainingSettings = new TrainingSettings([]);
	}

	public inline function setEndlessDefaults() {
		endlessSettings = new EndlessSettings([]);
	}

	public inline function setDefaults() {
		setInputDefaults();
		setPrefsDefaults();
		setTrainingDefaults();
		setEndlessDefaults();
	}

	public function exportOverrides() {
		final overrides = new StringMap<Any>();
		// No need for wereOverrides flag since NAME is always set

		overrides.set(NAME, name);

		final inputOverrides = input.exportOverrides();

		if (inputOverrides != null) {
			overrides.set(INPUT, inputOverrides);
		}

		final prefsOverrides = prefs.exportOverrides();

		if (prefsOverrides != null) {
			overrides.set(PREFS, prefsOverrides);
		}

		final trainingOverrides = trainingSettings.exportOverrides();

		if (trainingOverrides != null) {
			overrides.set(TRAINING_SETTINGS, trainingOverrides);
		}

		final endlessOverrides = endlessSettings.exportOverrides();

		if (endlessOverrides != null) {
			overrides.set(ENDLESS_SETTINGS, endlessOverrides);
		}

		return overrides;
	}
}
