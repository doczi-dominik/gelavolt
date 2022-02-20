package save_data;

import haxe.Unserializer;
import kha.Storage;
import haxe.Serializer;

class SaveManager {
	static final PROFILES_FILENAME = "profiles";
	static final GRAPHICS_FIELNAME = "graphics";

	static final profiles: Array<Profile> = [];
	public static var graphics: GraphicsSave;

	public static function saveProfiles() {
		final ser = new Serializer();

		for (p in profiles) {
			ser.serialize(p);
		}

		Storage.namedFile(PROFILES_FILENAME).writeString(ser.toString());
	}

	public static function loadProfiles() {
		final serialized = Storage.namedFile(PROFILES_FILENAME).readString();
		// final serialized = null; // Hackerman manual save lol

		if (serialized == null) {
			saveDefaultProfiles();

			return;
		}

		final unser = new Unserializer(serialized);

		try {
			final p: Profile = unser.unserialize();

			p.setDefaults();

			profiles.push(p);
		} catch (_) {}

		if (profiles.length == 0) {
			saveDefaultProfiles();
			return;
		}

		saveProfiles();
	}

	public static function saveDefaultProfiles() {
		profiles.push(new Profile());
		saveProfiles();
	}

	public static function getProfile(index: Int) {
		return profiles[index];
	}

	public static function saveGraphics() {
		Storage.namedFile(GRAPHICS_FIELNAME).writeString(Serializer.run(graphics));
	}

	public static function loadGraphics() {
		final serialized = Storage.namedFile(GRAPHICS_FIELNAME).readString();

		if (serialized == null) {
			saveDefaultGraphics();

			return;
		}

		try {
			graphics = Unserializer.run(serialized);
			graphics.setDefaults();
		} catch (_) {}

		if (graphics == null) {
			saveDefaultGraphics();

			return;
		}

		saveGraphics();
	}

	public static function saveDefaultGraphics() {
		graphics = new GraphicsSave();
		graphics.setDefaults();
		saveGraphics();
	}

	public static inline function loadEverything() {
		loadProfiles();
		loadGraphics();
	}
}
