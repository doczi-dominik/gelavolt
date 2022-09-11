package save_data;

import save_data.ClearOnXMode;

@:structInit
class EndlessSettings implements hxbit.Serializable implements IClearOnXModeContainer {
	@:s @:optional public var showControlHints = true;
	@:s @:optional public var clearOnXMode = NEW;
}
