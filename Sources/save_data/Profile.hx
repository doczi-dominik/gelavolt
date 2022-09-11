package save_data;

import haxe.ds.StringMap;
import save_data.TrainingSettings;
import save_data.PrefsSettings;
import save_data.InputSettings;

class Profile implements hxbit.Serializable {
	static final onChangePrimary: Array<Void->Void> = [];

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

	@:s public var name: String;

	@:s public var input(default, null) = new InputSettings();
	@:s public var prefs(default, null): PrefsSettings = {};
	@:s public var trainingSettings(default, null): TrainingSettings = {};
	@:s public var endlessSettings(default, null): EndlessSettings = {};

	public function new(name: String) {
		this.name = name;
	}

	public inline function setInputDefaults() {
		input = new InputSettings();
	}

	public inline function setPrefsDefaults() {
		prefs = {};
	}

	public inline function setTrainingDefaults() {
		trainingSettings = {};
	}

	public inline function setEndlessDefaults() {
		endlessSettings = {};
	}

	public function setDefaults() {
		setInputDefaults();
		setPrefsDefaults();
		setTrainingDefaults();
		setEndlessDefaults();
	}
}
