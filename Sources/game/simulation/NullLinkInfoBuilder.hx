package game.simulation;

class NullLinkInfoBuilder implements ILinkInfoBuilder {
	public static var instance(get, null): Null<NullLinkInfoBuilder>;

	static function get_instance() {
		if (instance == null)
			instance = new NullLinkInfoBuilder();

		return instance;
	}

	final info: LinkInfo;

	function new() {
		info = {
			chain: 0,
			score: 0,
			clearCount: 0,
			chainPower: 0,
			groupBonus: 0,
			colorBonus: 0,

			garbage: 0,
			accumulatedGarbage: 0,
			garbageRemainder: 0,
			sendsAllClearBonus: false,

			isPowerful: false,
		};
	}

	public function build(params: LinkInfoBuildParameters) {
		return info;
	}
}
