package save_data;

import game.geometries.BoardGeometries;

/**
 * User-defined settings and preferences.
 */
class Profile {
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
