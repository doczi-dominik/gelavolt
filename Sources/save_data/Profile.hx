package save_data;

import game.geometries.BoardGeometries;

/**
 * User-defined settings and preferences.
 */
class Profile {
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
	public static var primary: Profile;

	public var input: Null<InputSave>;
	public var prefs: Null<PrefsSave>;
	public var training: Null<TrainingSave>;

	// Solo layout options
	public var soloLayoutGeometries: Null<BoardGeometries>;

	// Dual layout options
	public var dualLayoutLeftGeometries: Null<BoardGeometries>;
	public var dualLayoutRightGeometries: Null<BoardGeometries>;

	public function new() {
		setDefaults();
	}

	public function setDefaults() {
		if (input == null)
			input = new InputSave();
		input.setDefaults();

		if (prefs == null)
			prefs = new PrefsSave();
		prefs.setDefaults();

		if (training == null)
			training = new TrainingSave();
		training.setDefaults();

		if (soloLayoutGeometries == null)
			soloLayoutGeometries = BoardGeometries.CENTERED;
		if (dualLayoutLeftGeometries == null)
			dualLayoutLeftGeometries = BoardGeometries.LEFT;
		if (dualLayoutRightGeometries == null)
			dualLayoutRightGeometries = BoardGeometries.RIGHT;
	}
}
