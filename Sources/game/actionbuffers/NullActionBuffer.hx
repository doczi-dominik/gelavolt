package game.actionbuffers;

class NullActionBuffer implements IActionBuffer {
	static var instance: NullActionBuffer;

	public static function getInstance() {
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
		return new Map<Int, Int>();
	}
}
