package game.actionbuffers;

class NullActionBuffer implements IActionBuffer {
	public static var instance(get, null): NullActionBuffer;

	static function get_instance() {
		if (instance == null)
			instance = new NullActionBuffer();

		return instance;
	}

	public var latestAction(default, null): ActionSnapshot;

	function new() {
		latestAction = ActionSnapshot.fromBitField(0);
	}

	public function update() {}

	public function exportReplayData() {
		return new ReplayData();
	}
}
