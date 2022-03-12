package save_data;

import js.Browser;
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

	public static function getProfile(index: Int) {
		return profiles[index];
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

		graphics = new GraphicsSettings(Unserializer.run(serialized));
	}

	public static inline function loadEverything() {
		loadProfiles();
		loadGraphics();
	}
}
