package save_data;

import kha.Storage;
import kha.Blob;
import hxbit.Serializer;

using Safety;

class SaveManager {
	static inline final PROFILES_FILENAME = "profiles";
	static inline final GRAPHICS_FIELNAME = "graphics";

	public static var profiles(default, null) = new Array<Profile>();

	public static var graphics: GraphicsSettings = {};

	public static function saveProfiles() {
		final ser = new Serializer();

		ser.beginSave();

		ser.addArray(profiles, f -> {
			ser.addKnownRef(f);
		});

		final data = Blob.fromBytes(ser.endSave());

		Storage.namedFile(PROFILES_FILENAME).write(data);
	}

	public static function loadProfiles() {
		final blob = Storage.namedFile(PROFILES_FILENAME).read();
		// final blob = null; // Hackerman manual save lol

		final ser = new Serializer();

		try {
			if (blob == null) {
				throw "Null Blob";
			}

			ser.beginLoad(blob.bytes);

			// Inlined library functions
			// falsly trigger null safety
			@:nullSafety(Off)
			final ps: Array<Profile> = ser.getArray(() -> {
				return ser.getKnownRef(Profile);
			}).sure();

			ser.endLoad();

			if (ps.length == 0) {
				throw "Empty Profile List";
			}

			profiles = ps;
		} catch (_) {
			profiles = [];
			newProfile();
		}
	}

	public static function newProfile() {
		profiles.push(new Profile('P${profiles.length + 1}'));

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
		final ser = new Serializer();

		ser.beginSave();

		ser.addKnownRef(graphics);

		final data = Blob.fromBytes(ser.endSave());

		Storage.namedFile(GRAPHICS_FIELNAME).write(data);
	}

	public static function loadGraphics() {
		final blob = Storage.namedFile(GRAPHICS_FIELNAME).read();

		final ser = new Serializer();

		try {
			if (blob == null)
				throw "Null Blob";

			ser.beginLoad(blob.bytes);

			graphics = ser.getKnownRef(GraphicsSettings);

			ser.endLoad();
		} catch (_) {
			graphics = {};
			saveGraphics();

			return;
		}
	}

	public static inline function loadEverything() {
		loadProfiles();
		loadGraphics();
	}
}
