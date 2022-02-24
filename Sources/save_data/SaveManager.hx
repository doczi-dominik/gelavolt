package save_data;

import input.InputMapping;
import haxe.Unserializer;
import kha.Storage;
import haxe.Serializer;
import game.actions.ActionCategory;
import game.actions.GameActions;
import game.actions.MenuActions;

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
			while (true) {
				final p: Profile = unser.unserialize();

				p.setDefaults();

				profiles.push(p);
			}
		} catch (_) {}

		if (profiles.length == 0) {
			saveDefaultProfiles();
			return;
		}

		saveProfiles();
	}

	public static function saveDefaultProfiles() {
		profiles.push(new Profile());

		final p2 = new Profile();
		final m = p2.input.mappings;

		m[MENU][PAUSE] = ({keyboardInput: Delete, gamepadInput: OPTIONS} : InputMapping);

		m[GAME][SHIFT_LEFT] = ({keyboardInput: J, gamepadInput: DPAD_LEFT} : InputMapping);
		m[GAME][SHIFT_RIGHT] = ({keyboardInput: L, gamepadInput: DPAD_RIGHT} : InputMapping);
		m[GAME][SOFT_DROP] = ({keyboardInput: K, gamepadInput: DPAD_DOWN} : InputMapping);
		m[GAME][HARD_DROP] = ({keyboardInput: I, gamepadInput: DPAD_UP} : InputMapping);
		m[GAME][ROTATE_LEFT] = ({keyboardInput: O, gamepadInput: CROSS} : InputMapping);
		m[GAME][ROTATE_RIGHT] = ({keyboardInput: P, gamepadInput: CIRCLE} : InputMapping);

		profiles.push(p2);

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
