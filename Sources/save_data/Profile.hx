package save_data;

import save_data.TrainingSettings;
import save_data.PrefsSettings;
import save_data.InputSettings;
import game.geometries.BoardGeometries;

/**
 * User-defined settings and preferences.
 */
@:structInit
class Profile {
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

	@:optional public var name = "P1";

	@:optional public var inputSettings: InputSettings = {};
	@:optional public var prefsSettings: PrefsSettings = {};
	@:optional public var trainingSettings: TrainingSettings = {};

	public function exportData(): ProfileData {
		return {
			name: name,
			inputSettings: {
				menu: inputSettings.menu,
				game: inputSettings.game,
				training: inputSettings.training
			},
			prefsSettings: {
				colorTints: prefsSettings.colorTints,
				primaryColors: prefsSettings.primaryColors,
				boardBackground: prefsSettings.boardBackground,
				capAtCrowns: prefsSettings.capAtCrowns,
				showGroupShadow: prefsSettings.showGroupShadow,
				shadowOpacity: prefsSettings.shadowOpacity,
				shadowHighlightOthers: prefsSettings.shadowHighlightOthers,
				shadowWillTriggerChain: prefsSettings.shadowWillTriggerChain
			},
			trainingSettings: {
				clearOnXMode: trainingSettings.clearOnXMode,
				autoClear: trainingSettings.autoClear,
				autoAttack: trainingSettings.autoAttack,
				minAttackTime: trainingSettings.minAttackTime,
				maxAttackTime: trainingSettings.maxAttackTime,
				minAttackChain: trainingSettings.minAttackChain,
				maxAttackChain: trainingSettings.maxAttackChain,
				minAttackGroupDiff: trainingSettings.minAttackGroupDiff,
				maxAttackGroupDiff: trainingSettings.maxAttackGroupDiff,
				minAttackColors: trainingSettings.minAttackColors,
				maxAttackColors: trainingSettings.maxAttackColors
			}
		};
	}
}

typedef ProfileData = {
	name: String,
	inputSettings: InputSettingsData,
	prefsSettings: PrefsSettingsData,
	trainingSettings: TrainingSettingsData
};
