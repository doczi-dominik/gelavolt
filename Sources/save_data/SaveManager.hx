package save_data;

import save_data.GraphicsSettings.GraphicsSettingsKey;
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
			ser.serialize(p.exportOverrides());
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
				final overrides = unser.unserialize();

				profiles.push(new Profile(overrides));
			}
		} catch (_) {}

		if (profiles.length == 0) {
			newProfile();
			return;
		}
	}

	public static function newProfile() {
		profiles.push(new Profile([NAME => 'P${profiles.length + 1}']));
		saveProfiles();
	}

	public static function deleteProfile(p: Profile) {
		profiles.remove(p);
		saveProfiles();
	}

	public static inline function getProfile(index: Int) {
		return profiles[index];
	}

	public static inline function getProfileCount() {
		return profiles.length;
	}

	public static function saveGraphics() {
		final overrides = graphics.exportOverrides();

		if (overrides == null)
			return;

		Storage.namedFile(GRAPHICS_FIELNAME).writeString(Serializer.run(overrides));
	}

	public static function loadGraphics() {
		final serialized = Storage.namedFile(GRAPHICS_FIELNAME).readString();

		if (serialized == null) {
			graphics = new GraphicsSettings([]);

			return;
		}

		var overrides: Map<GraphicsSettingsKey, Any> = [];

		try {
			overrides = Unserializer.run(serialized);
		} catch (_) {}

		graphics = new GraphicsSettings(overrides);
	}

	public static inline function loadEverything() {
		loadProfiles();
		loadGraphics();
	}
}
