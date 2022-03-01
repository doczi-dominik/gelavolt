package save_data;

import save_data.ClearOnXMode;

@:structInit
class TrainingSettings {
	@:optional public var clearOnXMode = ClearOnXMode.RESTART;
	@:optional public var autoClear = true;
	@:optional public var autoAttack = false;
	@:optional public var minAttackTime = 10;
	@:optional public var maxAttackTime = 10;
	@:optional public var minAttackChain = 3;
	@:optional public var maxAttackChain = 3;
	@:optional public var minAttackGroupDiff = 0;
	@:optional public var maxAttackGroupDiff = 0;
	@:optional public var minAttackColors = 1;
	@:optional public var maxAttackColors = 1;

	public function exportData(): TrainingSettingsData {
		return {
			clearOnXMode: clearOnXMode,
			autoClear: autoClear,
			autoAttack: autoAttack,
			minAttackTime: minAttackTime,
			maxAttackTime: maxAttackTime,
			minAttackChain: minAttackChain,
			maxAttackChain: maxAttackChain,
			minAttackGroupDiff: minAttackGroupDiff,
			maxAttackGroupDiff: maxAttackGroupDiff,
			minAttackColors: minAttackColors,
			maxAttackColors: maxAttackColors
		};
	}
}

typedef TrainingSettingsData = {
	clearOnXMode: ClearOnXMode,
	autoClear: Bool,
	autoAttack: Bool,
	minAttackTime: Int,
	maxAttackTime: Int,
	minAttackChain: Int,
	maxAttackChain: Int,
	minAttackGroupDiff: Int,
	maxAttackGroupDiff: Int,
	minAttackColors: Int,
	maxAttackColors: Int,
}
