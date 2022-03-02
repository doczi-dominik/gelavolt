package save_data;

import save_data.GraphicsSettings.GraphicsSettingsData;
import save_data.Profile.ProfileData;
import haxe.Unserializer;
import kha.Storage;
import haxe.Serializer;

class SaveManager {
	static final PROFILES_FILENAME = "profiles";
	static final GRAPHICS_FIELNAME = "graphics";

	public static final profiles: Array<Profile> = [];

	public static var graphics: GraphicsSettings;

	public static function saveProfiles() {
		final ser = new Serializer();

		for (p in profiles) {
			ser.serialize(p.exportData());
		}

		Storage.namedFile(PROFILES_FILENAME).writeString(ser.toString());
	}

	public static function loadProfiles() {
		final serialized = Storage.namedFile(PROFILES_FILENAME).readString();
		// final serialized = null; // Hackerman manual save lol

		if (serialized == null) {
			newProfile();

			return;
		}

		final unser = new Unserializer(serialized);

		try {
			while (true) {
				final data: ProfileData = unser.unserialize();

				final inputData = data.inputSettings;
				final prefsData = data.prefsSettings;
				final trainingData = data.trainingSettings;

				profiles.push({
					name: data.name,
					inputSettings: {
						menu: inputData.menu,
						game: inputData.game,
						training: inputData.training
					},
					prefsSettings: {
						colorTints: prefsData.colorTints,
						primaryColors: prefsData.primaryColors,
						boardBackground: prefsData.boardBackground,
						capAtCrowns: prefsData.capAtCrowns,
						showGroupShadow: prefsData.showGroupShadow,
						shadowOpacity: prefsData.shadowOpacity,
						shadowHighlightOthers: prefsData.shadowHighlightOthers,
						shadowWillTriggerChain: prefsData.shadowWillTriggerChain
					},
					trainingSettings: {
						clearOnXMode: trainingData.clearOnXMode,
						autoClear: trainingData.autoClear,
						autoAttack: trainingData.autoAttack,
						minAttackTime: trainingData.minAttackTime,
						maxAttackTime: trainingData.maxAttackTime,
						minAttackChain: trainingData.minAttackChain,
						maxAttackChain: trainingData.maxAttackChain,
						minAttackGroupDiff: trainingData.minAttackGroupDiff,
						maxAttackGroupDiff: trainingData.maxAttackGroupDiff,
						minAttackColors: trainingData.minAttackColors,
						maxAttackColors: trainingData.maxAttackColors
					}
				});
			}
		} catch (_) {}

		if (profiles.length == 0) {
			newProfile();
			return;
		}

		saveProfiles();
	}

	public static function newProfile() {
		profiles.push({name: 'P${profiles.length + 1}'});
		saveProfiles();
	}

	public static function getProfile(index: Int) {
		return profiles[index];
	}

	public static function saveGraphics() {
		Storage.namedFile(GRAPHICS_FIELNAME).writeString(Serializer.run(graphics.exportData()));
	}

	public static function loadGraphics() {
		final serialized = Storage.namedFile(GRAPHICS_FIELNAME).readString();

		if (serialized == null) {
			saveDefaultGraphics();

			return;
		}

		try {
			final graphicsData: GraphicsSettingsData = Unserializer.run(serialized);

			graphics = {
				fullscreen: graphicsData.fullscreen
			}
		} catch (_) {}

		if (graphics == null) {
			saveDefaultGraphics();

			return;
		}

		saveGraphics();
	}

	public static function saveDefaultGraphics() {
		graphics = {}
		saveGraphics();
	}

	public static inline function loadEverything() {
		loadProfiles();
		loadGraphics();
	}
}
