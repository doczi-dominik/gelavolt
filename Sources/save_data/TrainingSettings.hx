package save_data;

import save_data.ClearOnXMode;

@:structInit
class TrainingSettings implements hxbit.Serializable implements IClearOnXModeContainer {
	@:s @:optional public var showControlHints = true;
	@:s @:optional public var clearOnXMode = RESTART;
	@:s @:optional public var autoClear = true;
	@:s @:optional public var minAttackTime = 10;
	@:s @:optional public var maxAttackTime = 10;
	@:s @:optional public var minAttackChain = 3;
	@:s @:optional public var maxAttackChain = 3;
	@:s @:optional public var minAttackGroupDiff = 0;
	@:s @:optional public var maxAttackGroupDiff = 0;
	@:s @:optional public var minAttackColors = 1;
	@:s @:optional public var maxAttackColors = 1;
	@:s @:optional public var groupBlindMode = false;
	@:s @:optional public var keepGroupCount = 0;
}
